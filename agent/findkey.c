/* findkey.c - locate the secret key
 *	Copyright (C) 2001 Free Software Foundation, Inc.
 *
 * This file is part of GnuPG.
 *
 * GnuPG is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * GnuPG is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA
 */

#include <config.h>
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <assert.h>
#include <unistd.h>
#include <sys/stat.h>

#include "agent.h"

static int
unprotect (unsigned char **keybuf)
{
  struct pin_entry_info_s *pi;
  int rc;
  unsigned char *result;
  size_t resultlen;
  int tries = 0;

  /* fixme: check whether the key needs unprotection */

  pi = gcry_calloc_secure (1, sizeof (*pi) + 100);
  pi->max_length = 100;
  pi->min_digits = 0;  /* we want a real passphrase */
  pi->max_digits = 8;
  pi->max_tries = 3;

  do
    {
      rc = agent_askpin (NULL, NULL, pi);
      if (!rc)
        {
          rc = agent_unprotect (*keybuf, pi->pin, &result, &resultlen);
          if (!rc)
            {
              xfree (*keybuf);
              *keybuf = result;
              xfree (pi);
              return 0;
            }
        }
    }
  while ((rc == GNUPG_Bad_Passphrase || rc == GNUPG_Bad_PIN)
         && tries++ < 3);
  xfree (pi);
  return rc;
}



/* Return the secret key as an S-Exp after locating it using the grip.
   Returns NULL if key is not available. */
GCRY_SEXP
agent_key_from_file (const unsigned char *grip)
{
  int i, rc;
  char *fname;
  FILE *fp;
  struct stat st;
  unsigned char *buf;
  size_t len, buflen, erroff;
  GCRY_SEXP s_skey;
  char hexgrip[41];
  
  for (i=0; i < 20; i++)
    sprintf (hexgrip+2*i, "%02X", grip[i]);
  hexgrip[40] = 0;

  fname = make_filename (opt.homedir, "private-keys-v1.d", hexgrip, NULL );
  fp = fopen (fname, "rb");
  if (!fp)
    {
      log_error ("can't open `%s': %s\n", fname, strerror (errno));
      xfree (fname);
      return NULL;
    }
  
  if (fstat (fileno(fp), &st))
    {
      log_error ("can't stat `%s': %s\n", fname, strerror (errno));
      xfree (fname);
      fclose (fp);
      return NULL;
    }

  buflen = st.st_size;
  buf = xmalloc (buflen+1);
  if (fread (buf, buflen, 1, fp) != 1)
    {
      log_error ("error reading `%s': %s\n", fname, strerror (errno));
      xfree (fname);
      fclose (fp);
      xfree (buf);
      return NULL;
    }

  rc = gcry_sexp_sscan (&s_skey, &erroff, buf, buflen);
  xfree (fname);
  fclose (fp);
  xfree (buf);
  if (rc)
    {
      log_error ("failed to build S-Exp (off=%u): %s\n",
                 (unsigned int)erroff, gcry_strerror (rc));
      return NULL;
    }
  len = gcry_sexp_sprint (s_skey, GCRYSEXP_FMT_CANON, NULL, 0);
  assert (len);
  buf = xtrymalloc (len);
  if (!buf)
    {
      gcry_sexp_release (s_skey);
      return NULL;
    }
  len = gcry_sexp_sprint (s_skey, GCRYSEXP_FMT_CANON, buf, len);
  assert (len);
  gcry_sexp_release (s_skey);

  rc = unprotect (&buf);
  if (rc)
    {
      log_error ("failed to unprotect the secret key: %s\n",
                 gcry_strerror (rc));
      xfree (buf);
      return NULL;
    }

  /* arggg FIXME: does scna support secure memory? */
  rc = gcry_sexp_sscan (&s_skey, &erroff,
                        buf, gcry_sexp_canon_len (buf, 0, NULL, NULL));
  xfree (buf);
  if (rc)
    {
      log_error ("failed to build S-Exp (off=%u): %s\n",
                 (unsigned int)erroff, gcry_strerror (rc));
      return NULL;
    }

  return s_skey;
}

/* Return the secret key as an S-Exp after locating it using the grip.
   Returns NULL if key is not available. 0 = key is available */
int
agent_key_available (const unsigned char *grip)
{
  int i;
  char *fname;
  char hexgrip[41];
  
  for (i=0; i < 20; i++)
    sprintf (hexgrip+2*i, "%02X", grip[i]);
  hexgrip[40] = 0;

  fname = make_filename (opt.homedir, "private-keys-v1.d", hexgrip, NULL );
  i = !access (fname, R_OK)? 0 : -1;
  xfree (fname);
  return i;
}




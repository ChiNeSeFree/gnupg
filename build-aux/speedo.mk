# speedo.mk - Speedo rebuilds speedily.
# Copyright (C) 2008, 2014 g10 Code GmbH
#
# speedo is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# speedo is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, see <http://www.gnu.org/licenses/>.

# speedo builds gnupg-related packages from GIT and installs them in a
# user directory, thereby providing a non-obstrusive test environment.
# speedo does only work with GNU make.  The build system is similar to
# that of gpg4win.  The following commands are supported:
#
#   make -f speedo.mk all  pkg2rep=/dir/with/tarballs
# or
#   make -f speedo.mk
#
# Builds all packages and installs them under play/inst.  At the end,
# speedo prints commands that can be executed in the local shell to
# make use of the installed packages.
#
#   make -f speedo.mk clean
# or
#   make -f speedo.mk clean-PACKAGE
#
# Removes all packages or the package PACKAGE from the installation
# and build tree.  A subsequent make will rebuild these (and only
# these) packages.
#
#   make -f speedo.mk report
# or
#   make -f speedo.mk report-PACKAGE
#
# Lists packages and versions.
#

# We need to know our own name.
SPEEDO_MK := $(realpath $(lastword $(MAKEFILE_LIST)))


# Set this to "git" or "release".
WHAT=git

# Set target to "native" or "w32"
TARGETOS=w32

# Set to the location of the directory with traballs of
# external packages.
TARBALLS=$(shell pwd)/../tarballs

#  Number of parallel make jobs
MAKE_J=3

# =====BEGIN LIST OF PACKAGES=====
# The packages that should be built.  The order is also the build order.
# Fixme: Do we need to build pkg-config for cross-building?

speedo_spkgs  = \
	libgpg-error npth libgcrypt

ifeq ($(TARGETOS),w32)
speedo_spkgs += \
	zlib libiconv gettext
endif

speedo_spkgs += \
	libassuan libksba gnupg

ifeq ($(TARGETOS),w32)
speedo_spkgs += \
	libffi glib pkg-config
endif

speedo_spkgs += \
	gpgme

ifeq ($(TARGETOS),w32)
speedo_spkgs += \
	libpng \
	gdk-pixbuf atk pixman cairo pango gtk+
endif

speedo_spkgs += \
	pinentry gpa

ifeq ($(TARGETOS),w32)
speedo_spkgs += \
	gpgex
endif

# =====END LIST OF PACKAGES=====


# Packages which are additionally build for 64 bit Windows
speedo_w64_spkgs  = \
	libgpg-error libiconv gettext libassuan gpgex

# Packages which use the gnupg autogen.sh build style
speedo_gnupg_style = \
	libgpg-error npth libgcrypt  \
	libassuan libksba gnupg gpgme \
	pinentry gpa gpgex

# Packages which use only make and no build directory
speedo_make_only_style = \
	zlib

# Version numbers of the released packages
# Fixme: Take the version numbers from gnupg-doc/web/swdb.mac
libgpg_error_ver = 1.13
npth_ver = 0.91
libgcrypt_ver = 1.6.1
libassuan_ver = 2.1.1
libksba_ver = 1.3.0
gpgme_ver = 1.5.0
pinentry_ver = 0.8.4
gpa_ver = 0.9.5
gpgex_ver = 1.0.0


# Version number for external packages
pkg_config_ver = 0.23
zlib_ver = 1.2.8
libiconv_ver = 1.14
gettext_ver = 0.18.2.1
libffi_ver = 3.0.13
glib_ver = 2.34.3
libpng_ver = 1.4.12
gdk_pixbuf_ver = 2.26.5
atk_ver = 1.32.0
pango_ver = 1.29.4
pixman_ver = 0.32.4
cairo_ver = 1.12.16
gtk__ver = 2.24.17


# The GIT repository.  Using a local repo is much faster.
#gitrep = git://git.gnupg.org
gitrep = ${HOME}/s

# The tarball directories
pkgrep = ftp://ftp.gnupg.org/gcrypt
pkg2rep = $(TARBALLS)

# For each package, the following variables can be defined:
#
# speedo_pkg_PACKAGE_git: The GIT repository that should be built.
# speedo_pkg_PACKAGE_gitref: The GIT revision to checkout
#
# speedo_pkg_PACKAGE_tar: URL to the tar file that should be built.
#
# Exactly one of the above variables is required.  Note that this
# version of speedo does not cache repositories or tar files, and does
# not test the integrity of the downloaded software.  If you care
# about this, you can also specify filenames to locally verified files.
# Filenames are differentiated from URLs by starting with a slash '/'.
#
# speedo_pkg_PACKAGE_configure: Extra arguments to configure.
#
# speedo_pkg_PACKAGE_make_args: Extra arguments to make.
#
# speedo_pkg_PACKAGE_make_args_inst: Extra arguments to make install.
#
# Note that you can override the defaults in this file in a local file
# "config.mk"

ifeq ($(WHAT),git)
  speedo_pkg_libgpg_error_git = $(gitrep)/libgpg-error
  speedo_pkg_libgpg_error_gitref = master
  speedo_pkg_npth_git = $(gitrep)/npth
  speedo_pkg_npth_gitref = master
  speedo_pkg_libassuan_git = $(gitrep)/libassuan
  speedo_pkg_libassuan_gitref = master
  speedo_pkg_libgcrypt_git = $(gitrep)/libgcrypt
  speedo_pkg_libgcrypt_gitref = LIBGCRYPT-1-6-BRANCH
  speedo_pkg_libksba_git = $(gitrep)/libksba
  speedo_pkg_libksba_gitref = master
  speedo_pkg_gpgme_git = $(gitrep)/gpgme
  speedo_pkg_gpgme_gitref = master
  speedo_pkg_pinentry_git = $(gitrep)/pinentry
  speedo_pkg_pinentry_gitref = master
  speedo_pkg_gpa_git = $(gitrep)/gpa
  speedo_pkg_gpa_gitref = master
  speedo_pkg_gpgex_git = $(gitrep)/gpgex
  speedo_pkg_gpgex_gitref = master
else
  speedo_pkg_libgpg_error_tar = \
	$(pkgrep)/libgpg-error/libgpg-error-$(libgpg_error_ver).tar.bz2
  speedo_pkg_npth_tar = \
	$(pkgrep)/npth/npth-$(npth_ver).tar.bz2
  speedo_pkg_libassuan_tar = \
	$(pkgrep)/libassuan/libassuan-$(libassuan_ver).tar.bz2
  speedo_pkg_libgcrypt_tar = \
	$(pkgrep)/libgcrypt/libgcrypt-$(libgcrypt_ver).tar.bz2
  speedo_pkg_libksba_tar = \
	$(pkgrep)/libksba/libksba-$(libksba_ver).tar.bz2
  speedo_pkg_gpgme_tar = \
	$(pkgrep)/gpgme/gpgme-$(gpgme_ver).tar.bz2
  speedo_pkg_pinentry_tar = \
	$(pkgrep)/pinentry/pinentry-$(pinentry_ver).tar.bz2
  speedo_pkg_gpa_tar = \
	$(pkgrep)/gpa/gpa-$(gpa_ver).tar.bz2
  speedo_pkg_gpgex_tar = \
	$(pkgrep)/gpex/gpgex-$(gpa_ver).tar.bz2
endif

speedo_pkg_pkg_config_tar = $(pkg2rep)/pkg-config-$(pkg_config_ver).tar.gz
speedo_pkg_zlib_tar       = $(pkg2rep)/zlib-$(zlib_ver).tar.gz
speedo_pkg_libiconv_tar   = $(pkg2rep)/libiconv-$(libiconv_ver).tar.gz
speedo_pkg_gettext_tar    = $(pkg2rep)/gettext-$(gettext_ver).tar.gz
speedo_pkg_libffi_tar     = $(pkg2rep)/libffi-$(libffi_ver).tar.gz
speedo_pkg_glib_tar       = $(pkg2rep)/glib-$(glib_ver).tar.xz
speedo_pkg_libpng_tar     = $(pkg2rep)/libpng-$(libpng_ver).tar.bz2
speedo_pkg_gdk_pixbuf_tar = $(pkg2rep)/gdk-pixbuf-$(gdk_pixbuf_ver).tar.xz
speedo_pkg_atk_tar        = $(pkg2rep)/atk-$(atk_ver).tar.bz2
speedo_pkg_pango_tar      = $(pkg2rep)/pango-$(pango_ver).tar.bz2
speedo_pkg_pixman_tar     = $(pkg2rep)/pixman-$(pixman_ver).tar.gz
speedo_pkg_cairo_tar      = $(pkg2rep)/cairo-$(cairo_ver).tar.xz
speedo_pkg_gtk__tar       = $(pkg2rep)/gtk+-$(gtk__ver).tar.xz


#
# Package build options
#

speedo_pkg_libgpg_error_configure = --enable-static
speedo_pkg_w64_libgpg_error_configure = --enable-static

speedo_pkg_libassuan_configure = --enable-static
speedo_pkg_w64_libassuan_configure = --enable-static

speedo_pkg_libgcrypt_configure = --disable-static

speedo_pkg_libksba_configure = --disable-static

speedo_pkg_gnupg_configure = --enable-gpg2-is-gpg --disable-g13
speedo_pkg_gnupg_extracflags = -g

define speedo_pkg_gnupg_post_install
(set -e; \
 sed -n  's/.*PACKAGE_VERSION "\(.*\)"/\1/p' config.h >$(idir)/INST_VERSION; \
 sed -n  's/.*W32INFO_VI_PRODUCTVERSION \(.*\)/\1/p' common/w32info-rc.h \
    |sed 's/,/./g' >$(idir)/INST_PROD_VERSION )
endef


# The LDFLAGS is needed for -lintl for glib.
speedo_pkg_gpgme_configure = \
	--enable-static --enable-w32-glib --disable-w32-qt \
	--with-gpg-error-prefix=$(idir) \
	LDFLAGS=-L$(idir)/lib

speedo_pkg_pinentry_configure = \
	--disable-pinentry-qt --disable-pinentry-qt4 --disable-pinentry-gtk \
	--enable-pinentry-gtk2 \
	--with-glib-prefix=$(idir) --with-gtk-prefix=$(idir) \
	CPPFLAGS=-I$(idir)/include   \
	LDFLAGS=-L$(idir)/lib        \
	CXXFLAGS=-static-libstdc++

speedo_pkg_gpa_configure = \
        --with-libiconv-prefix=$(idir) --with-libintl-prefix=$(idir) \
        --with-gpgme-prefix=$(idir) --with-zlib=$(idir) \
        --with-libassuan-prefix=$(idir) --with-gpg-error-prefix=$(idir)

speedo_pkg_gpgex_configure = \
	--with-gpg-error-prefix=$(idir) \
	--with-libassuan-prefix=$(idir)

speedo_pkg_w64_gpgex_configure = \
	--with-gpg-error-prefix=$(idir6) \
	--with-libassuan-prefix=$(idir6)


#
# External packages
#

speedo_pkg_zlib_make_args = \
        -fwin32/Makefile.gcc PREFIX=$(host)- IMPLIB=libz.dll.a

speedo_pkg_zlib_make_args_inst = \
        -fwin32/Makefile.gcc \
        BINARY_PATH=$(idir)/bin INCLUDE_PATH=$(idir)/include \
	LIBRARY_PATH=$(idir)/lib SHARED_MODE=1 IMPLIB=libz.dll.a

# Zlib needs some special magic to generate a libtool file.
# We also install the pc file here.
define speedo_pkg_zlib_post_install
(set -e; mkdir $(idir)/lib/pkgconfig || true;	        \
cp $(auxsrc)/zlib.pc $(idir)/lib/pkgconfig/; 	        \
cd $(idir);						\
echo "# Generated by libtool" > lib/libz.la		\
echo "dlname='../bin/zlib1.dll'" >> lib/libz.la;	\
echo "library_names='libz.dll.a'" >> lib/libz.la;	\
echo "old_library='libz.a'" >> lib/libz.la;		\
echo "dependency_libs=''" >> lib/libz.la;		\
echo "current=1" >> lib/libz.la;			\
echo "age=2" >> lib/libz.la;				\
echo "revision=5" >> lib/libz.la;			\
echo "installed=yes" >> lib/libz.la;			\
echo "shouldnotlink=no" >> lib/libz.la;			\
echo "dlopen=''" >> lib/libz.la;			\
echo "dlpreopen=''" >> lib/libz.la;			\
echo "libdir=\"$(idir)/lib\"" >> lib/libz.la)
endef

speedo_pkg_w64_libiconv_configure = \
	--enable-shared=no --enable-static=yes

speedo_pkg_gettext_configure = \
	--with-lib-prefix=$(idir) --with-libiconv-prefix=$(idir) \
        CPPFLAGS=-I$(idir)/include LDFLAGS=-L$(idir)/lib
speedo_pkg_w64_gettext_configure = \
	--with-lib-prefix=$(idir) --with-libiconv-prefix=$(idir) \
        CPPFLAGS=-I$(idir6)/include LDFLAGS=-L$(idir6)/lib
speedo_pkg_gettext_extracflags = -O2
# We only need gettext-runtime and there is sadly no top level
# configure option for this
speedo_pkg_gettext_make_dir = gettext-runtime


speedo_pkg_glib_configure = \
	--disable-modular-tests \
	--with-lib-prefix=$(idir) --with-libiconv-prefix=$(idir) \
	CPPFLAGS=-I$(idir)/include \
	LDFLAGS=-L$(idir)/lib \
	CCC=$(host)-g++ \
        LIBFFI_CFLAGS=-I$(idir)/lib/libffi-$(libffi_ver)/include \
	LIBFFI_LIBS=\"-L$(idir)/lib -lffi\"
speedo_pkg_glib_extracflags = -march=i486


speedo_pkg_libpng_configure = \
	CPPFLAGS=\"-I$(idir)/include -DPNG_BUILD_DLL\" \
	LDFLAGS=\"-L$(idir)/lib\" LIBPNG_DEFINES=\"-DPNG_BUILD_DLL\"

speedo_pkg_pixman_configure = \
	CPPFLAGS=-I$(idir)/include \
	LDFLAGS=-L$(idir)/lib

speedo_pkg_cairo_configure = \
	--disable-qt --disable-ft --disable-fc \
	--enable-win32 --enable-win32-font \
	CPPFLAGS=-I$(idir)/include \
	LDFLAGS=-L$(idir)/lib

speedo_pkg_pango_configure = \
	--disable-gtk-doc  \
	CPPFLAGS=-I$(idir)/include \
	LDFLAGS=-L$(idir)/lib

speedo_pkg_gtk__configure = \
	--disable-cups \
	CPPFLAGS=-I$(idir)/include \
	LDFLAGS=-L$(idir)/lib


# ---------

all: all-speedo

report: report-speedo

clean: clean-speedo

ifeq ($(TARGETOS),w32)
STRIP = i686-w64-mingw32-strip
else
STRIP = strip
endif
W32CC = i686-w64-mingw32-gcc

-include config.mk

#
#  The generic speedo code
#

MKDIR=mkdir
MAKENSIS=makensis
BUILD_ISODATE=$(shell date -u +%Y-%m-%d)

# These paths must be absolute, as we switch directories pretty often.
root := $(shell pwd)/play
sdir := $(root)/src
bdir := $(root)/build
bdir6:= $(root)/build-w64
idir := $(root)/inst
idir6:= $(root)/inst-w64
stampdir := $(root)/stamps
topsrc := $(shell cd $(dir $(SPEEDO_MK)).. && pwd)
auxsrc := $(topsrc)/build-aux/speedo
patdir := $(topsrc)/build-aux/speedo/patches
w32src := $(topsrc)/build-aux/speedo/w32

# The next two macros will work only after gnupg has been build.
INST_VERSION=$(shell head -1 $(idir)/INST_VERSION)
INST_PROD_VERSION=$(shell head -1 $(idir)/INST_PROD_VERSION)

# List with packages
speedo_build_list = $(speedo_spkgs)
speedo_w64_build_list = $(speedo_w64_spkgs)

# Determine build and host system
build := $(shell $(topsrc)/autogen.sh --silent --print-build)
ifeq ($(TARGETOS),w32)
  speedo_autogen_buildopt := --build-w32
  speedo_autogen_buildopt6 := --build-w64
  host := $(shell $(topsrc)/autogen.sh --silent --print-host --build-w32)
  host6:= $(shell $(topsrc)/autogen.sh --silent --print-host --build-w64)
  speedo_host_build_option := --host=$(host) --build=$(build)
  speedo_host_build_option6 := --host=$(host6) --build=$(build)
  speedo_w32_cflags := -mms-bitfields
else
  speedo_autogen_buildopt :=
  host :=
  speedo_host_build_option :=
  speedo_w32_cflags :=
endif

ifeq ($(MAKE_J),)
  speedo_makeopt=
else
  speedo_makeopt=-j$(MAKE_J)
endif




# The playground area is our scratch area, where we unpack, build and
# install the packages.
$(stampdir)/stamp-directories:
	$(MKDIR) $(root) || true
	$(MKDIR) $(stampdir) || true
	$(MKDIR) $(sdir)  || true
	$(MKDIR) $(bdir)  || true
	$(MKDIR) $(idir)   || true
ifeq ($(TARGETOS),w32)
	$(MKDIR) $(bdir6)  || true
	$(MKDIR) $(idir6)   || true
endif
	touch $(stampdir)/stamp-directories

# Frob the name $1 by converting all '-' and '+' characters to '_'.
define FROB_macro
$(subst +,_,$(subst -,_,$(1)))
endef

# Get the variable $(1) (which may contain '-' and '+' characters).
define GETVAR
$($(call FROB_macro,$(1)))
endef

# Set a couple of common variables.
define SETVARS
	pkg="$(1)";							\
	git="$(call GETVAR,speedo_pkg_$(1)_git)";			\
	gitref="$(call GETVAR,speedo_pkg_$(1)_gitref)";			\
	tar="$(call GETVAR,speedo_pkg_$(1)_tar)";			\
	pkgsdir="$(sdir)/$(1)";						\
	if [ "$(1)" = "gnupg" ]; then                                   \
	  git='';                                                       \
	  gitref='';                                                    \
	  tar='';                                                       \
          pkgsdir="$(topsrc)";                                          \
        fi;                                                             \
	pkgbdir="$(bdir)/$(1)";	                    			\
	pkgcfg="$(call GETVAR,speedo_pkg_$(1)_configure)";		\
	pkgextracflags="$(call GETVAR,speedo_pkg_$(1)_extracflags)";	\
	pkgmkdir="$(call GETVAR,speedo_pkg_$(1)_make_dir)";             \
	pkgmkargs="$(call GETVAR,speedo_pkg_$(1)_make_args)";           \
	pkgmkargs_inst="$(call GETVAR,speedo_pkg_$(1)_make_args_inst)"; \
	export PKG_CONFIG="/usr/bin/pkg-config";			\
	export PKG_CONFIG_PATH="$(idir)/lib/pkgconfig";			\
	export PKG_CONFIG_LIBDIR="";					\
	export SYSROOT="$(idir)";					\
	export PATH="$(idir)/bin:$${PATH}";				\
	export LD_LIBRARY_PATH="$(idir)/lib:$${LD_LIBRARY_PATH}"
endef

define SETVARS_W64
	pkg="$(1)";							\
	git="$(call GETVAR,speedo_pkg_$(1)_git)";			\
	gitref="$(call GETVAR,speedo_pkg_$(1)_gitref)";			\
	tar="$(call GETVAR,speedo_pkg_$(1)_tar)";			\
	pkgsdir="$(sdir)/$(1)";						\
	if [ "$(1)" = "gnupg" ]; then                                   \
	  git='';                                                       \
	  gitref='';                                                    \
	  tar='';                                                       \
          pkgsdir="$(topsrc)";                                          \
        fi;                                                             \
	pkgbdir="$(bdir6)/$(1)";                  			\
	pkgcfg="$(call GETVAR,speedo_pkg_w64_$(1)_configure)";		\
	pkgextracflags="$(call GETVAR,speedo_pkg_$(1)_extracflags)";	\
	pkgmkdir="$(call GETVAR,speedo_pkg_$(1)_make_dir)";             \
	pkgmkargs="$(call GETVAR,speedo_pkg_$(1)_make_args)";           \
	pkgmkargs_inst="$(call GETVAR,speedo_pkg_$(1)_make_args_inst)"; \
	export PKG_CONFIG="/usr/bin/pkg-config";			\
	export PKG_CONFIG_PATH="$(idir6)/lib/pkgconfig";		\
	export PKG_CONFIG_LIBDIR="";					\
	export SYSROOT="$(idir6)";					\
	export PATH="$(idir6)/bin:$${PATH}";				\
	export LD_LIBRARY_PATH="$(idir6)/lib:$${LD_LIBRARY_PATH}"
endef


# Template for source packages.
#
# Note that the gnupg package is special: The package source dir is
# the same as the topsrc dir and thus we need to detect the gnupg
# package and cd to that directory.  We also test that no in-source build
# has been done.  autogen.sh is not run for gnupg.
#
define SPKG_template

$(stampdir)/stamp-$(1)-00-unpack: $(stampdir)/stamp-directories
	@echo "speedo: /*"
	@echo "speedo:  *   $(1)"
	@echo "speedo:  */"
	@(set -e; cd $(sdir);				\
	 $(call SETVARS,$(1)); 				\
	 if [ "$(1)" = "gnupg" ]; then                  \
	   cd $$$${pkgsdir};                            \
           if [ -f config.log ]; then                   \
             echo "GnuPG has already been build in-source" >&2  ;\
	     echo "Please run \"make distclean\" and retry" >&2 ;\
	     exit 1 ;	                         	\
           fi;                                          \
	   echo "speedo: unpacking gnupg not needed";   \
	 elif [ -n "$$$${git}" ]; then			\
	   echo "speedo: unpacking $(1) from $$$${git}:$$$${gitref}"; \
           git clone -b "$$$${gitref}" "$$$${git}" "$$$${pkg}"; \
	   cd "$$$${pkg}"; 				\
	   AUTOGEN_SH_SILENT=1 ./autogen.sh;            \
         elif [ -n "$$$${tar}" ]; then			\
	   echo "speedo: unpacking $(1) from $$$${tar}"; \
           case "$$$${tar}" in				\
             *.gz) opt=z ;;				\
             *.bz2) opt=j ;;				\
	     *.xz) opt=J ;;                      	\
             *) opt= ;;					\
           esac;					\
           case "$$$${tar}" in				\
	     /*) cmd=cat ;;				\
	     *) cmd="wget -q -O -" ;;			\
	   esac;					\
	   $$$${cmd} "$$$${tar}" | tar x$$$${opt}f - ;	\
	   base=`echo "$$$${tar}" | sed -e 's,^.*/,,'   \
                 | sed -e 's,\.tar.*$$$$,,'`;		\
	   mv $$$${base} $(1);				\
	   patch="$(patdir)/$(1)-$$$${base#$(1)-}.patch";\
	   if [ -x "$$$${patch}" ]; then  		\
             echo "speedo: applying patch $$$${patch}"; \
             cd $(1); "$$$${patch}"; 	 		\
	   elif [ -f "$$$${patch}" ]; then  		\
             echo "speedo: warning: $$$${patch} is not executable"; \
	   fi;						\
	 else                                           \
	   echo "speedo: unpacking $(1) from UNKNOWN";  \
	 fi)
	@touch $(stampdir)/stamp-$(1)-00-unpack

$(stampdir)/stamp-$(1)-01-configure: $(stampdir)/stamp-$(1)-00-unpack
	@echo "speedo: configuring $(1)"
ifneq ($(findstring $(1),$(speedo_make_only_style)),)
	@echo "speedo: configure run not required"
else ifneq ($(findstring $(1),$(speedo_gnupg_style)),)
	@($(call SETVARS,$(1));				\
	 mkdir "$$$${pkgbdir}";				\
	 cd "$$$${pkgbdir}";		        	\
         if [ -n "$(speedo_autogen_buildopt)" ]; then   \
            eval AUTOGEN_SH_SILENT=1 w32root="$(idir)"  \
               "$$$${pkgsdir}/autogen.sh"               \
               $(speedo_autogen_buildopt)            	\
               $$$${pkgcfg}                         	\
               CFLAGS=\"$(speedo_w32_cflags) $$$${pkgextracflags}\";\
         else                                        	\
            eval "$$$${pkgsdir}/configure" 		\
	       --silent                 		\
	       --enable-maintainer-mode			\
               --prefix="$(idir)"		        \
               $$$${pkgcfg}                         	\
               CFLAGS=\"$(speedo_w32_cflags) $$$${pkgextracflags}\";\
	 fi)
else
	@($(call SETVARS,$(1)); 			\
	 mkdir "$$$${pkgbdir}";				\
	 cd "$$$${pkgbdir}";		        	\
	 eval "$$$${pkgsdir}/configure" 		\
	     --silent $(speedo_host_build_option)	\
             --prefix="$(idir)"		        	\
	     $$$${pkgcfg}                          	\
             CFLAGS=\"$(speedo_w32_cflags) $$$${pkgextracflags}\";\
	 )
endif
	@touch $(stampdir)/stamp-$(1)-01-configure

# Note that unpack has no 64 bit version becuase it is just the source.
# Fixme: We should use templates to create the standard and w64
# version of these rules.
$(stampdir)/stamp-w64-$(1)-01-configure: $(stampdir)/stamp-$(1)-00-unpack
	@echo "speedo: configuring $(1) (64 bit)"
ifneq ($(findstring $(1),$(speedo_make_only_style)),)
	@echo "speedo: configure run not required"
else ifneq ($(findstring $(1),$(speedo_gnupg_style)),)
	@($(call SETVARS_W64,$(1));			\
	 mkdir "$$$${pkgbdir}";				\
	 cd "$$$${pkgbdir}";		        	\
         if [ -n "$(speedo_autogen_buildopt)" ]; then   \
            eval AUTOGEN_SH_SILENT=1 w64root="$(idir6)" \
               "$$$${pkgsdir}/autogen.sh"               \
               $(speedo_autogen_buildopt6)            	\
               $$$${pkgcfg}                         	\
               CFLAGS=\"$(speedo_w32_cflags) $$$${pkgextracflags}\";\
         else                                        	\
            eval "$$$${pkgsdir}/configure" 		\
	       --silent                 		\
	       --enable-maintainer-mode			\
               --prefix="$(idir6)"		        \
               $$$${pkgcfg}                         	\
               CFLAGS=\"$(speedo_w32_cflags) $$$${pkgextracflags}\";\
	 fi)
else
	@($(call SETVARS_W64,$(1)); 			\
	 mkdir "$$$${pkgbdir}";				\
	 cd "$$$${pkgbdir}";		        	\
	 eval "$$$${pkgsdir}/configure" 		\
	     --silent $(speedo_host_build_option6)	\
             --prefix="$(idir6)"	        	\
	     $$$${pkgcfg}                          	\
             CFLAGS=\"$(speedo_w32_cflags) $$$${pkgextracflags}\";\
	 )
endif
	@touch $(stampdir)/stamp-w64-$(1)-01-configure


$(stampdir)/stamp-$(1)-02-make: $(stampdir)/stamp-$(1)-01-configure
	@echo "speedo: making $(1)"
ifneq ($(findstring $(1),$(speedo_make_only_style)),)
	@($(call SETVARS,$(1));				\
          cd "$$$${pkgsdir}";				\
	  test -n "$$$${pkgmkdir}" && cd "$$$${pkgmkdir}"; \
	  $(MAKE) --no-print-directory $(speedo_makeopt) $$$${pkgmkargs} V=0)
else
	@($(call SETVARS,$(1));				\
          cd "$$$${pkgbdir}";				\
	  test -n "$$$${pkgmkdir}" && cd "$$$${pkgmkdir}"; \
	  $(MAKE) --no-print-directory $(speedo_makeopt) $$$${pkgmkargs} V=1)
endif
	@touch $(stampdir)/stamp-$(1)-02-make

$(stampdir)/stamp-w64-$(1)-02-make: $(stampdir)/stamp-w64-$(1)-01-configure
	@echo "speedo: making $(1) (64 bit)"
ifneq ($(findstring $(1),$(speedo_make_only_style)),)
	@($(call SETVARS_W64,$(1));				\
          cd "$$$${pkgsdir}";				\
	  test -n "$$$${pkgmkdir}" && cd "$$$${pkgmkdir}"; \
	  $(MAKE) --no-print-directory $(speedo_makeopt) $$$${pkgmkargs} V=0)
else
	@($(call SETVARS_W64,$(1));				\
          cd "$$$${pkgbdir}";				\
	  test -n "$$$${pkgmkdir}" && cd "$$$${pkgmkdir}"; \
	  $(MAKE) --no-print-directory $(speedo_makeopt) $$$${pkgmkargs} V=1)
endif
	@touch $(stampdir)/stamp-w64-$(1)-02-make

# Note that post_install must come last because it may be empty and
# "; ;" is a syntax error.
$(stampdir)/stamp-$(1)-03-install: $(stampdir)/stamp-$(1)-02-make
	@echo "speedo: installing $(1)"
ifneq ($(findstring $(1),$(speedo_make_only_style)),)
	@($(call SETVARS,$(1));				\
          cd "$$$${pkgsdir}";				\
	  test -n "$$$${pkgmkdir}" && cd "$$$${pkgmkdir}"; \
	  $(MAKE) --no-print-directory $$$${pkgmkargs_inst} install V=1;\
	  $(call speedo_pkg_$(call FROB_macro,$(1))_post_install))
else
	@($(call SETVARS,$(1));				\
          cd "$$$${pkgbdir}";				\
	  test -n "$$$${pkgmkdir}" && cd "$$$${pkgmkdir}"; \
	  $(MAKE) --no-print-directory $$$${pkgmkargs_inst} install-strip V=0;\
	  $(call speedo_pkg_$(call FROB_macro,$(1))_post_install))
endif
	touch $(stampdir)/stamp-$(1)-03-install

$(stampdir)/stamp-w64-$(1)-03-install: $(stampdir)/stamp-w64-$(1)-02-make
	@echo "speedo: installing $(1) (64 bit)"
ifneq ($(findstring $(1),$(speedo_make_only_style)),)
	@($(call SETVARS_W64,$(1));				\
          cd "$$$${pkgsdir}";				\
	  test -n "$$$${pkgmkdir}" && cd "$$$${pkgmkdir}"; \
	  $(MAKE) --no-print-directory $$$${pkgmkargs_inst} install V=1;\
	  $(call speedo_pkg_$(call FROB_macro,$(1))_post_install))
else
	@($(call SETVARS_W64,$(1));				\
          cd "$$$${pkgbdir}";				\
	  test -n "$$$${pkgmkdir}" && cd "$$$${pkgmkdir}"; \
	  $(MAKE) --no-print-directory $$$${pkgmkargs_inst} install-strip V=0;\
	  $(call speedo_pkg_$(call FROB_macro,$(1))_post_install))
endif
	touch $(stampdir)/stamp-w64-$(1)-03-install

$(stampdir)/stamp-final-$(1): $(stampdir)/stamp-$(1)-03-install
	@echo "speedo: $(1) done"
	@touch $(stampdir)/stamp-final-$(1)

$(stampdir)/stamp-w64-final-$(1): $(stampdir)/stamp-w64-$(1)-03-install
	@echo "speedo: $(1) (64 bit) done"
	@touch $(stampdir)/stamp-w64-final-$(1)

.PHONY : clean-$(1)
clean-$(1):
	@echo "speedo: uninstalling $(1)"
	@($(call SETVARS,$(1));				\
	 (cd "$$$${pkgbdir}" 2>/dev/null &&		\
	  $(MAKE) --no-print-directory                  \
           $$$${pkgmkargs_inst} uninstall V=0 ) || true;\
	 rm -fR "$$$${pkgsdir}" "$$$${pkgbdir}" || true)
	-rm -f $(stampdir)/stamp-final-$(1) $(stampdir)/stamp-$(1)-*


.PHONY : build-$(1)
build-$(1): $(stampdir)/stamp-final-$(1)


.PHONY : report-$(1)
report-$(1):
	@($(call SETVARS,$(1));				\
	 echo -n $(1):\  ;				\
	 if [ -n "$$$${git}" ]; then			\
           if [ -e "$$$${pkgsdir}/.git" ]; then		\
	     cd "$$$${pkgsdir}" &&			\
             git describe ;		                \
	   else						\
             echo missing;				\
	   fi						\
         elif [ -n "$$$${tar}" ]; then			\
	   base=`echo "$$$${tar}" | sed -e 's,^.*/,,'   \
                 | sed -e 's,\.tar.*$$$$,,'`;		\
	   echo $$$${base} ;				\
         fi)

endef


# Insert the template for each source package.
$(foreach spkg, $(speedo_spkgs), $(eval $(call SPKG_template,$(spkg))))

$(stampdir)/stamp-final: $(stampdir)/stamp-directories
ifeq ($(TARGETOS),w32)
$(stampdir)/stamp-final: $(addprefix $(stampdir)/stamp-w64-final-,$(speedo_w64_build_list))
endif
$(stampdir)/stamp-final: $(addprefix $(stampdir)/stamp-final-,$(speedo_build_list))
	touch $(stampdir)/stamp-final

all-speedo: $(stampdir)/stamp-final

report-speedo: $(addprefix report-,$(speedo_build_list))

# Just to check if we catched all stamps.
clean-stamps:
	$(RM) -fR $(stampdir)

clean-speedo:
	$(RM) -fR play


#
# Windows installer
#

dist-source: all
	for i in 00 01 02 03; do sleep 1;touch play/stamps/stamp-*-${i}-*;done
	tar -cvJf gnupg-$(INST_VERSION)_$(BUILD_ISODATE).tar.xz \
	    --exclude-backups --exclude-vc \
	    patches play/stamps/stamp-*-00-unpack play/src


$(bdir)/NEWS.tmp: $(topsrc)/NEWS
	sed -e '/^#/d' <$(topsrc)/NEWS >$(bdir)/NEWS.tmp

$(bdir)/README.txt: $(bdir)/NEWS.tmp $(w32src)/README.txt \
                    $(w32src)/pkg-copyright.txt
	sed -e '/^;.*/d;' \
	-e '/!NEWSFILE!/{r NEWS.tmp' -e 'd;}' \
        -e '/!PKG-COPYRIGHT!/{r $(w32src)/pkg-copyright.txt' -e 'd;}' \
        -e 's,!VERSION!,$(INST_VERSION),g' \
	   < $(w32src)/README.txt \
           | awk '{printf "%s\r\n", $$0}' >$(bdir)/README.txt

$(bdir)/g4wihelp.dll: $(w32src)/g4wihelp.c $(w32src)/exdll.h
	(set -e; cd $(bdir); \
	 $(W32CC) -I. -shared -O2 -o g4wihelp.dll $(w32src)/g4wihelp.c \
	          -lwinmm -lgdi32; \
	 $(STRIP) g4wihelp.dll)

w32_insthelpers: $(bdir)/g4wihelp.dll

$(bdir)/inst-options.ini: $(w32src)/inst-options.ini
	cat $(w32src)/inst-options.ini >$(bdir)/inst-options.ini

installer: all w32_insthelpers $(bdir)/inst-options.ini $(bdir)/README.txt
	$(MAKENSIS) -V2 \
                    -DINST_DIR=$(idir) \
                    -DINST6_DIR=$(idir6) \
                    -DBUILD_DIR=$(bdir) \
                    -DTOP_SRCDIR=$(topsrc) \
                    -DW32_SRCDIR=$(w32src) \
                    -DBUILD_ISODATE=$(BUILD_ISODATE) \
	            -DVERSION=$(INST_VERSION) \
		    -DPROD_VERSION=$(INST_PROD_VERSION) \
		    $(w32src)/inst.nsi

#
# Mark phony targets
#
.PHONY: all-speedo report-speedo clean-stamps clean-speedo installer \
	w32_insthelpers

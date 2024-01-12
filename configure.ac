dnl
dnl Configuration script for the CUPS sharing server.
dnl
dnl Copyright © 2022-2024 by OpenPrinting.
dnl
dnl Licensed under Apache License v2.0.  See the file "LICENSE" for more
dnl information.
dnl
dnl ***********************************************************************
dnl
dnl Note: Using autoheader or automake on this project will break the build
dnl system.  Use "autoconf -f" to regenerate the configure script if you
dnl make changes to this file.
dnl
dnl ***********************************************************************

dnl We need at least autoconf 2.70 for --runstatedir...
AC_PREREQ([2.70])


dnl Package name and version...
AC_INIT([cups_sharing], [3.0b1], [https://github.com/OpenPrinting/cups-sharing/issues], [cups-sharing], [https://openprinting.github.io/cups])
AC_CONFIG_HEADERS([config.h])

CUPS_SHARING_VERSION="AC_PACKAGE_VERSION"

AC_SUBST([CUPS_SHARING_VERSION])

AC_DEFINE_UNQUOTED([CUPS_SHARING_VERSION], ["$CUPS_SHARING_VERSION"], [Version number])


dnl This line is provided to ensure that you don't run the autoheader program
dnl against this project.  Doing so is completely unsupported and WILL cause
dnl problems!
AH_TOP([#error "Somebody ran autoheader on this project which is unsupported and WILL cause problems."])


dnl Get the build and host platforms and split the host_os value
AC_CANONICAL_BUILD
AC_CANONICAL_HOST

[host_os_name="$(echo $host_os | sed -e '1,$s/[0-9.]*$//g')"]
[host_os_version="$(echo $host_os | sed -e '1,$s/^[^0-9.]*//g' | awk -F. '{print $1 $2}')"]
# Linux often does not yield an OS version we can use...
AS_IF([test "x$host_os_version" = x], [
    host_os_version="0"
])


dnl Compiler options...
CFLAGS="${CFLAGS:=}"
CPPFLAGS="${CPPFLAGS:=}"
LDFLAGS="${LDFLAGS:=}"
LIBS="${LIBS:=}"
OPTIM="${OPTIM:=}"

AC_SUBST([OPTIM])


dnl Programs...
AC_PROG_CC
AC_PATH_PROGS([CODE_SIGN], [codesign true])
AC_PATH_PROG([MKDIR], [mkdir])
AC_PATH_PROG([RM], [rm])
AC_PATH_PROG([RMDIR], [rmdir])
AC_PATH_PROG([LN], [ln])


dnl install-sh
AC_MSG_CHECKING([for install-sh script])
INSTALL="$(pwd)/install-sh"
AC_SUBST([INSTALL])
AC_MSG_RESULT([using $INSTALL])


dnl Check for pkg-config, which is used for some other tests later on...
AC_PATH_TOOL([PKGCONFIG], [pkg-config])


dnl CUPS library v3
AC_MSG_CHECKING([for CUPS library v3])
AS_IF([$PKGCONFIG --exists cups3], [
    AC_MSG_RESULT(yes)
    CPPFLAGS="$CPPFLAGS $($PKGCONFIG --cflags cups3)"
    LIBS="$LIBS $($PKGCONFIG --libs cups3)"
], [
    AC_MSG_RESULT(no)
    AC_MSG_ERROR([Required CUPS library v3 is not present.])
])


dnl PAPPL library...
AC_MSG_CHECKING([for PAPPL library v2.0 or later])
AS_IF([$PKGCONFIG --exists pappl2 --atleast-version=2.0], [
    AC_MSG_RESULT([yes])
    CPPFLAGS="$CFLAGS $($PKGCONFIG --cflags pappl2)"
    LIBS="$($PKGCONFIG --libs pappl2) $LIBS"
], [
    AC_MSG_RESULT([no])
    $PKGCONFIG --debug --exists pappl2
    AC_MSG_ERROR([PAPPL v2.0 or later is required.])
])


dnl Extra compiler options...
AC_ARG_ENABLE([debug], AS_HELP_STRING([--enable-debug], [turn on debugging, default=no]))
AC_ARG_ENABLE([maintainer], AS_HELP_STRING([--enable-maintainer], [turn on maintainer mode, default=no]))
AC_ARG_ENABLE([sanitizer], AS_HELP_STRING([--enable-sanitizer], [build with AddressSanitizer, default=no]))

AS_IF([test x$enable_debug = xyes], [
    OPTIM="$OPTIM -g"
    CSFLAGS=""
], [
    OPTIM="$OPTIM -g -Os"
    CSFLAGS="-o runtime"
])

AC_SUBST([CSFLAGS])

WARNINGS=""
AC_SUBST([WARNINGS])

AS_IF([test -n "$GCC"], [
    AS_IF([test x$enable_sanitizer = xyes], [
	# Use -fsanitize=address with debugging...
	OPTIM="$OPTIM -fsanitize=address"
    ], [
	# Otherwise use the Fortify enhancements to catch any unbounded
	# string operations...
	CPPFLAGS="$CPPFLAGS -D_FORTIFY_SOURCE=2"
    ])

    dnl Show all standard warnings + unused variables when compiling...
    WARNINGS="-Wall -Wunused"

    dnl Drop some not-useful/unreliable warnings...
    for warning in char-subscripts format-truncation format-y2k switch unused-result; do
	AC_MSG_CHECKING([whether compiler supports -Wno-$warning])

	OLDCFLAGS="$CFLAGS"
	CFLAGS="$CFLAGS -Wno-$warning -Werror"

	AC_COMPILE_IFELSE([AC_LANG_PROGRAM()], [
	    AC_MSG_RESULT(yes)
	    WARNINGS="$WARNINGS -Wno-$warning"
        ], [
	    AC_MSG_RESULT(no)
	])

	CFLAGS="$OLDCFLAGS"
    done

    dnl Maintainer mode enables -Werror...
    AS_IF([test x$enable_maintainer = xyes], [
	WARNINGS="$WARNINGS -Werror"
    ])

    dnl See if PIE options are supported...
    AC_MSG_CHECKING(whether compiler supports -fPIE)
    OLDCFLAGS="$CFLAGS"
    AS_CASE(["$host_os_name"],
    [darwin*], [
	CFLAGS="$CFLAGS -fPIC -fPIE -Wl,-pie"
	AC_COMPILE_IFELSE([AC_LANG_PROGRAM([[]], [[]])],[
	    OLDCFLAGS="-fPIC $OLDCFLAGS"
	    LDFLAGS="-fPIE -Wl,-pie $LDFLAGS"
	    AC_MSG_RESULT(yes)
	],[
	    AC_MSG_RESULT(no)
	])
    ], [*], [
	CFLAGS="$CFLAGS -fPIC -fPIE -pie"
	AC_COMPILE_IFELSE([AC_LANG_PROGRAM([[]], [[]])],[
	    OLDCFLAGS="-fPIC $OLDCFLAGS"
	    LDFLAGS="-fPIE -pie $LDFLAGS"
	    AC_MSG_RESULT(yes)
	],[
	    AC_MSG_RESULT(no)
	])
    ])
    CFLAGS="$OLDCFLAGS"

    dnl OS-specific compiler options...
    AS_CASE(["$host_os_name"], [linux*], [
	CPPFLAGS="$CPPFLAGS -D__USE_MISC -D_GNU_SOURCE"
    ], [darwin*], [
        AS_IF([test "$host_os_version" -ge 200 -a x$enable_debug != xyes], [
            # macOS 11.0 and higher support the Apple Silicon (arm64) CPUs
	    OPTIM="$OPTIM -mmacosx-version-min=11.0 -arch x86_64 -arch arm64"
	], [test x$enable_debug != xyes], [
	    OPTIM="$OPTIM -mmacosx-version-min=11.0 -arch x86_64"
	])
    ])
])


dnl Extra linker options...
AC_ARG_WITH([ldflags], AS_HELP_STRING([--with-ldflags=...], [Specify additional LDFLAGS]), [
    LDFLAGS="$withval $LDFLAGS"
])

dnl State and run directories for root servers...
AS_IF([test "$prefix" = NONE], [
    # Default prefix isn't bound until AC_OUTPUT...
    realprefix="/usr/local"
], [
    realprefix="$prefix"
])

AS_IF([test "$datarootdir" = "\${prefix}/share"], [
    AS_IF([test "$prefix" = "/"], [
	datarootdir="/usr/share"
    ], [
	datarootdir="$realprefix/share"
    ])
])

AS_IF([test "$datadir" = "\${prefix}/share"], [
    AS_IF([test "$prefix" = "/"], [
	datadir="/usr/share"
    ], [
	datadir="$realprefix/share"
    ])
], [test "$datadir" = "\${datarootdir}"], [
    datadir="$datarootdir"
])


dnl Save the installed directory for localizations...
CUPS_SHARING_DATADIR="$datadir/cups-sharing"
AC_DEFINE_UNQUOTED([CUPS_SHARING_DATADIR], ["$datadir/cups-sharing"], [Location of data files.])
AC_SUBST([CUPS_SHARING_DATADIR])


dnl Generate a bunch of files...
AC_CONFIG_FILES([
    Makedefs
])
AC_OUTPUT

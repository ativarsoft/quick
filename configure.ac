#                                               -*- Autoconf -*-
# Process this file with autoconf to produce a configure script.

AC_PREREQ([2.69])
#AC_INIT([FULL-PACKAGE-NAME], [VERSION], [BUG-REPORT-ADDRESS])
AC_INIT([Quick],
    [0.1.0],
    [mateus@ativarsoft.com])
LT_INIT
AM_INIT_AUTOMAKE
AC_CONFIG_SRCDIR([money.c])
AC_CONFIG_HEADERS([config.h])
AC_CONFIG_MACRO_DIRS([m4])

# Checks for programs.
AC_PROG_CC
AC_PROG_CXX
AC_PROG_INSTALL
AC_PROG_RANLIB

# Checks for libraries.
# FIXME: Replace `main' with a function in `-lGeoIP':
AC_CHECK_LIB([GeoIP], [main])
# FIXME: Replace `main' with a function in `-lavcodec':
AC_CHECK_LIB([avcodec], [main])
# FIXME: Replace `main' with a function in `-lavformat':
AC_CHECK_LIB([avformat], [main])
# FIXME: Replace `main' with a function in `-lcsv':
AC_CHECK_LIB([csv], [main])
# FIXME: Replace `main' with a function in `-lical':
AC_CHECK_LIB([ical], [main])
# FIXME: Replace `main' with a function in `-ltemplatizer':
AC_CHECK_LIB([templatizer], [main])
# FIXME: Replace `main' with a function in `-ltesseract':
AC_CHECK_LIB([tesseract], [main])

# Checks for header files.
AC_CHECK_HEADERS([libintl.h locale.h netdb.h stddef.h stdlib.h string.h])

# Checks for typedefs, structures, and compiler characteristics.
AC_TYPE_SIZE_T
AC_TYPE_UINT32_T

# Checks for library functions.
AC_FUNC_MALLOC
AC_CHECK_FUNCS([gethostbyname memset setlocale strndup])

AC_CONFIG_FILES([Makefile])
AC_OUTPUT

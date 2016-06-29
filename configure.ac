# src/dbext/configure.ac
# Copyright (C) 2016 Long Range Systems, LLC.  All rights reserved.

AC_INIT([dbext], 1.0)
AC_CONFIG_SRCDIR([src/tracker_dbext.c])
AC_CANONICAL_SYSTEM

AM_INIT_AUTOMAKE
AM_CONFIG_HEADER([include/config.h])
AC_PROG_CC
AC_PROG_LIBTOOL

AC_CHECK_HEADER([b64/cdecode.h],,AC_MSG_ERROR([Can't find b64/cdecode.h]))
AC_CHECK_HEADER([uuid/uuid.h],,AC_MSG_ERROR([Can't find uuid/uuid.h]))

AC_CONFIG_FILES([
        Makefile
        src/Makefile
])
AC_OUTPUT

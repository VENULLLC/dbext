# src/dbext/src/Makefile.am
# Copyright (C) 2016 Long Range Systems, LLC.  All rights reserved.

lib_LTLIBRARIES = dbext.la

dbext_la_SOURCES = tracker_dbext.c
dbext_la_LDFLAGS = -Wl,-rpath,'$$ORIGIN' -module -avoid-version -lb64 -luuid

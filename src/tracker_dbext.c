/* src/dbext/src/tracker_dbext.c
 * Copyright (C) 2016 Long Range Systems, LLC.  All rights reserved.
 * SQLite 3 extension module for Tracker Gateway
 */

#include <stddef.h>
#include <stdio.h>
#include <string.h>

#include <sqlite3ext.h> /* Do not use <sqlite3.h>! */

#include <b64/cdecode.h>
#include <uuid/uuid.h>

SQLITE_EXTENSION_INIT1

/* Insert your extension code here */

static void _base64_to_uuid(sqlite3_context *, int, sqlite3_value **);
static void _eui64_to_digi(sqlite3_context *, int, sqlite3_value **);
static void _eui64_to_str(sqlite3_context *, int, sqlite3_value **);
static void _so_to_isodate(sqlite3_context *, int, sqlite3_value **);

#if !defined SQLITE_DETERMINISTIC
#  define SQLITE_DETERMINISTIC 0
#endif  /* !SQLITE_DETERMINISTIC */


#ifdef _WIN32
__declspec(dllexport)
#endif
/* TODO: Change the entry point name so that "extension" is replaced by
** text derived from the shared library filename as follows:  Copy every
** ASCII alphabetic character from the filename after the last "/" through
** the next following ".", converting each character to lowercase, and
** discarding the first three characters if they are "lib".
*/
int sqlite3_dbext_init(
    sqlite3 *db,
    char **pzErrMsg,
    const sqlite3_api_routines *pApi)
{
    int rc = SQLITE_OK;
    SQLITE_EXTENSION_INIT2(pApi);
    /* Insert here calls to
    **     sqlite3_create_function_v2(),
    **     sqlite3_create_collation_v2(),
    **     sqlite3_create_module_v2(), and/or
    **     sqlite3_vfs_register()
    ** to register the new features that your extension adds.
    */
    sqlite3_create_function_v2(
        db,
        "base64_to_uuid",       /* function name */
        1,                      /* number of parameters */
        SQLITE_UTF8 | SQLITE_DETERMINISTIC,
        NULL,                   /* user data */
        _base64_to_uuid,        /* scalar function */
        NULL,                   /* step function */
        NULL,                   /* finalize function */
        NULL);                  /* destructor */

    sqlite3_create_function_v2(
        db,
        "eui64_to_digi",        /* function name */
        1,                      /* number of parameters */
        SQLITE_UTF8 | SQLITE_DETERMINISTIC,
        NULL,                   /* user data */
        _eui64_to_digi,         /* scalar function */
        NULL,                   /* step function */
        NULL,                   /* finalize function */
        NULL);                  /* destructor */

    sqlite3_create_function_v2(
        db,
        "eui64_to_str",         /* function name */
        1,                      /* number of parameters */
        SQLITE_UTF8 | SQLITE_DETERMINISTIC,
        NULL,                   /* user data */
        _eui64_to_str,          /* scalar function */
        NULL,                   /* step function */
        NULL,                   /* finalize function */
        NULL);                  /* destructor */

    sqlite3_create_function_v2(
        db,
        "so_to_isodate",        /* function name */
        1,                      /* number of parameters */
        SQLITE_UTF8 | SQLITE_DETERMINISTIC,
        NULL,                   /* user data */
        _so_to_isodate,         /* scalar function */
        NULL,                   /* step function */
        NULL,                   /* finalize function */
        NULL);                  /* destructor */
    return rc;
}


void _base64_to_uuid(
   sqlite3_context *ctx,
   int argc,
   sqlite3_value **argv)
{
    char uuid_bin[80];
    char uuid_str[40];
    int uuid_bin_len;
    base64_decodestate b64_state;

    const char *uuid_b64 = (const char *)sqlite3_value_text(argv[0]);
    base64_init_decodestate(&b64_state);
    uuid_bin_len = base64_decode_block(
        uuid_b64,
        strnlen(uuid_b64, 80),
        uuid_bin,
        &b64_state);
    uuid_unparse_lower(uuid_bin, uuid_str);

    sqlite3_result_text(ctx, uuid_str, -1, SQLITE_TRANSIENT);
}

void _so_to_isodate(
    sqlite3_context *ctx,
    int argc,
    sqlite3_value **argv)
{
    char s[32];

    if (sqlite3_value_type(argv[0]) == SQLITE_TEXT) {
        strncpy(s, (const char *)sqlite3_value_text(argv[0]), sizeof(s));
        s[sizeof(s) - 1] = '\0';
        s[10] = 'T';
        sqlite3_result_text(ctx, s, -1, SQLITE_TRANSIENT);
    } else {
        sqlite3_result_null(ctx);
    }
}

void _eui64_to_digi(
    sqlite3_context *ctx,
    int argc,
    sqlite3_value **argv)
{
    sqlite3_int64 eui64;
    char buf[32];

    eui64 = sqlite3_value_int64(argv[0]);
    sprintf(
        buf,
        "[%02x:%02x:%02x:%02x:%02x:%02x:%02x:%02x]!",
        ((int)(eui64 >> 56)) & 0xff,
        ((int)(eui64 >> 48)) & 0xff,
        ((int)(eui64 >> 40)) & 0xff,
        ((int)(eui64 >> 32)) & 0xff,
        ((int)(eui64 >> 24)) & 0xff,
        ((int)(eui64 >> 16)) & 0xff,
        ((int)(eui64 >> 8)) & 0xff,
        (int)eui64 & 0xff);

    sqlite3_result_text(ctx, buf, -1, SQLITE_TRANSIENT);
}

void _eui64_to_str(
    sqlite3_context *ctx,
    int argc,
    sqlite3_value **argv)
{
    sqlite3_int64 eui64;
    char buf[32];

    eui64 = sqlite3_value_int64(argv[0]);
    sprintf(
        buf,
        "%02x:%02x:%02x:%02x:%02x:%02x:%02x:%02x",
        ((int)(eui64 >> 56)) & 0xff,
        ((int)(eui64 >> 48)) & 0xff,
        ((int)(eui64 >> 40)) & 0xff,
        ((int)(eui64 >> 32)) & 0xff,
        ((int)(eui64 >> 24)) & 0xff,
        ((int)(eui64 >> 16)) & 0xff,
        ((int)(eui64 >> 8)) & 0xff,
        (int)eui64 & 0xff);

    sqlite3_result_text(ctx, buf, -1, SQLITE_TRANSIENT);
}

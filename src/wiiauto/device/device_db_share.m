#include "device_db.h"
#import <sqlite3.h>
#include "cherry/def.h"

static sqlite3 *__db__ = NULL;
static spin_lock __barrier__ = SPIN_LOCK_INIT;

static void __init()
{
    char *err_msg = NULL;
    int rc;
    const char *sql;

    lock(&__barrier__);
    if (!__db__) {
        sqlite3_open("/private/var/mobile/Library/WiiAuto/Databases/info_share.db", &__db__);

        if (__db__) {
            sql = "CREATE TABLE IF NOT EXISTS INFO (ID INTEGER PRIMARY KEY AUTOINCREMENT, BUNDLE TEXT NOT NULL, KEY TEXT NOT NULL, VALUE TEXT NOT NULL, CONSTRAINT BUNDLE_KEY_UNIQUE UNIQUE (BUNDLE,KEY));";
            rc = sqlite3_exec(__db__, sql, 0, 0, &err_msg);
            if (rc != SQLITE_OK) {
                sqlite3_free(err_msg);
            }
        }
    }
    unlock(&__barrier__);    
}

void wiiauto_device_db_share_setup()
{
    system("chown mobile:mobile /private/var/mobile/Library/WiiAuto/Databases/info_share.db");
    system("chmod 666 /private/var/mobile/Library/WiiAuto/Databases/info_share.db");
}

int wiiauto_device_db_set_share(const char *bundle, const char *key, const char *value)
{
    __init();
    if (!__db__) return 0;

    lock(&__barrier__);

    char *err_msg = NULL;
    int rc;
    const char *sql;

    rc = 0;

    sqlite3_exec(__db__, "BEGIN TRANSACTION;", NULL, NULL, NULL);

    if (value) {
        sql = sqlite3_mprintf("INSERT OR REPLACE INTO INFO(BUNDLE, KEY, VALUE) VALUES ('%q', '%q', '%q');", bundle, key, value);
    } else {
        sql = sqlite3_mprintf("DELETE FROM INFO WHERE BUNDLE = '%q' AND KEY = '%q';", bundle, key);
    }
    if (sql) {
        rc = sqlite3_exec(__db__, sql, 0, 0, &err_msg);
        if (rc != SQLITE_OK) {
            sqlite3_free(err_msg);
            rc = 0;
        } else {
            rc = 1;
        }
        sqlite3_free(sql);
    }

    sqlite3_exec(__db__, "END TRANSACTION;", NULL, NULL, NULL);

    unlock(&__barrier__);   

    return rc;
}

typedef struct
{
    char *value;
}
__result;

static int __callback(void *callBackArg, int argc, char **argv, char **azColName)
{
    if (argc > 0) {
        __result *ret = (__result *)callBackArg;

        for (int i = 0; i < argc; i++) {

            if (strcmp(azColName[i], "VALUE") == 0 || strcmp(azColName[i], "value") == 0) {
                ret->value = malloc(strlen(argv[i]) + 1);
                strcpy(ret->value, argv[i]);
            }

        }
    }

    return 0;
}


char *wiiauto_device_db_get_share(const char *bundle, const char *key)
{
    __init();
    if (!__db__) return NULL;

    char *err_msg = NULL;
    int rc;
    const char *sql;
    __result ret;
    ret.value = NULL;

    lock(&__barrier__);

    sql = sqlite3_mprintf("SELECT * FROM INFO WHERE BUNDLE = '%q' AND KEY = '%q';", bundle, key);
    if (sql) {
        rc = sqlite3_exec(__db__, sql, __callback, &ret, &err_msg);
        if (rc != SQLITE_OK) {
            sqlite3_free(err_msg);
        }
        sqlite3_free(sql);
    }

     unlock(&__barrier__);   

    return ret.value;
}

void wiiauto_device_db_get_share_all(const char *bundle, void *ctx, void(*callback)(void *ctx, const char *bundle, const char *key, const char *value))
{
    __init();
    if (!__db__) return;

    int rc;
    const char *sql;
    sqlite3_stmt *stmt;
    size_t len;

    lock(&__barrier__);
    sqlite3_exec(__db__, "BEGIN TRANSACTION;", NULL, NULL, NULL);     

    sql = "select key, value from info where bundle = ?;";
    rc = sqlite3_prepare_v2(__db__, sql, strlen(sql), &stmt, NULL);
    if (rc == SQLITE_OK) {
        sqlite3_bind_text(stmt, 1, bundle, strlen(bundle), SQLITE_TRANSIENT);

        rc = sqlite3_step(stmt);
        while (rc == SQLITE_ROW) {
            const char *key = sqlite3_column_text(stmt, 0);
            const char *value = sqlite3_column_text(stmt, 1);
            if (callback) {
                callback(ctx, bundle, key, value);
            }

            rc = sqlite3_step(stmt);
        }
        rc = sqlite3_clear_bindings(stmt);
        rc = sqlite3_reset(stmt);
        rc = sqlite3_finalize(stmt);    
    }

    sqlite3_exec(__db__, "END TRANSACTION;", NULL, NULL, NULL);     

    unlock(&__barrier__);
}
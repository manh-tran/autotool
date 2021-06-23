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
        sqlite3_open("/private/var/mobile/Library/WiiAuto/Databases/info.db", &__db__);

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

int wiiauto_device_db_set(const char *bundle, const char *key, const char *value)
{
    __init();
    if (!__db__) return 0;

    lock(&__barrier__);

    char *err_msg = NULL;
    int rc;
    const char *sql;

    rc = 0;

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


char *wiiauto_device_db_get(const char *bundle, const char *key)
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
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
        sqlite3_open("/private/var/mobile/Library/WiiAuto/Databases/blob_share.db", &__db__);

        if (__db__) {
            sql = "CREATE TABLE IF NOT EXISTS INFO (ID INTEGER PRIMARY KEY AUTOINCREMENT, BUNDLE TEXT NOT NULL, KEY BLOB NOT NULL, VALUE BLOB NOT NULL, CONSTRAINT BUNDLE_KEY_UNIQUE UNIQUE (BUNDLE,KEY));";
            rc = sqlite3_exec(__db__, sql, 0, 0, &err_msg);
            if (rc != SQLITE_OK) {
                sqlite3_free(err_msg);
            }
        }
    }
    unlock(&__barrier__);    
}

void wiiauto_device_db_blob_share_setup()
{
    system("chown mobile:mobile /private/var/mobile/Library/WiiAuto/Databases/blob_share.db");
    system("chmod 666 /private/var/mobile/Library/WiiAuto/Databases/blob_share.db");
}

int wiiauto_device_db_set_blob_share(const char *bundle, const char *key, const size_t key_len, const char *value, size_t len)
{
    __init();
    if (!__db__) return 0;

    lock(&__barrier__);

    int rc;
    const char *sql;
    sqlite3_stmt *stmt;

    sqlite3_exec(__db__, "BEGIN TRANSACTION;", NULL, NULL, NULL);     

    if (value) {
        sql = "INSERT OR REPLACE INTO INFO(BUNDLE, KEY, VALUE) VALUES (?, ?, ?);";
        rc = sqlite3_prepare_v2(__db__, sql, strlen(sql), &stmt, NULL);
        if (rc == SQLITE_OK) {
            sqlite3_bind_text(stmt, 1, bundle, strlen(bundle), SQLITE_TRANSIENT);
            sqlite3_bind_blob(stmt, 2, key, key_len, SQLITE_TRANSIENT);
            sqlite3_bind_blob(stmt, 3, value, len, SQLITE_TRANSIENT);

            rc = sqlite3_step(stmt);
            rc = sqlite3_clear_bindings(stmt);
            rc = sqlite3_reset(stmt);
            rc = sqlite3_finalize(stmt);    
        }
    } else {
        sql = "DELETE FROM INFO WHERE BUNDLE = ? AND KEY = ?;";
        rc = sqlite3_prepare_v2(__db__, sql, strlen(sql), &stmt, NULL);
        if (rc == SQLITE_OK) {
            sqlite3_bind_text(stmt, 1, bundle, strlen(bundle), SQLITE_TRANSIENT);
            sqlite3_bind_blob(stmt, 2, key, key_len, SQLITE_TRANSIENT);

            rc = sqlite3_step(stmt);
            rc = sqlite3_clear_bindings(stmt);
            rc = sqlite3_reset(stmt);
            rc = sqlite3_finalize(stmt);    
        }
    }                    
    
    sqlite3_exec(__db__, "END TRANSACTION;", NULL, NULL, NULL);     

    unlock(&__barrier__);   

    return rc;
}

void wiiauto_device_db_get_blob_share(const char *bundle, const char *key, const size_t key_len, char **value, size_t *len)
{
    *value = NULL;
    *len = 0;

    __init();
    if (!__db__) return;

    lock(&__barrier__);

    int rc;
    const char *sql;
    sqlite3_stmt *stmt;

    sqlite3_exec(__db__, "BEGIN TRANSACTION;", NULL, NULL, NULL);                            

    sql = "SELECT * FROM INFO WHERE BUNDLE = ? AND KEY = ?;";
    rc = sqlite3_prepare_v2(__db__, sql, strlen(sql), &stmt, NULL);
    if (rc == SQLITE_OK) {
        sqlite3_bind_text(stmt, 1, bundle, strlen(bundle), SQLITE_TRANSIENT);
        sqlite3_bind_blob(stmt, 2, key, key_len, SQLITE_TRANSIENT);

        rc = sqlite3_step(stmt);
        if (rc == SQLITE_ROW) {

            *len = sqlite3_column_bytes(stmt, 3);
            if (*len > 0) {
                *value = malloc(*len);
                memcpy(*value, sqlite3_column_blob(stmt, 3), *len);
            }            
        }
        rc = sqlite3_clear_bindings(stmt);
        rc = sqlite3_reset(stmt);
        rc = sqlite3_finalize(stmt);    
    }
    
    sqlite3_exec(__db__, "END TRANSACTION;", NULL, NULL, NULL);     

    unlock(&__barrier__);   
}
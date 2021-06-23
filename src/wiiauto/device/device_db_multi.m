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
        sqlite3_open("/private/var/mobile/Library/WiiAuto/Databases/cache_multi.db", &__db__);

        if (__db__) {
            sql = "CREATE TABLE IF NOT EXISTS INFO (ID INTEGER PRIMARY KEY AUTOINCREMENT, BUNDLE TEXT NOT NULL, KEY TEXT NOT NULL, VALUE TEXT NOT NULL);";
            rc = sqlite3_exec(__db__, sql, 0, 0, &err_msg);
            if (rc != SQLITE_OK) {
                sqlite3_free(err_msg);
            }
        }
    }
    unlock(&__barrier__);    
}

void wiiauto_device_db_multi_setup()
{
    system("chown mobile:mobile /private/var/mobile/Library/WiiAuto/Databases/cache_multi.db");
    system("chmod 666 /private/var/mobile/Library/WiiAuto/Databases/cache_multi.db");
}

void wiiauto_device_db_multi_add(const char *bundle, const char *key, const char *value)
{
    __init();
    if (!__db__) return;

    lock(&__barrier__);

    int rc;
    const char *sql;
    sqlite3_stmt *stmt;

    if (bundle && key && value) {
        sqlite3_exec(__db__, "BEGIN TRANSACTION;", NULL, NULL, NULL);     

        sql = "INSERT INTO INFO(BUNDLE, KEY, VALUE) VALUES (?, ?, ?);";
        rc = sqlite3_prepare_v2(__db__, sql, strlen(sql), &stmt, NULL);
        if (rc == SQLITE_OK) {
            sqlite3_bind_text(stmt, 1, bundle, strlen(bundle), SQLITE_TRANSIENT);
            sqlite3_bind_text(stmt, 2, key, strlen(key), SQLITE_TRANSIENT);
            sqlite3_bind_text(stmt, 3, value, strlen(value), SQLITE_TRANSIENT);

            rc = sqlite3_step(stmt);
            rc = sqlite3_clear_bindings(stmt);
            rc = sqlite3_reset(stmt);
            rc = sqlite3_finalize(stmt);    
        }      
        
        sqlite3_exec(__db__, "END TRANSACTION;", NULL, NULL, NULL);     

    }

    unlock(&__barrier__);  
}

void wiiauto_device_db_multi_delete(const char *bundle, const char *key)
{
    __init();
    if (!__db__) return;

    lock(&__barrier__);

    int rc;
    const char *sql;
    sqlite3_stmt *stmt;

    if (bundle && key) {
        sqlite3_exec(__db__, "BEGIN TRANSACTION;", NULL, NULL, NULL);     

        sql = "DELETE FROM INFO WHERE BUNDLE = ? AND KEY = ?;";
        rc = sqlite3_prepare_v2(__db__, sql, strlen(sql), &stmt, NULL);
        if (rc == SQLITE_OK) {
            sqlite3_bind_text(stmt, 1, bundle, strlen(bundle), SQLITE_TRANSIENT);
            sqlite3_bind_text(stmt, 2, key, strlen(key), SQLITE_TRANSIENT);

            rc = sqlite3_step(stmt);
            rc = sqlite3_clear_bindings(stmt);
            rc = sqlite3_reset(stmt);
            rc = sqlite3_finalize(stmt);    
        }      
        
        sqlite3_exec(__db__, "END TRANSACTION;", NULL, NULL, NULL);     

    }

    unlock(&__barrier__);  
}

char *wiiauto_device_db_multi_get(const char *bundle, const char *key, const int index)
{
    __init();
    if (!__db__) return NULL;

    lock(&__barrier__);

    int rc;
    const char *sql;
    sqlite3_stmt *stmt;
    size_t len = 0;
    char *value = NULL;

    sqlite3_exec(__db__, "BEGIN TRANSACTION;", NULL, NULL, NULL);     

    sql = "SELECT VALUE FROM INFO WHERE BUNDLE = ? AND KEY = ? LIMIT 1 OFFSET ?;";
    rc = sqlite3_prepare_v2(__db__, sql, strlen(sql), &stmt, NULL);
    if (rc == SQLITE_OK) {
        sqlite3_bind_text(stmt, 1, bundle, strlen(bundle), SQLITE_TRANSIENT);
        sqlite3_bind_text(stmt, 2, key, strlen(key), SQLITE_TRANSIENT);
        sqlite3_bind_int(stmt, 3, index);

        rc = sqlite3_step(stmt);
        if (rc == SQLITE_ROW) {
            
            len = sqlite3_column_bytes(stmt, 0);

            if (len > 0) {
                value = malloc(len + 1);
                memset(value, 0, len + 1);
                strncpy(value, sqlite3_column_text(stmt, 0), len);
            }  
        }
        rc = sqlite3_clear_bindings(stmt);
        rc = sqlite3_reset(stmt);
        rc = sqlite3_finalize(stmt);    
    }                
    
    sqlite3_exec(__db__, "END TRANSACTION;", NULL, NULL, NULL);     

    unlock(&__barrier__);  

    return value;
}
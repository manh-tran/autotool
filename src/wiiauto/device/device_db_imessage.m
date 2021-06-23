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
        sqlite3_open("/private/var/mobile/Library/WiiAuto/Databases/imessage5.db", &__db__);

        if (__db__) {
            sql = "CREATE TABLE IF NOT EXISTS IMESSAGE (ID INTEGER PRIMARY KEY AUTOINCREMENT, INFO TEXT NOT NULL, STATUS INTEGER NOT NULL);";
            rc = sqlite3_exec(__db__, sql, 0, 0, &err_msg);
            if (rc != SQLITE_OK) {
                sqlite3_free(err_msg);
            }
        }
    }
    unlock(&__barrier__);    
}

void wiiauto_device_db_imessage_setup()
{
    __init();

    system("chown mobile:mobile /private/var/mobile/Library/WiiAuto/Databases/imessage5.db");
    system("chmod 666 /private/var/mobile/Library/WiiAuto/Databases/imessage5.db");
}

void wiiauto_device_db_imessage_add(const char *infos)
{
    __init();
    if (!__db__) return;

    lock(&__barrier__);

    int rc;
    const char *sql;
    sqlite3_stmt *stmt;

    sqlite3_exec(__db__, "BEGIN TRANSACTION;", NULL, NULL, NULL);     

    sql = "INSERT INTO IMESSAGE(INFO, STATUS) VALUES (?, 1);";
    rc = sqlite3_prepare_v2(__db__, sql, strlen(sql), &stmt, NULL);
    if (rc == SQLITE_OK) {
        sqlite3_bind_text(stmt, 1, infos, strlen(infos), SQLITE_TRANSIENT);

        rc = sqlite3_step(stmt);
        rc = sqlite3_clear_bindings(stmt);
        rc = sqlite3_reset(stmt);
        rc = sqlite3_finalize(stmt);    
    }

    sqlite3_exec(__db__, "END TRANSACTION;", NULL, NULL, NULL);     

    unlock(&__barrier__);
}

void wiiauto_device_db_imessage_get(long long *rid, char **infos, const int status)
{
     __init();
    if (!__db__) return;

    int rc;
    const char *sql;
    sqlite3_stmt *stmt;
    size_t len;

    lock(&__barrier__);
    sqlite3_exec(__db__, "BEGIN TRANSACTION;", NULL, NULL, NULL);     

    sql = "SELECT ID, INFO FROM IMESSAGE WHERE STATUS = ? LIMIT 1;";
    rc = sqlite3_prepare_v2(__db__, sql, strlen(sql), &stmt, NULL);
    if (rc == SQLITE_OK) {
        sqlite3_bind_int(stmt, 1, status);
        rc = sqlite3_step(stmt);
        if (rc == SQLITE_ROW) {
            *rid = sqlite3_column_int(stmt, 0);

            len = sqlite3_column_bytes(stmt, 1);
            *infos = malloc(len + 1);
            memset(*infos, 0, len + 1);
            strncpy(*infos, sqlite3_column_text(stmt, 1), len);
        }
        rc = sqlite3_clear_bindings(stmt);
        rc = sqlite3_reset(stmt);
        rc = sqlite3_finalize(stmt);    
    }

    sqlite3_exec(__db__, "END TRANSACTION;", NULL, NULL, NULL);     

    unlock(&__barrier__);
}

void wiiauto_device_db_imessage_update_info(const long long rid, const char *infos)
{
    __init();
    if (!__db__) return;

    int rc;
    const char *sql;
    sqlite3_stmt *stmt;
    size_t len;

    lock(&__barrier__);
    sqlite3_exec(__db__, "BEGIN TRANSACTION;", NULL, NULL, NULL);     

    sql = "UPDATE IMESSAGE SET INFO = ? WHERE ID = ?";
    rc = sqlite3_prepare_v2(__db__, sql, strlen(sql), &stmt, NULL);
    if (rc == SQLITE_OK) {
        sqlite3_bind_text(stmt, 1, infos, strlen(infos), SQLITE_TRANSIENT);
        sqlite3_bind_int(stmt, 2, rid);

        rc = sqlite3_step(stmt);
        rc = sqlite3_clear_bindings(stmt);
        rc = sqlite3_reset(stmt);
        rc = sqlite3_finalize(stmt);    
    }

    sqlite3_exec(__db__, "END TRANSACTION;", NULL, NULL, NULL);     

    unlock(&__barrier__);
}

void wiiauto_device_db_imessage_set_status(const long long rid, int status)
{
    __init();
    if (!__db__) return;

    lock(&__barrier__);

    int rc;
    const char *sql;
    sqlite3_stmt *stmt;

    sqlite3_exec(__db__, "BEGIN TRANSACTION;", NULL, NULL, NULL);     

    sql = "UPDATE IMESSAGE SET STATUS = ? WHERE ID = ?;";
    rc = sqlite3_prepare_v2(__db__, sql, strlen(sql), &stmt, NULL);
    if (rc == SQLITE_OK) {
        sqlite3_bind_int(stmt, 1, status);
        sqlite3_bind_int(stmt, 2, rid);

        rc = sqlite3_step(stmt);
        rc = sqlite3_clear_bindings(stmt);
        rc = sqlite3_reset(stmt);
        rc = sqlite3_finalize(stmt);    
    }

    sqlite3_exec(__db__, "END TRANSACTION;", NULL, NULL, NULL);     

    unlock(&__barrier__);
}

void wiiauto_device_db_imessage_delete_processeds()
{
    __init();
    if (!__db__) return;

    lock(&__barrier__);

    int rc;
    const char *sql;
    sqlite3_stmt *stmt;

    sqlite3_exec(__db__, "BEGIN TRANSACTION;", NULL, NULL, NULL);     

    sql = "DELETE FROM IMESSAGE WHERE STATUS <> 1;";
    rc = sqlite3_prepare_v2(__db__, sql, strlen(sql), &stmt, NULL);
    if (rc == SQLITE_OK) {

        rc = sqlite3_step(stmt);
        rc = sqlite3_clear_bindings(stmt);
        rc = sqlite3_reset(stmt);
        rc = sqlite3_finalize(stmt);    
    }

    sqlite3_exec(__db__, "END TRANSACTION;", NULL, NULL, NULL);     

    unlock(&__barrier__);
}
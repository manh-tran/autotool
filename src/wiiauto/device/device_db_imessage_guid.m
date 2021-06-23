
#include "device_db.h"
#import <sqlite3.h>
#include "cherry/def.h"

static sqlite3 *__db__ = NULL;
static spin_lock __barrier__ = SPIN_LOCK_INIT;

static void __init()
{
    lock(&__barrier__);
    if (!__db__) {
        sqlite3_open("/private/var/mobile/Library/SMS/sms.db", &__db__);
    }
    unlock(&__barrier__);    
}

void wiiauto_device_db_imessage_get_last_guid(char **guid)
{
    *guid = NULL;
    
    __init();
    if (!__db__) return;

    int rc;
    const char *sql;
    sqlite3_stmt *stmt;
    size_t len;

    lock(&__barrier__);
    sqlite3_exec(__db__, "BEGIN TRANSACTION;", NULL, NULL, NULL);     

    sql = "SELECT guid from message order by ROWID desc limit 1;";
    rc = sqlite3_prepare_v2(__db__, sql, strlen(sql), &stmt, NULL);
    if (rc == SQLITE_OK) {
        rc = sqlite3_step(stmt);
        if (rc == SQLITE_ROW) {
            len = sqlite3_column_bytes(stmt, 0);
            *guid = malloc(len + 1);
            memset(*guid, 0, len + 1);
            strncpy(*guid, sqlite3_column_text(stmt, 0), len);
        }
        rc = sqlite3_clear_bindings(stmt);
        rc = sqlite3_reset(stmt);
        rc = sqlite3_finalize(stmt);    
    }

    sqlite3_exec(__db__, "END TRANSACTION;", NULL, NULL, NULL);     

    unlock(&__barrier__);
}
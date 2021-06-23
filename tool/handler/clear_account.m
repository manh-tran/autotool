#include "handler.h"
#import <sqlite3.h>
#include "cherry/util/util.h"

void wiiauto_clear_account();
void wiiauto_clear_keychain();

void wiiauto_tool_run_clear_account(const int argc, const char **argv)
{
    wiiauto_tool_register();
    wiiauto_clear_account();
}

static void __vacuum(const sqlite3 *db)
{
    char *errMsg;
    const char *sql_stmt = "VACUUM;";
    if (sqlite3_exec(db, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK) {
        sqlite3_free(errMsg);
    }
}

void wiiauto_tool_run_clear_keychain(const int argc, const char **argv)
{
    wiiauto_tool_register();
    // wiiauto_clear_keychain();

     char *err_msg = NULL;
    int rc;
    const char *sql;

    sqlite3 *db = nil;
    if (sqlite3_open_v2("/private/var/Keychains/keychain-2.db", &db, SQLITE_OPEN_READWRITE, NULL) == SQLITE_OK)
    {
        sql = sqlite3_mprintf("delete from genp where 1 > 0;");
        if (sql) {
            rc = sqlite3_exec(db, sql, 0, 0, &err_msg);
            if (rc != SQLITE_OK) {
                sqlite3_free(err_msg);
            }
            sqlite3_free(sql);
        }

        sql = sqlite3_mprintf("delete from cert where 1 > 0;");
        if (sql) {
            rc = sqlite3_exec(db, sql, 0, 0, &err_msg);
            if (rc != SQLITE_OK) {
                sqlite3_free(err_msg);
            }
            sqlite3_free(sql);
        }

        sql = sqlite3_mprintf("delete from keys where 1 > 0;");
        if (sql) {
            rc = sqlite3_exec(db, sql, 0, 0, &err_msg);
            if (rc != SQLITE_OK) {
                sqlite3_free(err_msg);
            }
            sqlite3_free(sql);
        }

        if (sqlite3_exec(db, "VACUUM;", NULL, NULL, &err_msg) != SQLITE_OK) {
            sqlite3_free(err_msg);
        }

        sqlite3_close(db);
    }
}
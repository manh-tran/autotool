#include "api.h"
#import <sqlite3.h>
#include "cherry/util/util.h"

int wiiauto_lua_get_total_zaccounts(lua_State *ls)
{
    sqlite3 *db = nil;
    int rc;
    const char *sql;
    sqlite3_stmt *stmt;
    size_t len;

    int total_accounts = 0;

    if (sqlite3_open("/private/var/mobile/Library/Accounts/Accounts3.sqlite", &db) == SQLITE_OK)
    {

        sqlite3_exec(db, "BEGIN TRANSACTION;", NULL, NULL, NULL);     

        sql = "SELECT COUNT(*) FROM ZACCOUNT;";
        rc = sqlite3_prepare_v2(db, sql, strlen(sql), &stmt, NULL);
        if (rc == SQLITE_OK) {
            rc = sqlite3_step(stmt);
            if (rc == SQLITE_ROW) {
                total_accounts = sqlite3_column_int(stmt, 0);
            }
            rc = sqlite3_clear_bindings(stmt);
            rc = sqlite3_reset(stmt);
            rc = sqlite3_finalize(stmt);    
        }

        sqlite3_exec(db, "END TRANSACTION;", NULL, NULL, NULL);     

        sqlite3_close(db);
    }

    lua_pushinteger(ls, total_accounts);

    return 1;
}
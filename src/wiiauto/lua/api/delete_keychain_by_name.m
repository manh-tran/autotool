#include "api.h"
#import <sqlite3.h>
#include "cherry/util/util.h"

static void __vacuum(const sqlite3 *db)
{
    char *errMsg;
    const char *sql_stmt = "VACUUM;";
    if (sqlite3_exec(db, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK) {
        // printf("VACUUM failed\n");
        sqlite3_free(errMsg);
    }
}


int wiiauto_lua_delete_keychain_by_name(lua_State *ls)
{
    const char *name = luaL_optstring(ls, 1, NULL);
    if (!name) return 0;

    char *err_msg = NULL;
    int rc;
    const char *sql;

    sqlite3 *db = nil;
    if (sqlite3_open_v2("/private/var/Keychains/keychain-2.db", &db, SQLITE_OPEN_READWRITE, NULL) == SQLITE_OK)
    {
        sql = sqlite3_mprintf("delete from genp where agrp like '%%%q%%';", name);
        if (sql) {
            rc = sqlite3_exec(db, sql, 0, 0, &err_msg);
            if (rc != SQLITE_OK) {
                sqlite3_free(err_msg);
            }
            sqlite3_free(sql);
        }

        sql = sqlite3_mprintf("delete from keys where agrp like '%%%q%%';", name);
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

    return 0;
}
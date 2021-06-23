#include "api.h"
#import <sqlite3.h>

int wiiauto_lua_fix_db(lua_State *ls)
{
    // const char *path = luaL_optstring(ls, 1, NULL);
    // const char *path_wal = luaL_optstring(ls, 2, NULL);

    // sqlite3 *db = nil;
    // if (sqlite3_open_v2(path, &db, SQLITE_OPEN_READWRITE, NULL) == SQLITE_OK)
    // {
    //     int v = sqlite3_snapshot_recover(db, path_wal);

    //     sqlite3_close(db);
    // }
    return 0;
}
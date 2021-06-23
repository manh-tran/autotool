#include "api.h"
#include "cherry/def.h"
#import <sqlite3.h>

static sqlite3 *__db__ = NULL;

static void __open()
{
    static spin_lock __barrier__ = 0;
    char *err_msg = NULL;
    int rc;
    const char *sql;

    lock(&__barrier__);

    if (!__db__) {
        sqlite3_open("/private/var/mobile/Library/WiiAuto/Cache/hashcode.db", &__db__);
    }

    if (__db__) {
        sql = "CREATE TABLE IF NOT EXISTS DATA (ID INTEGER PRIMARY KEY AUTOINCREMENT, CODE TEXT NOT NULL UNIQUE);";
        rc = sqlite3_exec(__db__, sql, 0, 0, &err_msg);
        if (rc != SQLITE_OK) {
            sqlite3_free(err_msg);
        }
    }

    unlock(&__barrier__);
}

int wiiauto_lua_remember_hashcode(lua_State *ls)
{
    char buf[1024];
    const char *code;
    const char *err_msg = NULL;
    int rc;

    code = luaL_optstring(ls, 1, NULL);
    if (!code) goto finish;

    __open();
    if (!__db__) goto finish;

    sprintf(buf, "INSERT INTO DATA(CODE) VALUES('%s');", code);
    rc = sqlite3_exec(__db__, buf, 0, 0, &err_msg);
    if (rc != SQLITE_OK) {
        sqlite3_free(err_msg);
    } 

finish:
    return 0;
}

static int __callback(void *callBackArg, int argc, char **argv, char **azColName)
{
    if (argc > 0) {
        int *ret = (int *)callBackArg;
        *ret = argc;
    }
}

int wiiauto_lua_is_hashcode_remembered(lua_State *ls)
{
    char buf[1024];
    const char *code;
    const char *err_msg = NULL;
    int rc;
    int ret = 0;

    code = luaL_optstring(ls, 1, NULL);
    if (!code) goto finish;

    __open();
    if (!__db__) {        
        goto finish;
    }
    
    sprintf(buf, "SELECT * FROM DATA WHERE CODE='%s';", code);
    rc = sqlite3_exec(__db__, buf, __callback, &ret, &err_msg);
    if (rc != SQLITE_OK) {
        sqlite3_free(err_msg);
    }

finish:
    lua_pushinteger(ls, ret);
    return 1;
}
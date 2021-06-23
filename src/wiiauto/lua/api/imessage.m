#include "api.h"
#include "wiiauto/device/device_db.h"
#include <notify.h>

int wiiauto_lua_db_imessage_get(lua_State *ls)
{
    int status = luaL_optinteger(ls, 1, -1);
    long long rid;
    char *infos = NULL;

    if (status >= 0) {

        wiiauto_device_db_imessage_get(&rid, &infos, status);
        if (infos) {
            lua_pushinteger(ls, rid);
            lua_pushstring(ls, infos);
            free(infos);
        } else {
            lua_pushinteger(ls, -1);
            lua_pushnil(ls);
        }

    } else {
        lua_pushinteger(ls, -1);
        lua_pushnil(ls);
    }

    return 2;
}

int wiiauto_lua_db_imessage_set_status(lua_State *ls)
{
    long long rid = luaL_optinteger(ls, 1, -1);
    int status = luaL_optinteger(ls, 2, -1);

    if (rid >= 0 && status >= 0) {
        wiiauto_device_db_imessage_set_status(rid, status);
    }

    return 0;
}

int wiiauto_lua_db_imessage_add(lua_State *ls)
{
    const char *infos = luaL_optstring(ls, 1, NULL);

    if (!infos || strlen(infos) == 0) goto finish;

    wiiauto_device_db_imessage_add(infos);

finish: 
    return 0;
}

int wiiauto_lua_db_imessage_delete_processeds()
{
    wiiauto_device_db_imessage_delete_processeds();
    return 0;
}
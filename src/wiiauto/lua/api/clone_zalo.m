#include "api.h"
#include "wiiauto/util/util.h"

int wiiauto_lua_clone_zalo(lua_State *ls)
{
    int ret;
    int group;
    const char *bundle;

    bundle = luaL_optstring(ls, 1, NULL);
    if (!bundle) {
        lua_pushstring(ls, "error");
        goto finish;
    }

    group = luaL_optinteger(ls, 2, 0);

    ret = wiiauto_util_clone_zalo(bundle, group);
    
    if (ret > 0) {
        lua_pushstring(ls, "success");
    } else if (ret == 0) {
        lua_pushstring(ls, "exist");
    } else {
        lua_pushstring(ls, "error");
    }

finish:
    return 1;
}

int wiiauto_lua_remove_all_clone_zalo(lua_State *ls)
{
    wiiauto_util_remove_all_clone_zalo();
    return 0;
}
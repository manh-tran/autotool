#include "api.h"

static void hook(lua_State* ls, lua_Debug *ar)
{
    lua_sethook(ls, hook, LUA_MASKLINE, 0); 
    luaL_error(ls, "stop by user!");
}

int wiiauto_lua_stop(lua_State *ls)
{
    lua_sethook(ls, hook, LUA_MASKLINE, 0);
    return 0;
}
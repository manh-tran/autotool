#include "api.h"

int wiiauto_lua_usleep(lua_State *ls)
{
#if WIIAUTO_DEBUG_LUA_API == 1
    printf("wiiauto_lua_usleep_start\n");
#endif

    int ms = luaL_optinteger(ls, 1, 0);

    if (ms > 0) {
        usleep(ms);
    }

#if WIIAUTO_DEBUG_LUA_API == 1
    printf("wiiauto_lua_usleep_end\n");
#endif
    return 0;
}
#include "api.h"
#include "wiiauto/common/common.h"

int wiiauto_lua_int_to_rgb(lua_State *ls)
{
#if WIIAUTO_DEBUG_LUA_API == 1
    printf("wiiauto_lua_int_to_rgb_start\n");
#endif
    i32 color;
    u8 r, g, b;

    color = luaL_optinteger(ls, 1, 0);

    common_int_to_rgb(color, &r, &g, &b);

    lua_pushinteger(ls, r);
    lua_pushinteger(ls, g);
    lua_pushinteger(ls, b);

#if WIIAUTO_DEBUG_LUA_API == 1
    printf("wiiauto_lua_int_to_rgb_end\n");
#endif
    return 3;
}
#include "api.h"
#include "wiiauto/common/common.h"

int wiiauto_lua_rgb_to_int(lua_State *ls)
{
#if WIIAUTO_DEBUG_LUA_API == 1
    printf("wiiauto_lua_rgb_to_int_start\n");
#endif
    i32 color;
    u8 r, g, b;

    r = luaL_optinteger(ls, 1, 0);
    g = luaL_optinteger(ls, 2, 0);
    b = luaL_optinteger(ls, 3, 0);

    common_rgb_to_int(r, g, b, &color);

    lua_pushinteger(ls, color);

#if WIIAUTO_DEBUG_LUA_API == 1
    printf("wiiauto_lua_rgb_to_int_end\n");
#endif
    return 1;
}
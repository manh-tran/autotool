#include "api.h"
#include "wiiauto/common/common.h"

int wiiauto_lua_get_color(lua_State *ls)
{
#if WIIAUTO_DEBUG_LUA_API == 1
    printf("wiiauto_lua_get_color_start\n");
#endif
    i32 color;
    float x, y;

    x = luaL_optnumber(ls, 1, 0);
    y = luaL_optnumber(ls, 2, 0);

    common_get_color(x, y, &color);

    lua_settop(ls, 0);
    lua_pushinteger(ls, color); 

#if WIIAUTO_DEBUG_LUA_API == 1
    printf("wiiauto_lua_get_color_end\n");
#endif  
    return 1;
}
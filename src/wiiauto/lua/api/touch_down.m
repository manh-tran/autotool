#include "api.h"
#include "wiiauto/common/common.h"

float down_x = 0;
float down_y = 0;

int wiiauto_lua_touch_down(lua_State *ls)
{
#if WIIAUTO_DEBUG_LUA_API == 1
    printf("wiiauto_lua_touch_down_start\n");
#endif
    int index;
    float x, y;

    index = luaL_optinteger(ls, 1, 0);
    x = luaL_optnumber(ls, 2, 0);
    y = luaL_optnumber(ls, 3, 0);

    down_x = x;
    down_y = y;

    common_touch_down(index, x, y);

#if WIIAUTO_DEBUG_LUA_API == 1
    printf("wiiauto_lua_touch_down_end\n");
#endif
    return 0;
}
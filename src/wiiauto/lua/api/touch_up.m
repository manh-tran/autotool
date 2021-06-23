#include "api.h"

#include "wiiauto/common/common.h"

int wiiauto_lua_touch_up(lua_State *ls)
{
#if WIIAUTO_DEBUG_LUA_API == 1
    printf("wiiauto_lua_touch_up_start\n");
#endif
    int index;
    float x, y;

    index = luaL_optinteger(ls, 1, 0);
    x = luaL_optnumber(ls, 2, 0);
    y = luaL_optnumber(ls, 3, 0);
    
    common_touch_up(index, x, y);

#if WIIAUTO_DEBUG_LUA_API == 1
    printf("wiiauto_lua_touch_up_end\n");
#endif
    return 0;
}
#include "api.h"
#include "wiiauto/common/common.h"

int wiiauto_lua_get_screen_resolution(lua_State *ls)
{
#if WIIAUTO_DEBUG_LUA_API == 1
    printf("wiiauto_lua_get_screen_resolution_start\n");
#endif
    u32 width, height;

    common_get_view_size(&width, &height);

    lua_pushinteger(ls, width);
    lua_pushinteger(ls, height);

#if WIIAUTO_DEBUG_LUA_API == 1
    printf("wiiauto_lua_get_screen_resolution_end\n");
#endif
    return 2;
}
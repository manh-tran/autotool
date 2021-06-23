#include "api.h"
#include "wiiauto/common/common.h"

int wiiauto_lua_get_orientation(lua_State *ls)
{
#if WIIAUTO_DEBUG_LUA_API == 1
    printf("wiiauto_lua_get_orientation_start\n");
#endif
    __wiiauto_device_orientation o;

    common_get_orientation(&o);
    lua_pushinteger(ls, o);

#if WIIAUTO_DEBUG_LUA_API == 1
    printf("wiiauto_lua_get_orientation_end\n");
#endif
    return 1;
}
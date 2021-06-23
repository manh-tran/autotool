#include "api.h"
#include "wiiauto/common/common.h"

int wiiauto_lua_key_down(lua_State *ls)
{
#if WIIAUTO_DEBUG_LUA_API == 1
    printf("wiiauto_lua_key_down_start\n");
#endif
    int type;

    type = luaL_optnumber(ls, 1, 0);

    common_key_down(type);

#if WIIAUTO_DEBUG_LUA_API == 1
    printf("wiiauto_lua_key_down_end\n");
#endif
    return 0;
}
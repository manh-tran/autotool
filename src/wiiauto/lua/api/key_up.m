#include "api.h"
#include "wiiauto/common/common.h"

int wiiauto_lua_key_up(lua_State *ls)
{
#if WIIAUTO_DEBUG_LUA_API == 1
    printf("wiiauto_lua_key_up_start\n");
#endif
    int type;

    type = luaL_optinteger(ls, 1, 0);

    common_key_up(type);

#if WIIAUTO_DEBUG_LUA_API == 1
    printf("wiiauto_lua_key_up_end\n");
#endif
    return 0;
}
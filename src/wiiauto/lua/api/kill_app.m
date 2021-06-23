#include "api.h"
#include "wiiauto/common/common.h"

int wiiauto_lua_kill_app(lua_State *ls)
{

#if WIIAUTO_DEBUG_LUA_API == 1
    printf("wiiauto_lua_kill_app_start\n");
#endif
    const char *bundle = "";

    bundle = luaL_optstring(ls, 1, "");

    if (strlen(bundle) > 0) {

        common_kill_app(bundle);
            
    }

#if WIIAUTO_DEBUG_LUA_API == 1
    printf("wiiauto_lua_kill_app_end\n");
#endif
    return 0;
}
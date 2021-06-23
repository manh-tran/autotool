#include "api.h"
#include "wiiauto/app/app.h"
#include "wiiauto/event/event_app_state.h"
#include "wiiauto/common/common.h"

int wiiauto_lua_get_app_state(lua_State *ls)
{
#if WIIAUTO_DEBUG_LUA_API == 1
    printf("wiiauto_lua_get_app_state_start\n");
#endif
    const char *bundle = "";
    const char *front = "";

    bundle = luaL_optstring(ls, 1, "");    
    common_get_front_most_app_bundle_id(&front);

    if (bundle && front && strcmp(bundle, front) == 0) {
        lua_pushstring(ls, "ACTIVATED");
    } else {
        lua_pushstring(ls, "NOT RUNNING");
    }
#if WIIAUTO_DEBUG_LUA_API == 1
    printf("wiiauto_lua_get_app_state_end\n");
#endif
    return 1;
}
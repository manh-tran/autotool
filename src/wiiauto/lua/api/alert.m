#include "api.h"
#include "wiiauto/common/common.h"

int wiiauto_lua_alert(lua_State *ls)
{
#if WIIAUTO_DEBUG_LUA_API == 1
    printf("wiiauto_lua_alert_start\n");
#endif
    const char *content = "";

    content = luaL_optstring(ls, 1, "");
    if (strlen(content) > 0) {
        common_alert(content);
    }

#if WIIAUTO_DEBUG_LUA_API == 1
    printf("wiiauto_lua_alert_end\n");
#endif
    return 0;
}
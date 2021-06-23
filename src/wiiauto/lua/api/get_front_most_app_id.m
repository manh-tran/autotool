#include "api.h"
#include "wiiauto/common/common.h"

int wiiauto_lua_get_front_most_app_id(lua_State *ls)
{
#if WIIAUTO_DEBUG_LUA_API == 1
    printf("wiiauto_lua_get_front_most_app_id_start\n");
#endif
    const char *bundle = "";

    common_get_front_most_app_bundle_id(&bundle);

    lua_pushstring(ls, bundle);

#if WIIAUTO_DEBUG_LUA_API == 1
    printf("wiiauto_lua_get_front_most_app_id_end\n");
#endif
    return 1;
}
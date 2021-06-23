#include "api.h"
#include "wiiauto/device/device.h"

int wiiauto_lua_root_dir(lua_State *ls)
{
#if WIIAUTO_DEBUG_LUA_API == 1
    printf("wiiauto_lua_root_dir_start\n");
#endif
    buffer b;
    const char *ptr;

    buffer_new(&b);
    buffer_append(b, WIIAUTO_ROOT_SCRIPTS_PATH, strlen(WIIAUTO_ROOT_SCRIPTS_PATH) - 1);
    buffer_get_ptr(b, &ptr);

    lua_pushstring(ls, ptr);

    release(b.iobj);

#if WIIAUTO_DEBUG_LUA_API == 1
    printf("wiiauto_lua_root_dir_end\n");
#endif
    return 1;
}
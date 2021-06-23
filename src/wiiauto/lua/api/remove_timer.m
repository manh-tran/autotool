#include "api.h"
#include <time.h>
#include "cherry/util/util.h"
#include "wiiauto/common/common.h"
#include "wiiauto/preference/preference.h"
#include "../lua.h"

void wiiauto_daemon_remove_timer_internal(const char *url);

int wiiauto_lua_remove_timer(lua_State *ls)
{
#if WIIAUTO_DEBUG_LUA_API == 1
    printf("wiiauto_lua_remove_timer_start\n");
#endif
    int ret = 0;
    buffer url;
    const char *path = "";

    path = luaL_optstring(ls, 1, "");
    if (strlen(path) == 0) goto finish;

    buffer_new(&url);
    wiiauto_lua_process_input_path(ls, path, url);
    buffer_get_ptr(url, &path);
    
    // common_remove_timer(path);
    wiiauto_daemon_remove_timer_internal(path);

    release(url.iobj);

finish:
    lua_pushboolean(ls, ret);

#if WIIAUTO_DEBUG_LUA_API == 1
    printf("wiiauto_lua_remove_timer_end\n");
#endif
    return 1;
}
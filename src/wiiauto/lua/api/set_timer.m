#include "api.h"
#include <time.h>
#include "cherry/util/util.h"
#include "wiiauto/common/common.h"
#include "wiiauto/preference/preference.h"
#include "../lua.h"

void wiiauto_daemon_add_timer_internal(const char *url, const time_t fire_time, const u8 repeat, const i32 interval);

int wiiauto_lua_set_timer(lua_State *ls)
{
#if WIIAUTO_DEBUG_LUA_API == 1
    printf("wiiauto_lua_set_timer_start\n");
#endif

    int ret = 0;
    buffer url;
    const char *path = "";
    const char *firetime_str = NULL;
    time_t firetime_int = -1;
    time_t t_i, t_now;
    int repeat = 0;
    int interval = 0;

    path = luaL_optstring(ls, 1, "");
    if (strlen(path) == 0) goto finish;

    if (lua_isinteger(ls, 2)) {
        firetime_int = lua_tointeger(ls, 2);
        if (firetime_int < 0) {
            firetime_int = 0;
        }
    } else if (lua_isstring(ls, 2)) {
        firetime_str = luaL_optstring(ls, 2, NULL);
    }

    if (firetime_str) {
        util_strtime(firetime_str, &t_i);
    } else {
        util_time(&t_now);
        t_i = t_now + firetime_int;
    }

    buffer_new(&url);
    wiiauto_lua_process_input_path(ls, path, url);
    buffer_get_ptr(url, &path);

    if (lua_isboolean(ls, 3)) {
        repeat = lua_toboolean(ls, 3);
    }

    interval = luaL_optinteger(ls, 4, 0);
    
    // common_set_timer(path, t_i, repeat, interval);

    wiiauto_daemon_add_timer_internal(path, t_i, repeat, interval);

    release(url.iobj);
    
finish:
    lua_pushboolean(ls, ret);

#if WIIAUTO_DEBUG_LUA_API == 1
    printf("wiiauto_lua_set_timer_end\n");
#endif
    return 1;
}
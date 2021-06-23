#include "api.h"
#include "cherry/core/buffer.h"
#include "../lua.h"

int wiiauto_lua_current_path(lua_State *ls)
{
#if WIIAUTO_DEBUG_LUA_API == 1
    printf("wiiauto_lua_current_path_start\n");
#endif
    const char *path;
    buffer b;
    u32 len;
    
    wiiauto_lua_get_current_executing_path(ls, &path);
    if (path) {
        buffer_new(&b);
        len = strlen(path);

        if (len == 0) {
            lua_pushnil(ls);
        } else {
            if (path[len - 1] == '/') {
                buffer_append(b, path, len - 1);
            } else {
                buffer_append(b, path, len);
            }
            buffer_get_ptr(b, &path);
            lua_pushstring(ls, path);
        }      

        release(b.iobj);
    } else {
        lua_pushnil(ls);
    }

#if WIIAUTO_DEBUG_LUA_API == 1
    printf("wiiauto_lua_current_path_end\n");
#endif
    return 1;
}
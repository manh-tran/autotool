#include "api.h"
#include <sys/stat.h>
#include "../lua.h"
#include "cherry/core/buffer.h"

int wiiauto_lua_is_file_exist(lua_State *ls)
{
    const char *path = luaL_optstring(ls, 1, NULL);
    buffer url;

    buffer_new(&url);
    wiiauto_lua_process_input_path(ls, path, url);
    buffer_get_ptr(url, &path);

    struct stat st = {0};
    if(stat(path, &st) == -1) {
        lua_pushboolean(ls, 0);
    } else {
        lua_pushboolean(ls, 1);
    }

    release(url.iobj);
    return 1;
}
#include "api.h"
#include "cherry/core/buffer.h"
#include "wiiauto/lua/lua.h"

int wiiauto_lua_get_running_scripts(lua_State *ls)
{
    buffer b;
    buffer_new(&b);
    const char *ptr;

    wiiauto_lua_get_json_string_running_scripts(b, 1);
    buffer_get_ptr(b, &ptr);

    lua_pushstring(ls, ptr);

    release(b.iobj);
    return 1;
}
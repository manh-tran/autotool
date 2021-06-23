#include "api.h"
#include "log/remote_log.h"

int wiiauto_lua_remote_log(lua_State *ls)
{
    const char *content;

    content = luaL_optstring(ls, 1, NULL);

    if (content) {
        
        remote_log(content);

    }
    return 0;
}
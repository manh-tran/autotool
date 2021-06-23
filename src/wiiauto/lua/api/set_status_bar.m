#include "api.h"
#include "wiiauto/common/common.h"

int wiiauto_lua_set_status_bar(lua_State *ls)
{
    const char *ptr;

    ptr = luaL_optstring(ls, 1, NULL);
    if (ptr) {
        common_set_status_bar(ptr);
    }

    return 0;
}
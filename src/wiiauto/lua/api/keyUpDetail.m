#include "api.h"
#include "wiiauto/common/common.h"

int wiiauto_lua_key_up_detail(lua_State *ls)
{
    int usage_page, usage;

    usage_page = luaL_optinteger(ls, 1, 0);
    usage = luaL_optinteger(ls, 2, 0);

    common_key_up_detail(usage_page, usage);

    return 0;
}
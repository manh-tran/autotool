#include "api.h"
#include "wiiauto/common/common.h"

int wiiauto_lua_set_status_bar_state(lua_State *ls)
{
    int visible = luaL_optinteger(ls, 1, 1);
    
    common_set_status_bar_state(visible);

    return 0;
}
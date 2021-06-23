#include "api.h"
#include "wiiauto/common/common.h"

int wiiauto_lua_awake(lua_State *ls)
{   
    common_undim_display();
    return 0;
}
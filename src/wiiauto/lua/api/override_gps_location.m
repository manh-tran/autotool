#include "api.h"
#include "wiiauto/common/common.h"

int wiiauto_lua_override_gps_location(lua_State *ls)
{
    u8 v = 0;

    if (lua_isboolean(ls, 1)) {
        v = lua_toboolean(ls, 1);
    }

    common_override_gps_location(v);

    return 0;
}
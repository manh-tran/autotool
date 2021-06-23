#include "api.h"
#include "wiiauto/common/common.h"

int wiiauto_lua_set_gps_location(lua_State *ls)
{
    double latitude = luaL_optnumber(ls, 1, 0.0);
    double longitude = luaL_optnumber(ls, 2, 0.0);
    double altitude = luaL_optnumber(ls, 3, 0.0);
    
    common_set_gps_location(latitude, longitude, altitude);

    return 0;
}
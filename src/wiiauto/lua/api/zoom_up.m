#include "api.h"
#include "wiiauto/common/common.h"

int wiiauto_lua_zoom_up(lua_State *ls)
{
    int index;
    float x1, y1, x2, y2;

    index = luaL_optinteger(ls, 1, 0);
    x1 = luaL_optnumber(ls, 2, 0);
    y1 = luaL_optnumber(ls, 3, 0);
    x2 = luaL_optnumber(ls, 4, 0);
    y2 = luaL_optnumber(ls, 5, 0);

    common_zoom_up(index, x1, y1, x2, y2);

    return 0;
}
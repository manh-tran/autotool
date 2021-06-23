#include "api.h"

#include "wiiauto/common/common.h"
#include "cherry/math/cmath.h"

extern float down_x;
extern float down_y;

int wiiauto_lua_touch_move(lua_State *ls)
{
#if WIIAUTO_DEBUG_LUA_API == 1
    printf("wiiauto_lua_touch_move_start\n");
#endif
    int index;
    float x, y;
    // float vec[2], len, count, offset;

    index = luaL_optinteger(ls, 1, 0);
    x = luaL_optnumber(ls, 2, 0);
    y = luaL_optnumber(ls, 3, 0);

    // vec[0] = x - down_x;
    // vec[1] = y - down_y;
    // vector_length(2, vec, &len);
    // vector_normalize(2, vec);
    // count = 0;
    // offset = 0.01;
    // while (len > offset) {
    //     count += offset;
    //     common_touch_move(index, down_x + vec[0] * count, down_y + vec[1] * count);
    //     len -= offset;
    //     offset += 0.01;
    // }

    common_touch_move(index, x, y);

    // down_x = x;
    // down_y = y;
    
#if WIIAUTO_DEBUG_LUA_API == 1
    printf("wiiauto_lua_touch_move_end\n");
#endif
    return 0;
}
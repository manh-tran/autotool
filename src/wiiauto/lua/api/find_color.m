#include "api.h"
#include "cherry/core/buffer.h"
#include "wiiauto/common/common.h"
#include <pthread.h>

int wiiauto_lua_find_color(lua_State *ls)
{
#if WIIAUTO_DEBUG_LUA_API == 1
    printf("wiiauto_lua_find_color_start\n");
#endif
    i32 color, count, i;
    buffer b;
    f32 pos[2];
    i32 range[4];
    u32 width, height, len;

    /* get color */
    color = luaL_optinteger(ls, 1, 0);

    /* get count */
    count = luaL_optinteger(ls, 2, 1);

    /* get range */    
    common_get_view_size(&width, &height);

    range[0] = 0;
    range[1] = 0;
    range[2] = width;
    range[3] = height;

    if (lua_isnil(ls, 3)) {

    } else if (lua_istable(ls, 3)) {

        lua_pushvalue(ls, 3);
        lua_pushnil(ls);        

        i = 0;
        while (lua_next(ls, -2) != 0) {

            if (lua_type(ls, -2) == LUA_TNUMBER) {
                if (i < 4) {
                    range[i] = lua_tonumber(ls, -1);
                    i++;
                }
            }

            lua_pop(ls, 1);
        }
        lua_pop(ls, 1);

        if (i < 4) {
            range[0] = 0;
            range[1] = 0;
            range[2] = width;
            range[3] = height;
        }

        if (range[0] < 0) range[0] = 0;
        else if (range[0] >= width) range[0] = width - 1;

        if (range[1] < 0) range[1] = 0;
        else if(range[1] >= height) range[1] = height - 1;

        if (range[2] < 0) range[2] = 0;
        if (range[3] < 0) range[3] = 0;

        if (range[0] + range[2] > width) {
            range[2] = width - range[0];
        }

        if (range[1] + range[3] > height) {
            range[3] = height - range[1];
        }
    }    

    /* search */
    lua_settop(ls, 0);

    buffer_new(&b);    
    common_find_color(color, count, range, b);

    buffer_length(b, sizeof(f32[2]), &len);

    lua_newtable(ls);
    for (i = 0; i < len; ++i) {
        buffer_get(b, sizeof(f32[2]), i, pos);

        lua_newtable(ls);
        
        lua_pushnumber(ls, pos[0]);
        lua_rawseti(ls, -2, 1);

        lua_pushnumber(ls, pos[1]);
        lua_rawseti(ls, -2, 2);

        lua_rawseti(ls, -2, i + 1);
    }

    release(b.iobj);

#if WIIAUTO_DEBUG_LUA_API == 1
    printf("wiiauto_lua_find_color_end\n");
#endif

    __yield();
    return 1;
}
#include "api.h"
#include "cherry/core/buffer.h"
#include "wiiauto/common/common.h"
#include <pthread.h>

int wiiauto_lua_find_colors(lua_State *ls)
{
#if WIIAUTO_DEBUG_LUA_API == 1
    printf("wiiauto_lua_find_colors_start\n");
#endif
    i32 count, i;
    buffer b, colors;
    f32 pos[2];
    i32 range[4];
    u32 width, height, len;
    i32 arg[3];
    i32 offset;

     /* get count */
    count = luaL_optinteger(ls, 2, 1);
    offset = luaL_optinteger(ls, 4, 0);


    #if WIIAUTO_DEBUG_LUA_API == 1
        printf("wiiauto_lua_find_colors_____get_colors\n");
    #endif
    buffer_new(&colors);
    /* get colors */
    if (lua_isnil(ls, 1)) {

    } else if (lua_istable(ls, 1)) {
        lua_pushvalue(ls, 1);
        lua_pushnil(ls);
        while (lua_next(ls, -2) != 0) {

            if (lua_istable(ls, -1)) {
                i = 0;
                lua_pushnil(ls);
                while (lua_next(ls, -2) != 0) {

                    if (lua_type(ls, -2) == LUA_TNUMBER) {
                        if (i < 3) {
                            arg[i] = lua_tointeger(ls, -1);
                            i++;
                            if (i == 3) {
                                buffer_append(colors, arg, sizeof(arg));
                            }
                        }
                    }

                    lua_pop(ls, 1);
                }
            }

            lua_pop(ls, 1);
        }
        lua_pop(ls, 1);

    }
    
    /* get range */    
    common_get_view_size(&width, &height);

    #if WIIAUTO_DEBUG_LUA_API == 1
        printf("wiiauto_lua_find_colors_____get_ranges\n");
    #endif

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

    #if WIIAUTO_DEBUG_LUA_API == 1
        printf("wiiauto_lua_find_colors_____pre_process\n");
    #endif

    /* search */
    lua_settop(ls, 0);

    #if WIIAUTO_DEBUG_LUA_API == 1
        printf("wiiauto_lua_find_colors_____process: %d | %d %d %d %d\n", count, range[0], range[1], range[2], range[3]);
    #endif
    buffer_new(&b);    
    common_find_colors(colors, count, range, b, offset);

    #if WIIAUTO_DEBUG_LUA_API == 1
        printf("wiiauto_lua_find_colors_____complete_process\n");
    #endif
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

    #if WIIAUTO_DEBUG_LUA_API == 1
        printf("wiiauto_lua_find_colors_____ready_return\n");
    #endif

    release(b.iobj);
    release(colors.iobj);

#if WIIAUTO_DEBUG_LUA_API == 1
    printf("wiiauto_lua_find_colors_end\n");
#endif

    __yield();
    return 1;
}
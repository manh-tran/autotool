#include "api.h"
#include "wiiauto/common/common.h"
#include "cherry/core/buffer.h"

int wiiauto_lua_get_colors(lua_State *ls)
{

#if WIIAUTO_DEBUG_LUA_API == 1
    printf("wiiauto_lua_get_colors_start\n");
#endif
    f32 point[2];
    i32 i, color;
    buffer buf;
    u32 len;

    luaL_checktype(ls, 1, LUA_TTABLE);

    lua_pushvalue(ls, 1);
    lua_pushnil(ls);

    buffer_new(&buf);

    while (lua_next(ls, -2) != 0) {

        if (lua_istable(ls, -1)) {
            
            i = 0;
            lua_pushnil(ls);
            while (lua_next(ls, -2) != 0) {

                if (lua_type(ls, -2) == LUA_TNUMBER) {
                    if (i < 2) {
                        point[i] = lua_tonumber(ls, -1);
                        i++;
                        if (i == 2) {
                            buffer_append(buf, point, sizeof(point));
                        }
                    }
                }

                lua_pop(ls, 1);
            }
        }

        lua_pop(ls, 1);
    }
    lua_pop(ls, 1);

    lua_settop(ls, 0);
    buffer_length(buf, sizeof(f32[2]), &len);

    lua_createtable(ls, len, 0);

    for (i = 0; i < len; ++i) {
        buffer_get(buf, sizeof(f32[2]), i, point);

        common_get_color(point[0], point[1], &color);
        lua_pushinteger(ls, color);
        lua_rawseti(ls, -2, i + 1);
    }

    release(buf.iobj);  

#if WIIAUTO_DEBUG_LUA_API == 1
    printf("wiiauto_lua_get_colors_end\n");
#endif
    return 1;
}
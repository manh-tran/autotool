#include "api.h"
#include "wiiauto/common/common.h"
#include "../lua.h"
#include <pthread.h>

int wiiauto_lua_find_image_blackwhite(lua_State *ls)
{
    const char *path;
    u32 count;
    f32 threshold;
    // u8 debug;
    i32 method;
    i32 region[4];
    u32 width, height;
    i32 i;
    buffer b, url;
    f32 pos[2];
    u32 len;

    path = luaL_optstring(ls, 1, "");
    count = luaL_optinteger(ls, 2, 0);
    threshold = luaL_optnumber(ls, 3, 1.0);
    // debug = lua_toboolean(ls, 5);
    method = luaL_optinteger(ls, 6, 1);

    /* get region */    
    common_get_view_size(&width, &height);

    region[0] = 0;
    region[1] = 0;
    region[2] = width;
    region[3] = height;

    if (lua_isnil(ls, 4)) {

    } else if (lua_istable(ls, 4)) {

        lua_pushvalue(ls, 4);
        lua_pushnil(ls);        

        i = 0;
        while (lua_next(ls, -2) != 0) {

            if (lua_type(ls, -2) == LUA_TNUMBER) {
                if (i < 4) {
                    region[i] = lua_tonumber(ls, -1);
                    i++;
                }
            }

            lua_pop(ls, 1);
        }
        lua_pop(ls, 1);

        if (i < 4) {
            region[0] = 0;
            region[1] = 0;
            region[2] = width;
            region[3] = height;
        }

        if (region[0] < 0) region[0] = 0;
        else if (region[0] >= width) region[0] = width - 1;

        if (region[1] < 0) region[1] = 0;
        else if(region[1] >= height) region[1] = height - 1;

        if (region[2] < 0) region[2] = 0;
        if (region[3] < 0) region[3] = 0;

        if (region[0] + region[2] > width) {
            region[2] = width - region[0];
        }

        if (region[1] + region[3] > height) {
            region[3] = height - region[1];
        }
    }    

    /* search */
    lua_settop(ls, 0);

    buffer_new(&b);    

    buffer_new(&url);
    wiiauto_lua_process_input_path(ls, path, url);
    buffer_get_ptr(url, &path);
    
    common_find_image_blackwhite(path, count, threshold, region, b);
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
    release(url.iobj);

    return 1;
}
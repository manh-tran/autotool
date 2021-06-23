#include "api.h"
#include "wiiauto/common/common.h"
#include "../lua.h"

int wiiauto_lua_screen_shot(lua_State *ls)
{
#if WIIAUTO_DEBUG_LUA_API == 1
    printf("wiiauto_lua_screen_shot_start\n");
#endif
    const char *path;
    buffer url;
    i32 region[4];
    u32 width, height;
    i32 i;

    path = luaL_optstring(ls, 1, "screenshot.PNG");

    common_get_view_size(&width, &height);

    region[0] = 0;
    region[1] = 0;
    region[2] = width;
    region[3] = height;

    if (lua_isnil(ls, 2)) {

    } else if (lua_istable(ls, 2)) {

        lua_pushvalue(ls, 2);
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

    buffer_new(&url);
    wiiauto_lua_process_input_path(ls, path, url);
    buffer_get_ptr(url, &path);

    common_save_screen_shot(path, region);

    release(url.iobj);

#if WIIAUTO_DEBUG_LUA_API == 1
    printf("wiiauto_lua_screen_shot_end\n");
#endif
    return 0;
}
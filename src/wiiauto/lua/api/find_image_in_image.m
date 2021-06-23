#include "api.h"
#include "cherry/core/buffer.h"
#include "wiiauto/common/common.h"
#include "../lua.h"

int wiiauto_lua_find_image_in_image(lua_State *ls)
{
    const char *img1, *img2, *path1, *path2;
    buffer url1, url2, b;
    f32 pos[2];
    u32 len;
    int i;

    img1 = luaL_optstring(ls, 1, NULL);
    img2 = luaL_optstring(ls, 2, NULL);
    
    url1.iobj = id_null;
    url2.iobj = id_null;
    buffer_new(&b);

    if (!img1 || !img2) {
        goto finish;
    }

    buffer_new(&url1);
    wiiauto_lua_process_input_path(ls, img1, url1);
    buffer_get_ptr(url1, &path1);

    buffer_new(&url2);
    wiiauto_lua_process_input_path(ls, img2, url2);
    buffer_get_ptr(url2, &path2);

    common_find_image_in_image(path1, path2, 1, b);

finish:
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

    release(url1.iobj);
    release(url2.iobj);
    release(b.iobj);

    return 1;
}
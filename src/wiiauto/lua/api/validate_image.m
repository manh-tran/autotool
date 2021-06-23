#include "api.h"
#include "wiiauto/common/common.h"
#include "../lua.h"
#include <sys/stat.h>
#include <pthread.h>

#include "cherry/core/buffer.h"
#include "wiiauto/device/device.h"
#include "wiiauto/file/file.h"
#include "cherry/graphic/image.h"
#include "wiiauto/util/util.h"

int wiiauto_lua_validate_image(lua_State *ls)
{
    buffer url, burl;
    image img;
    u32 img_width = 0, img_height;

    const char *full_path = NULL;
    const char *path = luaL_optstring(ls, 1, NULL);
    if (!path) {
        lua_pushboolean(ls, 0);
        return 1;
    }

    buffer_new(&url);
    wiiauto_lua_process_input_path(ls, path, url);
    buffer_get_ptr(url, &path);

    struct stat st = {0};
    if(stat(path, &st) == -1) {
        release(url.iobj);
        lua_pushboolean(ls, 0);
        return 1;
    }



    /* load image */
    buffer_new(&burl);
    common_get_script_url(path, burl);
    buffer_get_ptr(burl, &full_path);

    image_new(&img);
    image_load_file(img, full_path, (f32[3]){1, 1, 1});
    image_get_size(img, &img_width, &img_height);

    release(burl.iobj);
    release(img.iobj);
    release(url.iobj);

    if (img_width > 0) {
        lua_pushboolean(ls, 1);
    } else {
        lua_pushboolean(ls, 0);
    }
 
    return 1;
}
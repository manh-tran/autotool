#include "api.h"
#include "wiiauto/device/device.h"
#include "wiiauto/common/common.h"


static int cc = 0;
int wiiauto_lua_test_screen(lua_State *ls)
{
    const __wiiauto_pixel *pixels;
    u32 view_width, view_height;
    int t;

    common_get_view_size(&view_width, &view_height);
    common_get_device_color_pointer(&pixels);

    if (pixels) {
        for (int i = 0; i < view_height; ++i) {
            for (int j = 0; j < view_width; ++j) {
                t = pixels[i * view_width + view_height].r;
                t += 3;
                t -= 100;
                if (t < 100) {
                    t++;
                }
                cc += t;
            }
        }
    }

    return 0;
}
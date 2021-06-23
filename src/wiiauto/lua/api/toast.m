#include "api.h"
#include "wiiauto/common/common.h"
#include "wiiauto/device/device.h"

int wiiauto_lua_toast(lua_State *ls)
{
    const char *message = NULL;
    int delay;
    u8 r;

    wiiauto_device_is_toast_enable(&r);

    message = luaL_optstring(ls, 1, "");
    delay = luaL_optnumber(ls, 2, 2);

    if (strlen(message) > 0 && r) {
        common_toast(message, delay);
    }

    return 0;
}
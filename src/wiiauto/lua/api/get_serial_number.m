#include "api.h"
#include "wiiauto/device/device.h"

int wiiauto_lua_get_serial_number(lua_State *ls)
{
#if WIIAUTO_DEBUG_LUA_API == 1
    printf("wiiauto_lua_get_serial_number_start\n");
#endif
    buffer b;
    const char *ptr = "";

    buffer_new(&b);
    wiiauto_device_get_serial_number(b);
    buffer_get_ptr(b, &ptr);
    
    lua_pushstring(ls, ptr);

    release(b.iobj);

#if WIIAUTO_DEBUG_LUA_API == 1
    printf("wiiauto_lua_get_serial_number_end\n");
#endif
    return 1;
}
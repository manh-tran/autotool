#include "api.h"
#include "wiiauto/util/nsdata_compression.h"

int wiiauto_lua_gzip_string(lua_State *ls)
{
    const char *str = luaL_optstring(ls, 1, NULL);
    if (!str) {
        lua_pushnil(ls);
        return 1;
    }

    @autoreleasepool {
        NSData *data = [NSData dataWithBytes:str length:strlen(str)];

        NSData *comp = [data gzipDeflate];
        lua_pushlstring(ls, [comp bytes], [comp length]);
    }

    return 1;
}
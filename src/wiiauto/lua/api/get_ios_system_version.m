#include "api.h"

int wiiauto_lua_get_ios_system_version(lua_State *ls)
{
    @autoreleasepool {
        NSString *s = [[UIDevice currentDevice] systemVersion];
        lua_pushstring(ls, [s UTF8String]);
    }
    return 1;
}
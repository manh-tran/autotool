#include "api.h"

int wiiauto_lua_get_new_uuid(lua_State *ls)
{
    @autoreleasepool {
        NSUUID  *UUID = [NSUUID UUID];
        NSString* stringUUID = [UUID UUIDString];
        lua_pushstring(ls, [stringUUID UTF8String]);
    }

    return 1;
}
#include "api.h"

extern NSString* CTSettingCopyMyPhoneNumber();

int wiiauto_lua_get_phone_number(lua_State *ls)
{
    NSString *phone = CTSettingCopyMyPhoneNumber();

    if (phone) {
        lua_pushstring(ls, [phone UTF8String]);
    } else {
        lua_pushstring(ls, "");
    }

    return 1;
}
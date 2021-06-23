#include "api.h"
#import <AdSupport/ASIdentifierManager.h>

int wiiauto_lua_reset_advertising_id(lua_State *ls)
{
    [[ASIdentifierManager sharedManager] clearAdvertisingIdentifier];
    NSString *idfaString = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    if (idfaString) {
        lua_pushstring(ls, [idfaString UTF8String]);
    } else {
        lua_pushnil(ls);
    }
    idfaString = nil;
    return 1;
}
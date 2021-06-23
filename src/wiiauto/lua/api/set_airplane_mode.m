#include "api.h"

@interface RadiosPreferences : NSObject

-(void) setAirplaneMode:(BOOL)val;
-(void)setTelephonyState:(BOOL)arg1 fromBundleID:(id)arg2;

@end

static NSBundle *bundle = nil;

int wiiauto_lua_set_airplane_mode(lua_State *ls)
{
    int on = luaL_optinteger(ls, 1, 0);

    if (!bundle) {
        bundle = [NSBundle bundleWithPath:@"/System/Library/PrivateFrameworks/AppSupport.framework"];
        BOOL success = [bundle load];    
        if (!success) {
            bundle = nil;
        }
    }

    @try {
        RadiosPreferences *radioPreferences = [[RadiosPreferences alloc] init];
        if (on) {
            [radioPreferences setAirplaneMode:YES];
        } else {
            [radioPreferences setAirplaneMode:NO];
        }        
    } @catch (NSException *e) {

    }

    return 0;
}
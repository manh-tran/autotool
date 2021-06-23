#include "api.h"

@interface CTMessageCenter : NSObject

+(id)sharedMessageCenter;
-(BOOL)sendSMSWithText:(id)arg1 serviceCenter:(id)arg2 toAddress:(id)arg3 withID:(unsigned)arg4 ;
-(BOOL)sendSMSWithText:(id)arg1 serviceCenter:(id)arg2 toAddress:(id)arg3 withMoreToFollow:(BOOL)arg4 withID:(unsigned)arg5 ;
-(BOOL)sendSMSWithText:(id)arg1 serviceCenter:(id)arg2 toAddress:(id)arg3 ;

@end

int wiiauto_lua_send_sms(lua_State *ls)
{
    const char *number = luaL_optstring(ls, 1, NULL);
    const char *message = luaL_optstring(ls, 2, NULL);
    BOOL success = false;

    if (!number || !message) goto finish;

    success = [[CTMessageCenter sharedMessageCenter] sendSMSWithText:[NSString stringWithUTF8String:message] serviceCenter:nil toAddress:[NSString stringWithUTF8String:number]];

finish:
    if (success) {
        lua_pushboolean(ls, 1);
    } else {
        lua_pushboolean(ls, 0);
    }
    return 1;
}
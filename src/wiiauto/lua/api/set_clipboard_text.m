#include "api.h"
#include "wiiauto/common/common.h"

int wiiauto_lua_set_clipboard_text(lua_State *ls)
{
#if WIIAUTO_DEBUG_LUA_API == 1
    printf("wiiauto_lua_set_clipboard_start\n");
#endif
    const char *text;

    text = luaL_optstring(ls, 1, "");

    @try {
        UIPasteboard *pb = [UIPasteboard generalPasteboard];
        [pb setString:[NSString stringWithUTF8String:text]];
        pb = nil;
    }
    @catch (NSException *exception) {
        
    }   

#if WIIAUTO_DEBUG_LUA_API == 1
    printf("wiiauto_lua_set_clipboard_end\n");
#endif
    return 0;
}
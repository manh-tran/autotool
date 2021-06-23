#include "api.h"

int wiiauto_lua_get_clipboard_text(lua_State *ls)
{
#if WIIAUTO_DEBUG_LUA_API == 1
    printf("wiiauto_lua_get_clipboard_text_start\n");
#endif
    const char *str = "";

    @try {
        UIPasteboard *pb = [UIPasteboard generalPasteboard];
        str = [[pb string] UTF8String];
    }
    @catch (NSException *exception) {
        str = "";
    }   
    
    lua_pushstring(ls, str);

#if WIIAUTO_DEBUG_LUA_API == 1
    printf("wiiauto_lua_get_clipboard_text_end\n");
#endif
    return 1;
}
#include "api.h"
#include <objc/runtime.h>

int wiiauto_lua_run_app(lua_State *ls)
{
#if WIIAUTO_DEBUG_LUA_API == 1
    printf("wiiauto_lua_run_app_start\n");
#endif
    const char *bundle = "";

    bundle = luaL_optstring(ls, 1, "");

    if (strlen(bundle) > 0) {

        @try {
            Class LSApplicationWorkspace_class = objc_getClass("LSApplicationWorkspace");
            NSObject * workspace = [LSApplicationWorkspace_class performSelector:@selector(defaultWorkspace)];
            [workspace performSelector:@selector(openApplicationWithBundleID:) withObject:[NSString stringWithUTF8String:bundle]];
            workspace = nil;
            LSApplicationWorkspace_class = nil;
        }
        @catch (NSException *exception) {
        
        }   
    }

#if WIIAUTO_DEBUG_LUA_API == 1
    printf("wiiauto_lua_run_app_end\n");
#endif
    return 0;
}
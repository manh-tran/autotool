#include "api.h"
#include <objc/runtime.h>

@interface LSApplicationWorkspace : NSObject
+ (LSApplicationWorkspace *)defaultWorkspace;
- (BOOL)installApplication:(NSURL *)path withOptions:(NSDictionary *)options;
- (BOOL)uninstallApplication:(NSString *)identifier withOptions:(NSDictionary *)options;
- (BOOL)applicationIsInstalled:(NSString *)appIdentifier;
- (NSArray *)allInstalledApplications;
- (NSArray *)allApplications;
- (NSArray *)applicationsOfType:(unsigned int)appType; // 0 for user, 1 for system
@end

int wiiauto_lua_uninstall_app(lua_State *ls)
{
#if WIIAUTO_DEBUG_LUA_API == 1
    printf("wiiauto_lua_uninstall_app_start\n");
#endif
    const char *bundle = "";

    bundle = luaL_optstring(ls, 1, "");

    if (strlen(bundle) > 0) {

        @try {
           Class LSApplicationWorkspace_class = objc_getClass("LSApplicationWorkspace");
            if (LSApplicationWorkspace_class) {
                LSApplicationWorkspace *workspace = [LSApplicationWorkspace_class performSelector:@selector(defaultWorkspace)];
                if (workspace) {
                    [workspace uninstallApplication:[NSString stringWithUTF8String:bundle] withOptions:nil];
                }
                workspace = nil;
            }  
            LSApplicationWorkspace_class = nil;          
        }
        @catch (NSException *exception) {
        }   
    }

#if WIIAUTO_DEBUG_LUA_API == 1
    printf("wiiauto_lua_uninstall_app_end\n");
#endif
    return 0;
}
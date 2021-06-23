#include "api.h"
#import <sys/utsname.h>
#include <sys/sysctl.h>

int wiiauto_lua_get_device_name(lua_State *ls)
{
    @autoreleasepool {
        NSString *v = [[UIDevice currentDevice] name];
        if (v) {
            lua_pushstring(ls, [v UTF8String]);
        } else {
            lua_pushstring(ls, "");
        }
    }
    return 1;
}

int wiiauto_lua_get_device_model(lua_State *ls)
{
    @autoreleasepool {
        struct utsname systemInfo;
        uname(&systemInfo);
        NSString *v = [NSString stringWithCString:systemInfo.machine
                                        encoding:NSUTF8StringEncoding];
        if (v) {
            lua_pushstring(ls, [v UTF8String]);
        } else {
            lua_pushstring(ls, "");
        }
    }
    return 1;
}

int wiiauto_lua_get_system_build_version(lua_State *ls)
{
    @autoreleasepool {
        NSString *ctlKey = @"kern.osversion";
        NSString *v = nil;

        size_t size = 0;

        if (sysctlbyname([ctlKey UTF8String], NULL, &size, NULL, 0) == -1) {

        } else {

            char *machine = calloc( 1, size );
            sysctlbyname([ctlKey UTF8String], machine, &size, NULL, 0);
            NSString *ctlValue = [NSString stringWithCString:machine encoding:[NSString defaultCStringEncoding]];
            free(machine);
            v = ctlValue;
        }

        if (v) {
            lua_pushstring(ls, [v UTF8String]);
        } else {
            lua_pushstring(ls, "");
        }
    }
    
    return 1;
}

int wiiauto_lua_get_system_version(lua_State *ls)
{
    @autoreleasepool {
        NSString *v = [[UIDevice currentDevice] systemVersion];
        if (v) {
            lua_pushstring(ls, [v UTF8String]);
        } else {
            lua_pushstring(ls, "");
        }
    }
    return 1;
}
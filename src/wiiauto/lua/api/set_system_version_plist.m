#include "api.h"
#include <sys/stat.h>

int wiiauto_lua_set_system_version_plist(lua_State *ls)
{
    const char *os_version = luaL_optstring(ls, 1, NULL);
    const char *os_build = luaL_optstring(ls, 2, NULL);
    int success = 0;

    if (os_version && os_build) {

        {
            struct stat st = {0};
            if(stat("/System/Library/CoreServices/SystemVersion_backup.plist", &st) == -1) {
                system("cp /System/Library/CoreServices/SystemVersion.plist /System/Library/CoreServices/SystemVersion_backup.plist");
            }
        }    

        {
            struct stat st = {0};
            if(stat("/System/Library/CoreServices/SystemVersion_backup.plist", &st) != -1) {
                /* change app info */
                @try {
                    NSString* path = @"/System/Library/CoreServices/SystemVersion.plist";
                    NSMutableDictionary* dict = [NSDictionary dictionaryWithContentsOfFile:path].mutableCopy; 
                    
                    dict[@"ProductBuildVersion"] = [NSString stringWithUTF8String:os_build];
                    dict[@"ProductVersion"] = [NSString stringWithUTF8String:os_version];

                    {
                        NSUUID  *UUID = [NSUUID UUID];
                        NSString* stringUUID = [UUID UUIDString];
                        dict[@"BuildID"] = stringUUID;
                    }
                    {
                        NSUUID  *UUID = [NSUUID UUID];
                        NSString* stringUUID = [UUID UUIDString];
                        dict[@"SystemImageID"] = stringUUID;
                    }
                    
                    [dict writeToFile:path atomically:YES];
                    dict = nil;
                    success = 1;
                } @catch (NSException *e) {
                }
   
            }
        }    
    } else {
        {
            struct stat st = {0};
            if(stat("/System/Library/CoreServices/SystemVersion_backup.plist", &st) != -1) {
                system("cp /System/Library/CoreServices/SystemVersion_backup.plist /System/Library/CoreServices/SystemVersion.plist");
                success = 1;
            }
        }  
    }


    lua_pushboolean(ls, success);

    return 1;
}
#include "api.h"

static void __find_and_delete(NSString* appName, NSString* dir)
{
    NSFileManager *manager = [NSFileManager defaultManager];
    
    NSError *error = nil;
    NSArray *folders = [manager contentsOfDirectoryAtPath:dir error:&error];
    char buf[2048];
    
    if (!error)
    {
        for (NSString *folder in folders)
        {
            @try {
                NSString *folderPath = [dir stringByAppendingString:folder];
                NSArray *items = [manager contentsOfDirectoryAtPath:folderPath error:&error];
                
                for(NSString* itemPath in items)
                {
                    if([itemPath rangeOfString:@".com.apple.mobile_container_manager.metadata.plist"].location != NSNotFound)
                    {
                        NSString* fullpath = [NSString stringWithFormat:@"%@/%@",folderPath, itemPath];
                        NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:fullpath];
                    
                        NSString* mcmmetadata = dict[@"MCMMetadataIdentifier"];
                        // if(mcmmetadata && [mcmmetadata rangeOfString:appName].location != NSNotFound)
                        if (mcmmetadata && [mcmmetadata hasPrefix:appName])
                        {
                            // sprintf(buf, "rm -rf %s  ", [folderPath UTF8String]);
                            // system(buf);

                            sprintf(buf, "cd %s/Documents && find . -maxdepth 1 -type d -exec rm -rf {} +", [folderPath UTF8String]);
                            system(buf);
                            sprintf(buf, "cd %s/Documents && find . -maxdepth 1 -type f -exec rm  {} +", [folderPath UTF8String]);
                            system(buf);

                            sprintf(buf, "cd %s/tmp && find . -maxdepth 1 -type d -exec rm -rf {} +", [folderPath UTF8String]);
                            system(buf);
                            sprintf(buf, "cd %s/tmp && find . -maxdepth 1 -type f -exec rm  {} +", [folderPath UTF8String]);
                            system(buf);

                            sprintf(buf, "cd %s/Library && find . -maxdepth 1 -not -name Caches -not -name Preferences -not -name SplashBoard -type d -exec rm -rf {} +", [folderPath UTF8String]);
                            system(buf);
                            sprintf(buf, "cd %s/Library && find . -maxdepth 1 -not -name Caches -not -name Preferences -not -name SplashBoard -type f -exec rm {} +", [folderPath UTF8String]);
                            system(buf);

                            sprintf(buf, "cd %s/Library/Caches && find . -maxdepth 1 -type d -exec rm -rf {} +", [folderPath UTF8String]);
                            system(buf);
                            sprintf(buf, "cd %s/Library/Caches && find . -maxdepth 1 -type f -exec rm  {} +", [folderPath UTF8String]);
                            system(buf);
                            break;
                        }
                    }
                }
            } @catch (NSException *e) {

            }
            
        }
        
    }
}

int wiiauto_lua_delete_app_data_start_with(lua_State *ls)
{
    const char *agi = NULL;

    agi = luaL_optstring(ls, 1, NULL);
    if (!agi) {
        goto finish;
    }

     @autoreleasepool {
        @try {
           
            NSString *dir = @"/private/var/mobile/Containers/Data/Application/";
            __find_and_delete([NSString stringWithUTF8String:agi],dir);

        } @catch (NSException *e) {
        }
    }

finish:
    return 0;
}

int wiiauto_lua_delete_app_group_start_with(lua_State *ls)
{
    const char *agi = NULL;

    agi = luaL_optstring(ls, 1, NULL);
    if (!agi) {
        goto finish;
    }

     @autoreleasepool {
        @try {
           
            NSString *dir = @"/private/var/mobile/Containers/Shared/AppGroup/";
            __find_and_delete([NSString stringWithUTF8String:agi],dir);

        } @catch (NSException *e) {
        }
    }

finish:
    return 0;
}


static void __find_and_delete_exactly(NSString* appName, NSString* dir)
{
    NSFileManager *manager = [NSFileManager defaultManager];
    
    NSError *error = nil;
    NSArray *folders = [manager contentsOfDirectoryAtPath:dir error:&error];
    char buf[2048];
    
    if (!error)
    {
        for (NSString *folder in folders)
        {
            @try {
                NSString *folderPath = [dir stringByAppendingString:folder];
                NSArray *items = [manager contentsOfDirectoryAtPath:folderPath error:&error];
                
                for(NSString* itemPath in items)
                {
                    if([itemPath rangeOfString:@".com.apple.mobile_container_manager.metadata.plist"].location != NSNotFound)
                    {
                        NSString* fullpath = [NSString stringWithFormat:@"%@/%@",folderPath, itemPath];
                        NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:fullpath];
                    
                        NSString* mcmmetadata = dict[@"MCMMetadataIdentifier"];
                        if (mcmmetadata && [mcmmetadata isEqualToString:appName])
                        {
                            sprintf(buf, "rm -rf %s  ", [folderPath UTF8String]);
                            system(buf);
                            break;
                        }
                    }
                }
            } @catch (NSException *e) {

            }
            
        }
        
    }
}

int wiiauto_lua_delete_app_data_exactly(lua_State *ls)
{
    const char *agi = NULL;

    agi = luaL_optstring(ls, 1, NULL);
    if (!agi) {
        goto finish;
    }

     @autoreleasepool {
        @try {
           
            NSString *dir = @"/private/var/mobile/Containers/Data/Application/";
            __find_and_delete_exactly([NSString stringWithUTF8String:agi],dir);

        } @catch (NSException *e) {
        }
    }

finish:
    return 0;
}

int wiiauto_lua_delete_app_group_exactly(lua_State *ls)
{
    const char *agi = NULL;

    agi = luaL_optstring(ls, 1, NULL);
    if (!agi) {
        goto finish;
    }

     @autoreleasepool {
        @try {
           
            NSString *dir = @"/private/var/mobile/Containers/Shared/AppGroup/";
            __find_and_delete_exactly([NSString stringWithUTF8String:agi],dir);

        } @catch (NSException *e) {
        }
    }

finish:
    return 0;
}
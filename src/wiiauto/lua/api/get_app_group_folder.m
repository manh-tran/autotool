#include "api.h"

static NSString *__findFolder(NSString* appName, NSString* dir)
{
    NSFileManager *manager = [NSFileManager defaultManager];
    
    NSError *error = nil;
    NSArray *folders = [manager contentsOfDirectoryAtPath:dir error:&error];
    
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
                        if(mcmmetadata && [mcmmetadata rangeOfString:appName].location != NSNotFound)
                        {
                            return folderPath;
                        }
                    }
                }
            } @catch (NSException *e) {

            }
            
        }
        
    }
    return nil;
}

int wiiauto_lua_get_app_group_folder(lua_State *ls)
{
    const char *agi = NULL;

    agi = luaL_optstring(ls, 1, NULL);
    if (!agi) {
        lua_pushnil(ls);
        return 1;
    }

    @autoreleasepool {

        @try {

            NSString *result = nil;
            // NSURL *fileManagerURL = [[[NSFileManager alloc] init] containerURLForSecurityApplicationGroupIdentifier:[NSString stringWithUTF8String:agi]];
            // if (fileManagerURL) {
            //     result = [NSString stringWithFormat:@"%@", fileManagerURL.path];
            // }

            char buf[1025];
            sprintf(buf, "/usr/bin/wiiauto_run get_app_group %s", agi);

            FILE *fp = popen(buf, "r");
            if (fp) {
                while (fgets(buf, 1024, fp) != NULL) {
                    if (!result) {
                        result = [NSString stringWithUTF8String:buf];
                    } else {
                        result = [result stringByAppendingString:[NSString stringWithUTF8String:buf]];
                    }
                }
                pclose(fp);
            }

            if (!result) {
                NSString *dir = @"/private/var/mobile/Containers/Shared/AppGroup/";
                result = __findFolder([NSString stringWithUTF8String:agi],dir);
            }
            if (result) {
                lua_pushstring(ls, [result UTF8String]);
            } else {
                lua_pushnil(ls);
            }

        } @catch (NSException *e) {
            lua_pushnil(ls);
        }
    }
    
    return 1;
}
#include "api.h"
#include "wiiauto/common/common.h"
#include <objc/runtime.h>
#import <dlfcn.h>
#import <MobileCoreServices/MobileCoreServices.h>

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
                        if(mcmmetadata && [mcmmetadata isEqualToString:appName])
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

@interface MCMContainer : NSObject
+ (instancetype)containerWithIdentifier:(NSString *)identifier createIfNecessary:(BOOL)createIfNecessary existed:(BOOL *)existed error:(NSError **)error;
- (NSURL *)url;
@end

@interface MCMAppDataContainer : MCMContainer
@end

@interface MCMPluginKitPluginDataContainer : MCMContainer
@end

@interface LSApplicationWorkspace : NSObject
+ (LSApplicationWorkspace *)defaultWorkspace;
- (BOOL)installApplication:(NSURL *)path withOptions:(NSDictionary *)options;
- (BOOL)uninstallApplication:(NSString *)identifier withOptions:(NSDictionary *)options;
- (BOOL)applicationIsInstalled:(NSString *)appIdentifier;
- (NSArray *)allInstalledApplications;
- (NSArray *)allApplications;
- (NSArray *)applicationsOfType:(unsigned int)appType; // 0 for user, 1 for system
@end

@interface LSApplicationProxy : NSObject
+ (LSApplicationProxy *)applicationProxyForIdentifier:(id)appIdentifier;
@property(readonly) NSString * applicationIdentifier;
@property(readonly) NSString * bundleVersion;
@property(readonly) NSString * bundleExecutable;
@property(readonly) NSArray * deviceFamily;
@property(readonly) NSURL * bundleContainerURL;
@property(readonly) NSString * bundleIdentifier;
@property(readonly) NSURL * bundleURL;
@property(readonly) NSURL * containerURL;
@property(readonly) NSURL * dataContainerURL;
@property(readonly) NSString * localizedShortName;
@property(readonly) NSString * localizedName;
@property(readonly) NSString * shortVersionString;
@end

int wiiauto_lua_get_app_info(lua_State *ls)
{
    static int __flag__ = 0;
    if (!__flag__) {
        __flag__ = 1;
        dlopen("/System/Library/PrivateFrameworks/MobileContainerManager.framework/MobileContainerManager", RTLD_NOW);
    }  

#if WIIAUTO_DEBUG_LUA_API == 1
    printf("wiiauto_lua_get_app_info_start\n");
#endif
    const char *idf = "";
    const char *ptr;
    u8 success = 0;

    idf = luaL_optstring(ls, 1, "");    

    if (strlen(idf) > 0) {        

        @try {
            Class LSApplicationWorkspace_class = objc_getClass("LSApplicationWorkspace");
            if (LSApplicationWorkspace_class) {
                LSApplicationWorkspace *workspace = [LSApplicationWorkspace_class performSelector:@selector(defaultWorkspace)];
                if (workspace && [workspace applicationIsInstalled:[NSString stringWithUTF8String:idf]]) {
                    Class LSApplicationProxy_class = objc_getClass("LSApplicationProxy");
                    if (LSApplicationProxy_class) {
                        LSApplicationProxy *app = [LSApplicationProxy_class applicationProxyForIdentifier:[NSString stringWithUTF8String:idf]];
                        if (app) {
                            
                            lua_newtable(ls);
                            success = 1;

                            @try {
                                ptr = app.localizedShortName ? [app.localizedShortName UTF8String] : "";
                            } @catch (NSException *e)
                            {
                                ptr = "";
                            }                
                            lua_pushstring(ls, ptr);
                            lua_setfield(ls, -2, "displayName");


                            @try {
                                ptr = app.dataContainerURL ? [app.dataContainerURL.absoluteString UTF8String] : "";
                            } @catch (NSException *e)
                            {
                                ptr = "";
                            }
                            NSString *full_path = nil;
                            if (strlen(ptr) == 0) {
                                @try {
                                    MCMContainer *appContainer = [objc_getClass("MCMAppDataContainer") containerWithIdentifier:[NSString stringWithUTF8String:idf] createIfNecessary:NO existed:nil error:nil];
                                    NSString *containerPath = [appContainer url].path;
                                    full_path = [NSString stringWithFormat:@"file://%@", containerPath];
                                    ptr = [full_path UTF8String];
                                } @catch (NSException *e) {

                                }
                            }      
                            // ptr = "";
                            // NSString *ctp = nil;
                            // @try {
                            //     NSString *dir = @"/private/var/mobile/Containers/Data/Application/";
                            //     ctp = __findFolder([NSString stringWithUTF8String:idf], dir);
                            //     if (ctp) {
                            //         full_path = [NSString stringWithFormat:@"file://%@/", ctp];
                            //         ptr = [full_path UTF8String];
                            //     }
                            // } @catch (NSException *e) {
                            //     ptr = "";
                            // }             

                            lua_pushstring(ls, ptr);
                            lua_setfield(ls, -2, "dataContainerPath");
                            full_path = nil;


                            @try {
                                ptr = app.bundleContainerURL ? [app.bundleContainerURL.absoluteString UTF8String] : "";
                            } @catch (NSException *e)
                            {
                                ptr = "";
                            }                              
                            lua_pushstring(ls, ptr);
                            lua_setfield(ls, -2, "bundleContainerPath");


                            NSString *nnurl = @"";
                            @try {
                                if (app.bundleURL && app.bundleExecutable) {

                                    NSString *surl = app.bundleURL.absoluteString;
                                    surl = [surl stringByReplacingOccurrencesOfString: @"%20" withString:@" "];
                                    nnurl = [NSString stringWithFormat:@"%@/%@", surl, app.bundleExecutable];
                                } else {
                                    nnurl = @"";
                                }
                            } @catch (NSException *e) {
                                nnurl = @"";
                            }

                            @try {
                                ptr = [nnurl UTF8String];
                            } @catch (NSException *e)
                            {
                                ptr = "";
                            }   
                            lua_pushstring(ls, ptr);
                            lua_setfield(ls, -2, "executablePath");  

                            nnurl = nil;                           
                        }
                    }
                    LSApplicationProxy_class = nil;
                }
                workspace = nil;
            }
            LSApplicationWorkspace_class = nil;
        } @catch (NSException *e) 
        {
        }

        if (!success) {
            lua_pushnil(ls);
        }

    } else {
        lua_pushnil(ls);
    }
#if WIIAUTO_DEBUG_LUA_API == 1
    printf("wiiauto_lua_get_app_info_end\n");
#endif
    return 1;
}
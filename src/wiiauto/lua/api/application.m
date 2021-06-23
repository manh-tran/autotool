#include "api.h"
#include "wiiauto/util/util.h"

#import <Foundation/Foundation.h>
#include <notify.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <objc/runtime.h>
#import <dlfcn.h>
#import <MobileCoreServices/MobileCoreServices.h>

@interface MCMContainer : NSObject
+ (instancetype)containerWithIdentifier:(NSString *)identifier createIfNecessary:(BOOL)createIfNecessary existed:(BOOL *)existed error:(NSError **)error;
- (NSURL *)url;
@end

@interface MCMAppDataContainer : MCMContainer
@end

@interface MCMPluginKitPluginDataContainer : MCMContainer
@end

@interface LSApplicationWorkspace : NSObject
+ (id)defaultWorkspace;
- (BOOL)_LSPrivateRebuildApplicationDatabasesForSystemApps:(BOOL)arg1 internal:(BOOL)arg2 user:(BOOL)arg3;
- (BOOL)registerApplicationDictionary:(NSDictionary *)applicationDictionary;
- (BOOL)registerBundleWithInfo:(NSDictionary *)bundleInfo options:(NSDictionary *)options type:(unsigned long long)arg3 progress:(id)arg4 ;
- (BOOL)registerApplication:(NSURL *)url;
- (BOOL)registerPlugin:(NSURL *)url;
- (BOOL)unregisterApplication:(NSURL *)url;
- (NSArray *)installedPlugins;
-(void)_LSPrivateSyncWithMobileInstallation;
@end

static void __init()
{
    static int c = 0;
    if (!c) {
        dlopen("/System/Library/PrivateFrameworks/MobileContainerManager.framework/MobileContainerManager", RTLD_NOW);
        c = 1;
    }
}

int wiiauto_lua_register_application(lua_State *ls)
{
    __init();

    const char *app_path = luaL_optstring(ls, 1, NULL);
    if (!app_path) {
        lua_pushboolean(ls, 0);
        return 1;
    }

    int success = 0;

    @autoreleasepool {

        @try {
            NSString *path = [NSString stringWithUTF8String:app_path];
            NSDictionary *infoPlist = [NSDictionary dictionaryWithContentsOfFile:[path stringByAppendingPathComponent:@"Info.plist"]];
            NSString *bundleID = [infoPlist objectForKey:@"CFBundleIdentifier"];

            NSURL *url = [NSURL fileURLWithPath:path];
            LSApplicationWorkspace *workspace = [LSApplicationWorkspace defaultWorkspace];
            if (bundleID) {

                MCMContainer *appContainer = [objc_getClass("MCMAppDataContainer") containerWithIdentifier:bundleID createIfNecessary:YES existed:nil error:nil];
                NSString *containerPath = [appContainer url].path;

                NSMutableDictionary *plist = [NSMutableDictionary dictionary];
                [plist setObject:@"User" forKey:@"ApplicationType"];
                [plist setObject:@1 forKey:@"BundleNameIsLocalized"];
                [plist setObject:bundleID forKey:@"CFBundleIdentifier"];
                [plist setObject:@0 forKey:@"CompatibilityState"];
                if (containerPath)
                    [plist setObject:containerPath forKey:@"Container"];
                [plist setObject:@{
                    @"CFFIXED_USER_HOME" : containerPath,
                    @"HOME" : containerPath,
                    @"TMPDIR" : [containerPath stringByAppendingPathComponent:@"tmp"]
                } forKey:@"EnvironmentVariables"];
                [plist setObject:@1 forKey:@"IsDeletable"];
                [plist setObject:path forKey:@"Path"];

                NSString *pluginsPath = [path stringByAppendingPathComponent:@"PlugIns"];
                NSArray *plugins = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:pluginsPath error:nil];

                NSMutableDictionary *bundlePlugins = [NSMutableDictionary dictionary];
                for (NSString *pluginName in plugins){
                    NSString *fullPath = [pluginsPath stringByAppendingPathComponent:pluginName];

                    NSDictionary *infoPlist = [NSDictionary dictionaryWithContentsOfFile:[fullPath stringByAppendingPathComponent:@"Info.plist"]];
                    NSString *pluginBundleID = [infoPlist objectForKey:@"CFBundleIdentifier"];
                    if (!pluginBundleID)
                        continue;
                    
                    MCMContainer *pluginContainer = [objc_getClass("MCMPluginKitPluginDataContainer") containerWithIdentifier:pluginBundleID createIfNecessary:YES existed:nil error:nil];
                    NSString *pluginContainerPath = [pluginContainer url].path;

                    NSMutableDictionary *pluginPlist = [NSMutableDictionary dictionary];
                    [pluginPlist setObject:@"PluginKitPlugin" forKey:@"ApplicationType"];
                    [pluginPlist setObject:@1 forKey:@"BundleNameIsLocalized"];
                    [pluginPlist setObject:pluginBundleID forKey:@"CFBundleIdentifier"];
                    [pluginPlist setObject:@0 forKey:@"CompatibilityState"];
                    if (pluginContainer) {
                        [pluginPlist setObject:pluginContainerPath forKey:@"Container"];
                    }
                    [pluginPlist setObject:fullPath forKey:@"Path"];
                    [pluginPlist setObject:bundleID forKey:@"PluginOwnerBundleID"];
                    [bundlePlugins setObject:pluginPlist forKey:pluginBundleID];
                }
                [plist setObject:bundlePlugins forKey:@"_LSBundlePlugins"];

                if (![workspace registerApplicationDictionary:plist]){
                    success = 0;
                } else {
                    success = 1;
                }   
            }
        } @catch (NSException *e) {
            success = 0;
        }
    }

    lua_pushboolean(ls, success);
    return 1;
}

int wiiauto_lua_unregister_application(lua_State *ls)
{
    __init();

    const char *app_path = luaL_optstring(ls, 1, NULL);
    if (!app_path) {
        return 0;
    }

    @autoreleasepool {

        NSString *path = [NSString stringWithUTF8String:app_path];
        NSURL *url = [NSURL fileURLWithPath:path];
        LSApplicationWorkspace *workspace = [LSApplicationWorkspace defaultWorkspace];
        if (![workspace unregisterApplication:url]){
            
        }

    }
    return 0;
}
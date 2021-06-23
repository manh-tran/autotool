#include "util.h"

#include <objc/runtime.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include "wiiauto/util/util.h"
#include "cherry/json/json.h"
#include "wiiauto/daemon/daemon.h"
#include "wiiauto/common/common.h"
#include "cherry/util/util.h"
#include "log/remote_log.h"

static void __kill_execute()
{
    i32 num[2];
    char buf[1024];
    i32 exec_pid = -1;

    FILE *fp = popen("ps -u root | grep Facebook_com.facebook", "r");
    if (fp) {
        while (fgets(buf, 1024, fp) != NULL) {
            if (!strstr(buf, "grep")) {
                util_strtovl(2, buf, num);
                exec_pid = num[1];             
            }
        }
        pclose(fp);
    }

    if (exec_pid >= 0) {
        sprintf(buf, "kill -9 %d", exec_pid);
        system(buf);    
    }
}

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

static void __add_app_clone(const char *bundle, const char *app_path)
{
    json_element e, e_bundle, e_tmp;
    const char *str;
    json_element_new(&e);
    json_element_load_file(e, DAEMON_FILE_APPS_MESSENGER_CLONED);

    json_object_require_object(e, bundle, &e_bundle);

    json_object_require_boolean_default(e_bundle, "installed", &e_tmp, 0);
    json_boolean_set(e_tmp, 1);

    json_object_require_string_default(e_bundle, "path", &e_tmp, "");
    json_string_set(e_tmp, app_path);

    json_element_save_file(e, DAEMON_FILE_APPS_MESSENGER_CLONED);
    release(e.iobj);
}

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

static NSString *__get_url(const char *curl)
{
    const char *ptr;
    const char *idf = curl;

    NSString *nnurl = nil;

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
                        
                            @try {
                                if (app.bundleURL) {

                                    // NSString *surl = app.bundleURL.absoluteString;
                                    NSString *surl = [app.bundleURL path];
                                    surl = [surl stringByReplacingOccurrencesOfString: @"%20" withString:@" "];
                                    nnurl = surl;
                                } else {
                                    nnurl = nil;
                                }
                            } @catch (NSException *e) {
                                nnurl = nil;
                            }                         
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
    }

    return nnurl;
}

static int __create_orig()
{
    int success = 0;
    int create = 0;
    struct stat s;
    char buf[2048];

    int err = stat("/private/var/mobile/Library/WiiAuto/Clone/Messenger_orig.app", &s);
    if(-1 == err) {
        create = 1;
    } else {
        success = 1;
    }

    if (create) {        
        NSString *url = __get_url("com.facebook.Messenger");
        if (url) {
            sprintf(buf, "cp -r %s /private/var/mobile/Library/WiiAuto/Clone/Messenger_orig.app", [url UTF8String]);
            system(buf);

            err = stat("/private/var/mobile/Library/WiiAuto/Clone/Messenger_orig.app", &s);
            if(-1 == err) {
            } else {
                success = 1;
            }
        }
    }

    return success;
}

static int __create_template()
{
    int success = 0;

    int create = 0;
    struct stat s;
    char buf[1024];

    int err = stat("/private/var/mobile/Library/WiiAuto/Clone/Messenger_template.app", &s);
    if(-1 == err) {
        create = 1;
    } else {
        success = 1;
    }

    if (create) {
        system("mkdir /private/var/mobile/Library/WiiAuto/Clone/Messenger_template.app");
        system("ln -s /private/var/mobile/Library/WiiAuto/Clone/Messenger_orig.app/* /private/var/mobile/Library/WiiAuto/Clone/Messenger_template.app/");
        system("rm /private/var/mobile/Library/WiiAuto/Clone/Messenger_template.app/Info.plist");
        system("rm /private/var/mobile/Library/WiiAuto/Clone/Messenger_template.app/Messenger");
        system("cp /private/var/mobile/Library/WiiAuto/Clone/Messenger_orig.app/Info.plist /private/var/mobile/Library/WiiAuto/Clone/Messenger_template.app/Info.plist");
        system("cp /private/var/mobile/Library/WiiAuto/Clone/Messenger_orig.app/Messenger /private/var/mobile/Library/WiiAuto/Clone/Messenger_template.app/Messenger");

        success = 1;
    }

    return success;
}

static void __fetch_arr_ids(NSMutableArray *arr, NSMutableArray *out, int *count);
static void __fetch_ids(NSMutableDictionary *dict, NSMutableArray *out, int *count);

static void __fetch_arr_ids(NSMutableArray *arr, NSMutableArray *out, int *count)
{
    NSData *d;
    NSString *bundle;
    NSMutableDictionary *dict;
    NSString *listType;
    int i;
    int sc;

    for (i = 0; i < [arr count]; ++i) {
        d = arr[i];

        if ([d isKindOfClass:[NSString class]]) {
            bundle = (NSString *)d;
            if ([bundle isEqualToString:@"com.facebook.Messenger"]) {
                *count += 1;
            } else {
                if ([bundle containsString:@"com.facebook.Messenger"]) {
                    [out addObject:[NSString stringWithString:bundle]];
                    [arr removeObjectAtIndex:i];
                    i--;
                } else {
                    *count += 1;
                }
            }
        } else if ([d isKindOfClass:[NSDictionary class]]) {
            dict = ((NSDictionary *)d).mutableCopy;

            @try {
                listType = dict[@"listType"];
            } @catch (NSException *e) {
                listType = nil;
            }

            if (listType && [listType isEqualToString:@"folder"]) {
                
                sc = 0;
                __fetch_ids(dict, out, &sc);
                if (sc == 0) {
                    [arr removeObjectAtIndex:i];
                    i--;
                }
                *count += sc;
            }
        }
    }
}

static void __fetch_ids(NSMutableDictionary *dict, NSMutableArray *out, int *count)
{
    int i;
    int sc;

    NSMutableArray *iconLists = ((NSArray *)dict[@"iconLists"]).mutableCopy;
    for (int i = 0; i < [iconLists count]; ++i) {
        NSMutableArray *item = ((NSArray *)iconLists[i]).mutableCopy;
        sc = 0;
        __fetch_arr_ids(item, out, &sc);
        if (sc == 0) {
            [iconLists removeObjectAtIndex:i];
            i--;
        } else {
            iconLists[i] = item;
        }
        *count += sc;
    }

    dict[@"iconLists"] = iconLists;
}

static NSMutableDictionary *__create_folder(const int index, const char *name)
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    NSMutableArray *iconLists;

    dict[@"listType"] = @"folder";
    dict[@"displayName"] = [NSString stringWithFormat:@"MS:%s", name];

    iconLists = [NSMutableArray array];
    iconLists[0] = [NSMutableArray array];
    dict[@"iconLists"] = iconLists;

    return dict;
}

static void __add_messenger_ids(NSMutableDictionary *dict, NSArray *out)
{
    int i, j, sc;
    NSMutableDictionary *folder;
    NSMutableArray *folder_iconLists, *folder_item;
    char buf[256];

    @try {
        NSMutableArray *iconLists = ((NSArray *)dict[@"iconLists"]).mutableCopy;
        NSMutableArray *item = ((NSArray *)iconLists[0]).mutableCopy;
        NSMutableArray *temp_item = [NSMutableArray array];
        
        j = 1;

        sprintf(buf,"1-9");
        folder = __create_folder(j, buf);
        folder_iconLists = (NSMutableArray *)folder[@"iconLists"];
        folder_item = (NSMutableArray *)folder_iconLists[0];
        sc = 0;

        // for (i = [out count] - 1; i >= 0; i--) {
        for (i = 0; i <  [out count]; ++i) {
            if (sc == 0) {
                [temp_item insertObject:folder atIndex:0];
            }

            // [folder_item insertObject:out[i] atIndex:0];
            [folder_item addObject:out[i]];

            sc++;
            if (sc == 9) {
                j++;
                sprintf(buf, "%d-%d", (j - 1) * 9 + 1, j * 9);
                folder = __create_folder(j, buf);
                folder_iconLists = (NSMutableArray *)folder[@"iconLists"];
                folder_item = (NSMutableArray *)folder_iconLists[0];
                sc = 0;
            }
        }

        for (i = 0; i < [temp_item count]; ++i) {
            [item insertObject:temp_item[i] atIndex:0];
        }

        iconLists[0] = item;
        dict[@"iconLists"] = iconLists;

    } @catch (NSException *e) {

    }
}

int wiiauto_util_clone_messenger(const char *bundle_id, const unsigned char group)
{
    int ret;
    const char *bundle;
    char buf[2048];
    int exist = 0;
    NSString *b0, *b1, *b2;

    @autoreleasepool {
        ret = __create_orig();
        if (!ret) {
            ret = -1;
            goto finish;
        }

        ret = __create_template();
        if (!ret) {
            ret = -1;
            goto finish;
        }

        bundle = bundle_id;

        NSString *path = __get_url(bundle);
        if (path) {
            ret = 0;
            goto finish;
        }

        b0 = [NSString stringWithUTF8String:bundle];
        b1 = [b0 stringByReplacingOccurrencesOfString: @"com.facebook.Messenger" withString:@""];
        b2 = [b1 stringByReplacingOccurrencesOfString: @"." withString:@""];
        b1 = [b1 stringByReplacingOccurrencesOfString: @"." withString:@"_"];

        {

            /* change app info */
            @try {
                NSString* path = @"/private/var/mobile/Library/WiiAuto/Clone/Messenger_template.app/Info.plist";
                NSMutableDictionary* dict = [NSDictionary dictionaryWithContentsOfFile:path].mutableCopy; 
                
                dict[@"CFBundleName"] = [NSString stringWithFormat:@"Messenger%@", b1];
                dict[@"CFBundleDisplayName"] = [NSString stringWithFormat:@"MS%@", b1];
                dict[@"ApplicationIdentifier"] = [NSString stringWithFormat:@"T84QZS65DQ.com.facebook.Messenger%@", b2];
                // dict[@"ApplicationIdentifier"] = [NSString stringWithFormat:@"T84QZS65DQ.com.facebook.Messenger", i];
                dict[@"CFBundleIdentifier"] = [NSString stringWithFormat:@"%@", b0];
                dict[@"FBKeychainAccessGroup"] = [NSString stringWithFormat:@"T84QZS65DQ.platformFamily%@", b2];
                dict[@"FBAppGroup"] = [NSString stringWithFormat:@"group.com.facebook.Messenger%@", b2];

                [dict writeToFile:@"/private/var/mobile/Library/WiiAuto/Clone/Messenger_template.app/Info.plist" atomically:YES];
                dict = nil;
            } @catch (NSException *e) {
            }

            /* copy app */
            sprintf(buf, "cp -r /private/var/mobile/Library/WiiAuto/Clone/Messenger_template.app /Applications/Messenger_%s.app", [b0 UTF8String]);
            system(buf);

            /* active app resources */
            if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"11.0")) {
                sprintf(buf, "/Applications/Messenger_%s.app/Messenger", [b0 UTF8String]);
                system(buf);
                system(buf);
                system(buf);
                system(buf);
                system(buf);
            } else {
                sprintf(buf, "/Applications/Messenger_%s.app/Messenger &", [b0 UTF8String]);
                system(buf);
                usleep(0.25 * 1000000);
                __kill_execute();

                system(buf);
                usleep(0.25 * 1000000);
                __kill_execute();

                system(buf);
                usleep(0.25 * 1000000);
                __kill_execute();

                system(buf);
                usleep(0.25 * 1000000);
                __kill_execute();
                __kill_execute();
                __kill_execute();
            }

            /* sign app */
            @try {
                NSString* path = @"/var/mobile/Library/WiiAuto/Entitlements/messenger.xml";
                NSMutableDictionary* dict = [NSDictionary dictionaryWithContentsOfFile:path].mutableCopy; 

                {
                    NSMutableArray *arr = [NSMutableArray array];
                    [arr addObject:[NSString stringWithFormat:@"T84QZS65DQ.platformFamily%@", b2]];
                    dict[@"keychain-access-groups"] = arr;
                }  
                {
                    NSMutableArray *arr = [NSMutableArray array];
                    [arr addObject:[NSString stringWithFormat:@"group.com.facebook.Messenger%@", b2]];
                    [arr addObject:[NSString stringWithFormat:@"group.com.facebook.family%@", b2]];
                    dict[@"com.apple.security.application-groups"] = arr;
                }  
                // {
                //     NSMutableArray *arr = [NSMutableArray array];
                //     [arr addObject:[NSString stringWithFormat:@"V9WTTPBFK9.com.facebook.Wilde%@", b2]];
                //     dict[@"com.apple.developer.ubiquity-kvstore-identifier"] = arr;
                // }    
                dict[@"application-identifier"] = [NSString stringWithFormat:@"T84QZS65DQ.com.facebook.Messenger%@", b2];        

                [dict writeToFile:@"/var/mobile/Library/WiiAuto/Entitlements/messenger.xml" atomically:YES];
                dict = nil;
            } @catch (NSException *e) {
            }

            if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"11.0")) {
                sprintf(buf, "ldid -S/var/mobile/Library/WiiAuto/Entitlements/messenger.xml /Applications/Messenger_%s.app", [b0 UTF8String]);
            } else {
                sprintf(buf, "ldid -S/var/mobile/Library/WiiAuto/Entitlements/messenger.xml /Applications/Messenger_%s.app/Messenger", [b0 UTF8String]);
            }
            system(buf);

            sprintf(buf, "/Applications/Messenger_%s.app", [b0 UTF8String]);
            __add_app_clone(bundle_id, buf);
            
        }

        sprintf(buf, "/Applications/Messenger_%s.app", [b0 UTF8String]);
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"11.0")) {
            wiiauto_util_uicache(buf);
        } else {
            system("uicache");
        }

        /* group app folder */
        if (group) {
            @try {
                NSString* path = @"/private/var/mobile/Library/SpringBoard/IconState.plist";
                NSMutableDictionary* dict = [NSDictionary dictionaryWithContentsOfFile:path].mutableCopy; 

                NSMutableArray *ids = [NSMutableArray array];
                /* get all facebook ids */
                int count = 0;
                __fetch_ids(dict, ids, &count);
                
                exist = 0;
                for (int i = 0; i < [ids count]; ++i) {
                    NSString *cc = ids[i];
                    if ([cc isEqualToString:b0]) {
                        exist = 1;
                        break;
                    }
                }
                if (!exist) {
                    [ids addObject:b0];
                }

                ids = [ids sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                    return [(NSString *)obj1 compare:(NSString *)obj2 options:NSNumericSearch];
                }];

                /* insert facebook ids */
                __add_messenger_ids(dict, ids);

                NSError *err;
                NSDictionary* dict2 = [NSPropertyListSerialization dataFromPropertyList:dict
                    format:NSPropertyListBinaryFormat_v1_0
                    errorDescription:&err];
                [dict2 writeToFile:@"/private/var/mobile/Library/SpringBoard/DesiredIconState.plist" atomically:YES];
                [dict2 writeToFile:@"/private/var/mobile/Library/SpringBoard/IconState.plist" atomically:YES];
                dict = nil;
                dict2 = nil;
                system("killall -9 SpringBoard");

                ret = 1;
            } @catch (NSException *e) {
                ret = -1;
            }
        } else {
            ret = 1;
        }        
    }

finish:
    return ret;
}

int wiiauto_util_remove_clone_messenger(const char *bundle)
{
    json_element e, e_bundle, e_tmp;
    const char *str;
    char buf[1024];

    json_element_new(&e);
    json_element_load_file(e, DAEMON_FILE_APPS_MESSENGER_CLONED);

    json_object_require_object(e, bundle, &e_bundle);

    json_object_require_string_default(e_bundle, "path", &e_tmp, "");
    json_string_get_ptr(e_tmp, &str);

    if (str && (strlen(str) > 0) && (strstr(str, "/Applications/Messenger_"))) {
        sprintf(buf, "rm -rf %s", str);
        system(buf);
        wiiauto_util_unregister_app(str);

        json_object_remove(e, bundle);
        json_element_save_file(e, DAEMON_FILE_APPS_MESSENGER_CLONED);
    }
    
    release(e.iobj);

    return 1;
}

void wiiauto_util_remove_all_clone_messenger()
{
    json_element e, e_bundle, e_tmp;
    const char *str, *bundle;
    char buf[1024];
    i32 i;

    json_element_new(&e);
    json_element_load_file(e, DAEMON_FILE_APPS_MESSENGER_CLONED);
    json_element_make_object(e);

    i = 0;
    json_object_iterate(e, i, &bundle, &e_bundle);
    while (id_validate(e_bundle.iobj)) {

        json_object_require_string_default(e_bundle, "path", &e_tmp, "");
        json_string_get_ptr(e_tmp, &str);

        if (str && (strlen(str) > 0) && (strstr(str, "/Applications/Messenger_"))) {
            sprintf(buf, "rm -rf %s", str);
            system(buf);
            wiiauto_util_unregister_app(str);
        }

        i++;
        json_object_iterate(e, i, &str, &e_bundle);
    }
    release(e.iobj);

    json_element_new(&e);
    json_element_make_object(e);
    json_element_save_file(e, DAEMON_FILE_APPS_MESSENGER_CLONED);
    release(e.iobj);
}
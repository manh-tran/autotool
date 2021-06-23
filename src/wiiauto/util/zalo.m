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

static void __kill_execute()
{
    i32 num[2];
    char buf[1024];
    i32 exec_pid = -1;

    FILE *fp = popen("ps -u root | grep Zalo_", "r");
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
    json_element_load_file(e, DAEMON_FILE_APPS_ZALO_CLONED);

    json_object_require_object(e, bundle, &e_bundle);

    json_object_require_boolean_default(e_bundle, "installed", &e_tmp, 0);
    json_boolean_set(e_tmp, 1);

    json_object_require_string_default(e_bundle, "path", &e_tmp, "");
    json_string_set(e_tmp, app_path);

    json_element_save_file(e, DAEMON_FILE_APPS_ZALO_CLONED);
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

    int err = stat("/private/var/mobile/Library/WiiAuto/Clone/Zalo_orig.app", &s);
    if(-1 == err) {
        create = 1;
    } else {
        success = 1;
    }

    if (create) {        
        NSString *url = __get_url("vn.com.vng.zingalo");
        if (url) {
            sprintf(buf, "cp -r %s /private/var/mobile/Library/WiiAuto/Clone/Zalo_orig.app", [url UTF8String]);
            system(buf);

            err = stat("/private/var/mobile/Library/WiiAuto/Clone/Zalo_orig.app", &s);
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

    int err = stat("/private/var/mobile/Library/WiiAuto/Clone/Zalo_template.app", &s);
    if(-1 == err) {
        create = 1;
    } else {
        success = 1;
    }

    if (create) {
        system("mkdir /private/var/mobile/Library/WiiAuto/Clone/Zalo_template.app");
        system("ln -s /private/var/mobile/Library/WiiAuto/Clone/Zalo_orig.app/* /private/var/mobile/Library/WiiAuto/Clone/Zalo_template.app/");
        system("rm /private/var/mobile/Library/WiiAuto/Clone/Zalo_template.app/Info.plist");
        system("rm /private/var/mobile/Library/WiiAuto/Clone/Zalo_template.app/Zalo");
        system("cp /private/var/mobile/Library/WiiAuto/Clone/Zalo_orig.app/Info.plist /private/var/mobile/Library/WiiAuto/Clone/Zalo_template.app/Info.plist");
        system("cp /private/var/mobile/Library/WiiAuto/Clone/Zalo_orig.app/Zalo /private/var/mobile/Library/WiiAuto/Clone/Zalo_template.app/Zalo");

        success = 1;
    }

    return success;
}

int wiiauto_util_clone_zalo(const char *bundle_id, const unsigned char group)
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
        b1 = [b0 stringByReplacingOccurrencesOfString: @"vn.com.vng.zingalo" withString:@""];
        b2 = [b1 stringByReplacingOccurrencesOfString: @"." withString:@""];
        b1 = [b1 stringByReplacingOccurrencesOfString: @"." withString:@"_"];

        {

            /* change app info */
            @try {
                NSString* path = @"/private/var/mobile/Library/WiiAuto/Clone/Zalo_template.app/Info.plist";
                NSMutableDictionary* dict = [NSDictionary dictionaryWithContentsOfFile:path].mutableCopy; 
                
                dict[@"CFBundleName"] = [NSString stringWithFormat:@"Zalo%@", b1];
                dict[@"CFBundleDisplayName"] = [NSString stringWithFormat:@"Zalo%@", b1];
                dict[@"ApplicationIdentifier"] = [NSString stringWithFormat:@"CVB6BX97VM.vn.com.vng.zingalo%@", b2];
                dict[@"CFBundleIdentifier"] = [NSString stringWithFormat:@"%@", b0];

                [dict writeToFile:@"/private/var/mobile/Library/WiiAuto/Clone/Zalo_template.app/Info.plist" atomically:YES];
                dict = nil;
            } @catch (NSException *e) {
            }

            /* copy app */
            sprintf(buf, "cp -r /private/var/mobile/Library/WiiAuto/Clone/Zalo_template.app /Applications/Zalo_%s.app", [b0 UTF8String]);
            system(buf);

            /* active app resources */
            if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"11.0")) {
                sprintf(buf, "/Applications/Zalo_%s.app/Zalo", [b0 UTF8String]);
                system(buf);
                system(buf);
                system(buf);
                system(buf);
                system(buf);
            } else {
                sprintf(buf, "/Applications/Zalo_%s.app/Zalo &", [b0 UTF8String]);
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
                NSString* path = @"/var/mobile/Library/WiiAuto/Entitlements/zalo.xml";
                NSMutableDictionary* dict = [NSDictionary dictionaryWithContentsOfFile:path].mutableCopy; 
 
                dict[@"application-identifier"] = [NSString stringWithFormat:@"CVB6BX97VM.vn.com.vng.zingalo%@", b2];        

                [dict writeToFile:@"/var/mobile/Library/WiiAuto/Entitlements/zalo.xml" atomically:YES];
                dict = nil;
            } @catch (NSException *e) {
            }

            if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"11.0")) {
                sprintf(buf, "ldid -S/var/mobile/Library/WiiAuto/Entitlements/zalo.xml /Applications/Zalo_%s.app", [b0 UTF8String]);
            } else {
                sprintf(buf, "ldid -S/var/mobile/Library/WiiAuto/Entitlements/zalo.xml /Applications/Zalo_%s.app/Zalo", [b0 UTF8String]);
            }
            system(buf);

            sprintf(buf, "/Applications/Zalo_%s.app", [b0 UTF8String]);
            __add_app_clone(bundle_id, buf);
            
        }

        sprintf(buf, "/Applications/Zalo_%s.app", [b0 UTF8String]);
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"11.0")) {
            wiiauto_util_uicache(buf);
        } else {
            system("uicache");
        }

        ret = 1;

        // /* group app folder */
        // if (group) {
        //     @try {
        //         NSString* path = @"/private/var/mobile/Library/SpringBoard/IconState.plist";
        //         NSMutableDictionary* dict = [NSDictionary dictionaryWithContentsOfFile:path].mutableCopy; 

        //         NSMutableArray *ids = [NSMutableArray array];
        //         /* get all facebook ids */
        //         int count = 0;
        //         __fetch_ids(dict, ids, &count);
                
        //         exist = 0;
        //         for (int i = 0; i < [ids count]; ++i) {
        //             NSString *cc = ids[i];
        //             if ([cc isEqualToString:b0]) {
        //                 exist = 1;
        //                 break;
        //             }
        //         }
        //         if (!exist) {
        //             [ids addObject:b0];
        //         }

        //         ids = [ids sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        //             return [(NSString *)obj1 compare:(NSString *)obj2 options:NSNumericSearch];
        //         }];

        //         /* insert facebook ids */
        //         __add_fb_ids(dict, ids);

        //         NSError *err;
        //         NSDictionary* dict2 = [NSPropertyListSerialization dataFromPropertyList:dict
        //             format:NSPropertyListBinaryFormat_v1_0
        //             errorDescription:&err];
        //         [dict2 writeToFile:@"/private/var/mobile/Library/SpringBoard/DesiredIconState.plist" atomically:YES];
        //         [dict2 writeToFile:@"/private/var/mobile/Library/SpringBoard/IconState.plist" atomically:YES];
        //         dict = nil;
        //         dict2 = nil;
        //         system("killall -9 SpringBoard");

        //         ret = 1;
        //     } @catch (NSException *e) {
        //         ret = -1;
        //     }
        // } else {
        //     ret = 1;
        // }        
    }

finish:
    return ret;
}

int wiiauto_util_remove_clone_zalo(const char *bundle)
{
    json_element e, e_bundle, e_tmp;
    const char *str;
    char buf[1024];

    json_element_new(&e);
    json_element_load_file(e, DAEMON_FILE_APPS_ZALO_CLONED);

    json_object_require_object(e, bundle, &e_bundle);

    json_object_require_string_default(e_bundle, "path", &e_tmp, "");
    json_string_get_ptr(e_tmp, &str);

    if (str && (strlen(str) > 0) && (strstr(str, "/Applications/Zalo_"))) {
        sprintf(buf, "rm -rf %s", str);
        system(buf);
        wiiauto_util_unregister_app(str);

        json_object_remove(e, bundle);
        json_element_save_file(e, DAEMON_FILE_APPS_ZALO_CLONED);
    }
    
    release(e.iobj);

    return 1;
}

void wiiauto_util_remove_all_clone_zalo()
{
    json_element e, e_bundle, e_tmp;
    const char *str, *bundle;
    char buf[1024];
    i32 i;

    json_element_new(&e);
    json_element_load_file(e, DAEMON_FILE_APPS_ZALO_CLONED);

    json_element_make_object(e);

    i = 0;
    json_object_iterate(e, i, &bundle, &e_bundle);
    while (id_validate(e_bundle.iobj)) {

        json_object_require_string_default(e_bundle, "path", &e_tmp, "");
        json_string_get_ptr(e_tmp, &str);

        if (str && (strlen(str) > 0) && (strstr(str, "/Applications/Zalo_"))) {
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
    json_element_save_file(e, DAEMON_FILE_APPS_ZALO_CLONED);
    release(e.iobj);
}
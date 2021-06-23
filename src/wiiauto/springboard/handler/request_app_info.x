#include "request_app_info.h"
#include "wiiauto/device/device.h"
#include "log/remote_log.h"

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

@interface FBApplicationInfo

-(NSURL *)dataContainerURL;
-(NSURL *)bundleContainerURL;
-(NSURL *)executableURL;
-(NSURL *)sandboxURL;

@end

@interface SBApplicationInfo : FBApplicationInfo

-(NSString *)displayName;

@end

@interface SBApplication

-(SBApplicationInfo *)info;

@end

@interface SBApplicationController : NSObject

+(SBApplicationController *) sharedInstance;
-(SBApplication *) applicationWithDisplayIdentifier:(NSString *)bundleIdentifier;
-(SBApplication *) applicationWithBundleIdentifier:(NSString *)bundleIdentifier;
-(NSArray *) applicationsWithBundleIdentifier:(NSString *)bundleIdentifier;
@end

CFDataRef springboard_handle_request_app_info(const __wiiauto_event_request_app_info *input)
{
    SBApplicationController* ctl = nil;
    SBApplication *application = nil;
    SBApplicationInfo *info;
    const char *ptr;
    __wiiauto_event_result_app_info rt;
    u8 success = 0;

    __wiiauto_event_result_app_info_init(&rt);

    @try {
        Class LSApplicationWorkspace_class = objc_getClass("LSApplicationWorkspace");
        if (LSApplicationWorkspace_class) {
            LSApplicationWorkspace *workspace = [LSApplicationWorkspace_class performSelector:@selector(defaultWorkspace)];
            if (workspace && [workspace applicationIsInstalled:[NSString stringWithUTF8String:input->bundle]]) {
                Class LSApplicationProxy_class = objc_getClass("LSApplicationProxy");
                if (LSApplicationProxy_class) {
                    LSApplicationProxy *app = [LSApplicationProxy_class applicationProxyForIdentifier:[NSString stringWithUTF8String:input->bundle]];
                    if (app) {
                        ptr = app.localizedShortName ? [app.localizedShortName UTF8String] : NULL;
                        if (ptr) {
                            strcpy(rt.display_name, ptr);
                        }

                        ptr = app.dataContainerURL ? [app.dataContainerURL.absoluteString UTF8String] : NULL;
                        if (ptr) {
                            strcpy(rt.data_container_path, ptr);
                        }

                        ptr = app.bundleContainerURL ? [app.bundleContainerURL.absoluteString UTF8String] : NULL;
                        if (ptr ) {
                            strcpy(rt.bundle_container_path, ptr);
                        }

                        ptr = app.bundleExecutable ? [app.bundleExecutable UTF8String] : NULL;
                        if (ptr) {
                            strcpy(rt.executable_path, ptr);
                        }

                        success = 1;
                    }
                }
            }
        }        
    } @catch (NSException *e) {

    }

    if (success) goto finish;

    @try {
        ctl = [%c(SBApplicationController) sharedInstance];

        if ([ctl respondsToSelector:@selector(applicationsWithBundleIdentifier:)]) {
            NSArray *apps = [ctl applicationsWithBundleIdentifier: [NSString stringWithUTF8String:input->bundle]];
            if (apps && [apps count] > 0) {
                application = (SBApplication *)[apps objectAtIndex:0];
            }
        }

        if (!application && [ctl respondsToSelector:@selector(applicationWithBundleIdentifier:)]) {
            application = [ctl applicationWithBundleIdentifier:[NSString stringWithUTF8String:input->bundle]];          
        }
        
        if (!application && [ctl respondsToSelector:@selector(applicationWithDisplayIdentifier:)]) {
            application = [ctl applicationWithDisplayIdentifier:[NSString stringWithUTF8String:input->bundle]];
        }

        if (application) {
            info = [application info];

            ptr = [[info displayName] UTF8String];
            if (ptr) {
                strcpy(rt.display_name, ptr);
            }

            ptr = [[info dataContainerURL].absoluteString UTF8String];
            if (ptr) {
                strcpy(rt.data_container_path, ptr);
            }

            ptr = [[info bundleContainerURL].absoluteString UTF8String];
            if (ptr ) {
                strcpy(rt.bundle_container_path, ptr);
            }

            ptr = [[info executableURL].absoluteString UTF8String];
            if (ptr) {
                strcpy(rt.executable_path, ptr);
            }
        }
    }
    @catch (NSException *e)
    {
        application = nil;
    }

finish:
    return CFDataCreate(NULL, (const UInt8 *)&rt, sizeof(rt));
}
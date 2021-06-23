#include "handler.h"
#include <objc/runtime.h>
#import <dlfcn.h>
#import <MobileCoreServices/MobileCoreServices.h>

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
@property (nonatomic,readonly) NSString * applicationDSID; 
@property (nonatomic,readonly) NSNumber * purchaserDSID;
@property (nonatomic,readonly) NSNumber * downloaderDSID;    
@property (nonatomic,readonly) NSString * sourceAppIdentifier;
@property (nonatomic,readonly) NSString * applicationVariant;   
@property (nonatomic,readonly) NSString * storeCohortMetadata; 
@property (nonatomic,readonly) NSString * watchKitVersion;  
@end

void wiiauto_tool_run_test_app_proxy(const int argc, const char **argv)
{
    dlopen("/System/Library/PrivateFrameworks/MobileContainerManager.framework/MobileContainerManager", RTLD_NOW); 

    const char *idf;
    idf = argv[2];  

    if (strlen(idf) == 0) return;

    Class LSApplicationWorkspace_class = objc_getClass("LSApplicationWorkspace");
    LSApplicationWorkspace *workspace = [LSApplicationWorkspace_class performSelector:@selector(defaultWorkspace)];
    Class LSApplicationProxy_class = objc_getClass("LSApplicationProxy");
    LSApplicationProxy *app = [LSApplicationProxy_class applicationProxyForIdentifier:[NSString stringWithUTF8String:idf]];
    if (!app) return;

    if (app.applicationIdentifier) printf("applicationIdentitifer: %s\n", [app.applicationIdentifier UTF8String]);
    if (app.bundleVersion) printf("version: %s\n", [app.bundleVersion UTF8String]);
    if (app.bundleExecutable) printf("executable: %s\n", [app.bundleExecutable UTF8String]);
    if (app.bundleIdentifier) printf("identifier: %s\n", [app.bundleIdentifier UTF8String]);
    if (app.applicationDSID) printf("appDSID: %s\n", [app.applicationDSID UTF8String]);
    if (app.sourceAppIdentifier) printf("sourceAppIdentifier: %s\n", [app.sourceAppIdentifier UTF8String]);
    if (app.applicationVariant) printf("applicationVariant: %s\n", [app.applicationVariant UTF8String]);
    if (app.purchaserDSID) printf("purchaserDSID: %s\n", [[app.purchaserDSID stringValue] UTF8String]);
    if (app.downloaderDSID) printf("downloaderDSID: %s\n", [[app.downloaderDSID stringValue] UTF8String]);
    if (app.storeCohortMetadata) printf("storeCohortMetadata: %s\n", [app.storeCohortMetadata UTF8String]);
    if (app.watchKitVersion) printf("watchKitVersion: %s\n", [app.watchKitVersion UTF8String]);
    
}
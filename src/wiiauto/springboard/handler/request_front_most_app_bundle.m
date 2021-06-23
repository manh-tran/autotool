#include "request_front_most_app_bundle.h"

@interface SpringBoard : NSObject
-(id)_accessibilityFrontMostApplication;
@end

@interface SBApplication : NSObject
-(NSString *)bundleIdentifier;
@end

CFDataRef springboard_handle_request_front_most_app_bundle(const __wiiauto_event_request_front_most_app_bundle *input)
{   
    const char *bundle = NULL;
    __wiiauto_event_result_front_most_app_bundle rt;
    SBApplication *app;
    NSString *idr;
    
    @try {
        app = (SBApplication *)[(SpringBoard*)[UIApplication sharedApplication] _accessibilityFrontMostApplication];
    } @catch (NSException *e) {
        app = nil;
    }
    
    if (!app) goto finish;

    idr = [app bundleIdentifier];
    if (!idr) goto finish;

    bundle = [idr UTF8String];

finish:
    __wiiauto_event_result_front_most_app_bundle_init(&rt);
    if (bundle) {
        strcpy(rt.bundle, bundle);
    }
    return CFDataCreate(NULL, (const UInt8 *)&rt, sizeof(rt));
}
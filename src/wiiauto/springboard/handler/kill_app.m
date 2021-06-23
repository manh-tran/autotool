#include "kill_app.h"
#include "log/remote_log.h"
#include "wiiauto/device/device.h"

#import <BackBoardServices/BackBoardServices.h>

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

CFDataRef springboard_handle_kill_app(const __wiiauto_event_kill_app *input)
{

    @try {
        NSString *nsbundle = [NSString stringWithUTF8String:input->bundle];
        BKSTerminateApplicationForReasonAndReportWithDescription((__bridge CFStringRef)nsbundle, 1, 0, NULL);
        nsbundle = nil;
    } 
    @catch (NSException *exception) {
    
    }   

    return NULL;
}
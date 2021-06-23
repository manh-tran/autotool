#include "request_front_most_app_port.h"
#include "wiiauto/device/device.h"
#include <UIKit/UIKit.h>

/*
 * interfaces
 */

@interface CAWindowServer : NSObject
+ (CAWindowServer *)serverIfRunning;
- (NSArray *)displays;
@end

@interface CAWindowServerDisplay : NSObject
- (unsigned int)clientPortAtPosition:(struct CGPoint)position;
- (int) contextIdAtPosition:(CGPoint)position;
- (mach_port_t) taskPortOfContextId:(int)context;
@end

CFDataRef backboardd_handle_request_front_most_app_port(const __wiiauto_event_request_front_most_app_port *input)
{
    CGPoint point;
    int port = 0;

    __wiiauto_event_result_front_most_app_port evt;

    point.x = 100;
    point.y = 100;

    @try {
        if (CAWindowServer *server = [CAWindowServer serverIfRunning]) {
            NSArray *displays([server displays]);

            if (displays != nil && [displays count] != 0){
                if (CAWindowServerDisplay *display = [displays objectAtIndex:0]) { 
                    port = [display clientPortAtPosition:point];
                }
            }
        }
    } @catch (NSException *e) {

    }

    __wiiauto_event_result_front_most_app_port_init(&evt);
    evt.port = port;

    return CFDataCreate(NULL, (const UInt8 *)&evt, sizeof(evt));
}
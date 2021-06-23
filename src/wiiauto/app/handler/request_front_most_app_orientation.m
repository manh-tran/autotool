#include "request_front_most_app_orientation.h"
#include "wiiauto/device/device.h"

CFDataRef app_handle_request_front_most_app_orientation(const __wiiauto_event_request_front_most_app_orientation *input)
{
    __wiiauto_event_result_front_most_app_orientation evt;

    __wiiauto_event_result_front_most_app_orientation_init(&evt);

    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;

    if(orientation == 0) {
        evt.orientation = WIIAUTO_DEVICE_ORIENTATION_PORTRAIT;
    } else if(orientation == UIInterfaceOrientationPortrait) {
        evt.orientation = WIIAUTO_DEVICE_ORIENTATION_PORTRAIT;
    } else if(orientation == UIInterfaceOrientationPortraitUpsideDown) {
        evt.orientation = WIIAUTO_DEVICE_ORIENTATION_PORTRAIT_UPSIDE_DOWN;
    } else if(orientation == UIInterfaceOrientationLandscapeLeft) {
        evt.orientation = WIIAUTO_DEVICE_ORIENTATION_LANDSCAPE_LEFT;
    } else if(orientation == UIInterfaceOrientationLandscapeRight) {
        evt.orientation = WIIAUTO_DEVICE_ORIENTATION_LANDSCAPE_RIGHT;
    }

    return CFDataCreate(NULL, (const UInt8 *)&evt, sizeof(evt));
}
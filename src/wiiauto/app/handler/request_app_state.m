#include "request_app_state.h"
#include "wiiauto/device/device.h"

CFDataRef app_handle_request_app_state(const __wiiauto_event_request_app_state *input)
{
    __wiiauto_event_result_app_state evt;
    __wiiauto_event_result_app_state_init(&evt);

    switch([[UIApplication sharedApplication] applicationState]) {
        case UIApplicationStateActive:
            evt.state = WIIAUTO_APP_STATE_ACTIVE;
            break;
        default:
            evt.state = WIIAUTO_APP_STATE_INACTIVE;
            break;
    }

    return CFDataCreate(NULL, (const UInt8 *)&evt, sizeof(evt));
}
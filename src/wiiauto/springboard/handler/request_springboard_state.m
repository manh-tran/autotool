#include "request_springboard_state.h"
#include "wiiauto/device/device.h"

CFDataRef springboard_handle_request_springboard_state(const __wiiauto_event_request_springboard_state *input)
{
    __wiiauto_event_result_springboard_state evt;

    __wiiauto_event_result_springboard_state_init(&evt);
    evt.state = WIIAUTO_SPRINGBOARD_STATE_RUNNING;
    evt.pid = getpid();

    return CFDataCreate(NULL, (const UInt8 *)&evt, sizeof(evt));
}
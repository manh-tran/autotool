#include "request_daemon_state.h"
#include "wiiauto/device/device.h"

CFDataRef daemon_handle_request_daemon_state(const __wiiauto_event_request_daemon_state *input)
{
    __wiiauto_event_result_daemon_state evt;

    __wiiauto_event_result_daemon_state_init(&evt);
    evt.state = WIIAUTO_DAEMON_STATE_RUNNING;

    return CFDataCreate(NULL, (const UInt8 *)&evt, sizeof(evt));
}
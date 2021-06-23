#ifndef __wiiauto_daemon_handler_request_daemon_state_h
#define __wiiauto_daemon_handler_request_daemon_state_h

#if defined __cplusplus
extern "C" {
#endif

#include "wiiauto/event/event_daemon_state.h"

CFDataRef daemon_handle_request_daemon_state(const __wiiauto_event_request_daemon_state *input);

#if defined __cplusplus
}
#endif

#endif
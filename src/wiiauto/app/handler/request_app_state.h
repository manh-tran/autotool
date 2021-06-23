#ifndef __wiiauto_app_handler_request_app_state_h
#define __wiiauto_app_handler_request_app_state_h

#if defined __cplusplus
extern "C" {
#endif

#include "wiiauto/event/event_app_state.h"

CFDataRef app_handle_request_app_state(const __wiiauto_event_request_app_state *input);

#if defined __cplusplus
}
#endif

#endif
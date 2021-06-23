#ifndef __wiiauto_springboard_handler_set_status_bar_h
#define __wiiauto_springboard_handler_set_status_bar_h

#if defined __cplusplus
extern "C" {
#endif

#include "wiiauto/event/event_set_status_bar.h"

CFDataRef springboard_handle_set_status_bar(const __wiiauto_event_set_status_bar *input);
CFDataRef springboard_handle_set_status_bar_state(const __wiiauto_event_set_status_bar_state *input);

#if defined __cplusplus
}
#endif

#endif
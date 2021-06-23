#ifndef __wiiauto_springboard_handler_kill_app_h
#define __wiiauto_springboard_handler_kill_app_h

#if defined __cplusplus
extern "C" {
#endif

#include "wiiauto/event/event_kill_app.h"

CFDataRef springboard_handle_kill_app(const __wiiauto_event_kill_app *input);

#if defined __cplusplus
}
#endif

#endif
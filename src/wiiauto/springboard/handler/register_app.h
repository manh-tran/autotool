#ifndef __wiiauto_springboard_handler_register_app_h
#define __wiiauto_springboard_handler_register_app_h

#if defined __cplusplus
extern "C" {
#endif

#include "wiiauto/event/event_register_app.h"

CFDataRef springboard_handle_register_app(const __wiiauto_event_register_app *input);

#if defined __cplusplus
}
#endif

#endif
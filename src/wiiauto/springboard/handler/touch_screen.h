#ifndef __wiiauto_springboard_handler_touch_screen_h
#define __wiiauto_springboard_handler_touch_screen_h

#if defined __cplusplus
extern "C" {
#endif

#include "wiiauto/event/event_touch_screen.h"

CFDataRef springboard_handle_touch_screen(const __wiiauto_event_touch_screen *input);

#if defined __cplusplus
}
#endif

#endif
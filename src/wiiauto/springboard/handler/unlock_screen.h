#ifndef __wiiauto_springboard_handler_unlock_screen_h
#define __wiiauto_springboard_handler_unlock_screen_h

#if defined __cplusplus
extern "C" {
#endif

#include "wiiauto/event/event_unlock_screen.h"

CFDataRef springboard_handle_unlock_screen(const __wiiauto_event_unlock_screen *input);

#if defined __cplusplus
}
#endif

#endif
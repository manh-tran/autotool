#ifndef __wiiauto_springboard_handler_turn_on_screen_h
#define __wiiauto_springboard_handler_turn_on_screen_h

#if defined __cplusplus
extern "C" {
#endif

#include "wiiauto/event/event_turn_on_screen.h"

CFDataRef springboard_handle_turn_on_screen(const __wiiauto_event_turn_on_screen *input);

#if defined __cplusplus
}
#endif

#endif
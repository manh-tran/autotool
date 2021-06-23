#ifndef __wiiauto_springboard_handler_press_button_h
#define __wiiauto_springboard_handler_press_button_h

#if defined __cplusplus
extern "C" {
#endif

#include "wiiauto/event/event_press_button.h"

CFDataRef springboard_handle_press_button(const __wiiauto_event_press_button *input);

#if defined __cplusplus
}
#endif

#endif
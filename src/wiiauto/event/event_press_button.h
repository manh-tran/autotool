#ifndef __wiiauto_event_press_button_h
#define __wiiauto_event_press_button_h

#include "event.h"

#if defined __cplusplus
extern "C" {
#endif

typedef enum
{
    WIIAUTO_BUTTON_HOME = 1,
    WIIAUTO_BUTTON_LOCK,
    WIIAUTO_BUTTON_VOLUME_UP,    
    WIIAUTO_BUTTON_VOLUME_DOWN,
    WIIAUTO_BUTTON_ENTER,
    WIIAUTO_BUTTON_BACKSPACE
}
__wiiauto_button_type;

add_wiiauto_event(__wiiauto_event_press_button, EVENT_CONTENT(
    u8 down; 
    __wiiauto_button_type type;
));

#if defined __cplusplus
}
#endif

#endif
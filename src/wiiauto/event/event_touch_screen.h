#ifndef __wiiauto_event_touch_screen_h
#define __wiiauto_event_touch_screen_h

#include "event.h"

#if defined __cplusplus
extern "C" {
#endif

typedef enum
{
    WIIAUTO_TOUCH_UPDATE,
    WIIAUTO_TOUCH_EXPIRE
}
__wiiauto_touch_type;

add_wiiauto_event(__wiiauto_event_touch_screen, EVENT_CONTENT(

    __wiiauto_touch_type type;
    u8 index;

    float x;
    float y;
));

#if defined __cplusplus
}
#endif

#endif
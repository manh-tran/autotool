#ifndef __wiiauto_event_set_timer_h
#define __wiiauto_event_set_timer_h

#include "event.h"

#if defined __cplusplus
extern "C" {
#endif

add_wiiauto_event(__wiiauto_event_set_timer, EVENT_CONTENT(
    char url[256];
    time_t fire_time;
    u8 repeat;
    i32 interval;
));

add_wiiauto_event(__wiiauto_event_remove_timer, EVENT_CONTENT(
    char url[256];
));

#if defined __cplusplus
}
#endif

#endif
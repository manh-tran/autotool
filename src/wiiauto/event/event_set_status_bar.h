#ifndef __wiiauto_event_set_status_bar_h
#define __wiiauto_event_set_status_bar_h

#include "event.h"

#if defined __cplusplus
extern "C" {
#endif

add_wiiauto_event(__wiiauto_event_set_status_bar, EVENT_CONTENT(

    char text[1024];
    u8 complete;
));

add_wiiauto_event(__wiiauto_event_set_status_bar_state, EVENT_CONTENT(

    u8 visible;
));

#if defined __cplusplus
}
#endif

#endif
#ifndef __wiiauto_event_toast_h
#define __wiiauto_event_toast_h

#include "event.h"

#if defined __cplusplus
extern "C" {
#endif

add_wiiauto_event(__wiiauto_event_toast, EVENT_CONTENT(

    char text[1024];
    u8 complete;
    float delay;
));

#if defined __cplusplus
}
#endif

#endif
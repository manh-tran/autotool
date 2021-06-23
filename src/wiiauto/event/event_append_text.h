#ifndef __wiiauto_event_append_text_h
#define __wiiauto_event_append_text_h

#include "event.h"

#if defined __cplusplus
extern "C" {
#endif

add_wiiauto_event(__wiiauto_event_append_text, EVENT_CONTENT(

    char text[1024];
    u8 complete;
));

#if defined __cplusplus
}
#endif

#endif
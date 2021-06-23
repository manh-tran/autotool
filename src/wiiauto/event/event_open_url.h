#ifndef __wiiauto_event_open_url_h
#define __wiiauto_event_open_url_h

#include "event.h"

#if defined __cplusplus
extern "C" {
#endif

add_wiiauto_event(__wiiauto_event_open_url, EVENT_CONTENT(

    char text[1024];
    u8 complete;

));

#if defined __cplusplus
}
#endif

#endif
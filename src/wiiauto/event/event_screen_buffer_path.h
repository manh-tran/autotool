#ifndef __wiiauto_event_screen_buffer_path_h
#define __wiiauto_event_screen_buffer_path_h

#include "event.h"

#if defined __cplusplus
extern "C" {
#endif

add_wiiauto_event(__wiiauto_event_request_screen_buffer_path, EVENT_CONTENT(

));

add_wiiauto_event(__wiiauto_event_result_screen_buffer_path, EVENT_CONTENT(

    char path[1024];
    u64 timestamp;

));

#if defined __cplusplus
}
#endif

#endif 
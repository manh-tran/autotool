#ifndef __wiiauto_event_springboard_state_h
#define __wiiauto_event_springboard_state_h

#include "event.h"

#if defined __cplusplus
extern "C" {
#endif

typedef enum
{
    WIIAUTO_SPRINGBOARD_STATE_NOT_RUNNING,
    WIIAUTO_SPRINGBOARD_STATE_RUNNING
}
__wiiauto_springboard_state;

add_wiiauto_event(__wiiauto_event_request_springboard_state, EVENT_CONTENT(

));

add_wiiauto_event(__wiiauto_event_result_springboard_state, EVENT_CONTENT(

    __wiiauto_springboard_state state;
    int32_t pid;

));

#if defined __cplusplus
}
#endif

#endif 
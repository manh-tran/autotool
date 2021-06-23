#ifndef __wiiauto_event_app_state_h
#define __wiiauto_event_app_state_h

#include "event.h"

#if defined __cplusplus
extern "C" {
#endif

typedef enum
{
    WIIAUTO_APP_STATE_NOT_RUNNING,
    WIIAUTO_APP_STATE_ACTIVE,
    WIIAUTO_APP_STATE_INACTIVE
}
__wiiauto_app_state;

add_wiiauto_event(__wiiauto_event_request_app_state, EVENT_CONTENT(

));

add_wiiauto_event(__wiiauto_event_result_app_state, EVENT_CONTENT(

    __wiiauto_app_state state;

));

#if defined __cplusplus
}
#endif

#endif 
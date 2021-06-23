#ifndef __wiiauto_event_daemon_state_h
#define __wiiauto_event_daemon_state_h

#include "event.h"

#if defined __cplusplus
extern "C" {
#endif

typedef enum
{
    WIIAUTO_DAEMON_STATE_NOT_RUNNING,
    WIIAUTO_DAEMON_STATE_RUNNING
}
__wiiauto_daemon_state;

add_wiiauto_event(__wiiauto_event_request_daemon_state, EVENT_CONTENT(

));

add_wiiauto_event(__wiiauto_event_result_daemon_state, EVENT_CONTENT(

    __wiiauto_daemon_state state;

));

#if defined __cplusplus
}
#endif

#endif 
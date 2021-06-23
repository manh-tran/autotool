#include "event_daemon_state.h"

/*
 * request
 */
make_wiiauto_event(__wiiauto_event_request_daemon_state);

static void __wiiauto_event_request_daemon_state_init_content(__wiiauto_event_request_daemon_state *__p)
{
}  

/*
 * result
 */
make_wiiauto_event(__wiiauto_event_result_daemon_state);

static void __wiiauto_event_result_daemon_state_init_content(__wiiauto_event_result_daemon_state *__p)
{
    __p->state = WIIAUTO_DAEMON_STATE_NOT_RUNNING;
}
#include "event_springboard_state.h"

/*
 * request
 */
make_wiiauto_event(__wiiauto_event_request_springboard_state);

static void __wiiauto_event_request_springboard_state_init_content(__wiiauto_event_request_springboard_state *__p)
{
}  

/*
 * result
 */
make_wiiauto_event(__wiiauto_event_result_springboard_state);

static void __wiiauto_event_result_springboard_state_init_content(__wiiauto_event_result_springboard_state *__p)
{
    __p->state = WIIAUTO_SPRINGBOARD_STATE_NOT_RUNNING;
    __p->pid = 0;
}
#include "event_app_state.h"

/*
 * request
 */
make_wiiauto_event(__wiiauto_event_request_app_state);

static void __wiiauto_event_request_app_state_init_content(__wiiauto_event_request_app_state *__p)
{
}  

/*
 * result
 */
make_wiiauto_event(__wiiauto_event_result_app_state);

static void __wiiauto_event_result_app_state_init_content(__wiiauto_event_result_app_state *__p)
{
    __p->state = WIIAUTO_APP_STATE_NOT_RUNNING;
}
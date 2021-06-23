#include "event_front_most_app_port.h"

/*
 * request
 */
make_wiiauto_event(__wiiauto_event_request_front_most_app_port);

static void __wiiauto_event_request_front_most_app_port_init_content(__wiiauto_event_request_front_most_app_port *__p)
{
}  

/*
 * result
 */
make_wiiauto_event(__wiiauto_event_result_front_most_app_port);

static void __wiiauto_event_result_front_most_app_port_init_content(__wiiauto_event_result_front_most_app_port *__p)
{
    __p->port = 0;
}
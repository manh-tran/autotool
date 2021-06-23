#ifndef __wiiauto_event_front_most_app_port_h
#define __wiiauto_event_front_most_app_port_h

#include "event.h"

#if defined __cplusplus
extern "C" {
#endif

add_wiiauto_event(__wiiauto_event_request_front_most_app_port, EVENT_CONTENT(

));

add_wiiauto_event(__wiiauto_event_result_front_most_app_port, EVENT_CONTENT(

    int port;

));

#if defined __cplusplus
}
#endif

#endif 
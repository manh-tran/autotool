#ifndef __wiiauto_backboardd_handler_request_front_most_app_port_h
#define __wiiauto_backboardd_handler_request_front_most_app_port_h

#if defined __cplusplus
extern "C" {
#endif

#include "wiiauto/event/event_front_most_app_port.h"

CFDataRef backboardd_handle_request_front_most_app_port(const __wiiauto_event_request_front_most_app_port *input);

#if defined __cplusplus
}
#endif

#endif
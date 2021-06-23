#ifndef __wiiauto_springboard_handler_connect_wifi_h
#define __wiiauto_springboard_handler_connect_wifi_h

#if defined __cplusplus
extern "C" {
#endif

#include "wiiauto/event/event_connect_wifi.h"

CFDataRef springboard_handle_connect_wifi(const __wiiauto_event_connect_wifi *input);

#if defined __cplusplus
}
#endif

#endif
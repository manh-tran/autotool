#ifndef __wiiauto_event_connect_wifi_h
#define __wiiauto_event_connect_wifi_h

#include "event.h"

#if defined __cplusplus
extern "C" {
#endif

add_wiiauto_event(__wiiauto_event_connect_wifi, EVENT_CONTENT(

    char ssid[128];
    char pass[128];
));

#if defined __cplusplus
}
#endif

#endif
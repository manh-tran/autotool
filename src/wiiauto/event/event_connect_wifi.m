#include "event_connect_wifi.h"

make_wiiauto_event(__wiiauto_event_connect_wifi);

static void __wiiauto_event_connect_wifi_init_content(__wiiauto_event_connect_wifi *__p)
{
    __p->ssid[0] = '\0';
    __p->pass[0] = '\0';
}  
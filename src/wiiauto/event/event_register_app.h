#ifndef __wiiauto_event_register_app_h
#define __wiiauto_event_register_app_h

#include "event.h"

#if defined __cplusplus
extern "C" {
#endif

add_wiiauto_event(__wiiauto_event_register_app, EVENT_CONTENT(

    char bundle[256];
));

#if defined __cplusplus
}
#endif

#endif
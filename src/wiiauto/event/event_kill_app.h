#ifndef __wiiauto_event_kill_app_h
#define __wiiauto_event_kill_app_h

#include "event.h"

#if defined __cplusplus
extern "C" {
#endif

add_wiiauto_event(__wiiauto_event_kill_app, EVENT_CONTENT(

    char bundle[1024];

));

#if defined __cplusplus
}
#endif

#endif
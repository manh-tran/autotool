#ifndef __wiiauto_event_front_most_app_bundle_h
#define __wiiauto_event_front_most_app_bundle_h

#include "event.h"

#if defined __cplusplus
extern "C" {
#endif

add_wiiauto_event(__wiiauto_event_request_front_most_app_bundle, EVENT_CONTENT(

));

add_wiiauto_event(__wiiauto_event_result_front_most_app_bundle, EVENT_CONTENT(

    char bundle[256];

));

#if defined __cplusplus
}
#endif

#endif 
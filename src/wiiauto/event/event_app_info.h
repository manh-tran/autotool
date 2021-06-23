#ifndef __wiiauto_event_app_info_h
#define __wiiauto_event_app_info_h

#include "event.h"

#if defined __cplusplus
extern "C" {
#endif

add_wiiauto_event(__wiiauto_event_request_app_info, EVENT_CONTENT(

    char bundle[256];

));

add_wiiauto_event(__wiiauto_event_result_app_info, EVENT_CONTENT(

    char data_container_path[256];
    char display_name[256];
    char bundle_container_path[256];
    char executable_path[256];
));

#if defined __cplusplus
}
#endif

#endif 
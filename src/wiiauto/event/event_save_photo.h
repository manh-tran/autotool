#ifndef __wiiauto_event_save_photo_h
#define __wiiauto_event_save_photo_h

#include "event.h"

#if defined __cplusplus
extern "C" {
#endif

add_wiiauto_event(__wiiauto_event_request_save_photo, EVENT_CONTENT(

    char full_path[1024];

));

add_wiiauto_event(__wiiauto_event_result_save_photo, EVENT_CONTENT(

    int result;

));

#if defined __cplusplus
}
#endif

#endif 
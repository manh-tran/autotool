#ifndef __wiiauto_event_alert_h
#define __wiiauto_event_alert_h

#include "event.h"

#if defined __cplusplus
extern "C" {
#endif

add_wiiauto_event(__wiiauto_event_alert, EVENT_CONTENT(

    char text[1024];
    u8 complete;

));

add_wiiauto_event(__wiiauto_event_alert_on_add_title, EVENT_CONTENT(

    char title[1024];

    int priority;
));

add_wiiauto_event(__wiiauto_event_alert_on_add_action, EVENT_CONTENT(

    char title[1024];
    float x;
    float y;

    int priority;
));

add_wiiauto_event(__wiiauto_event_alert_on_add_label, EVENT_CONTENT(

    char title[1024];
    float x;
    float y;

    int priority;
));

add_wiiauto_event(__wiiauto_event_alert_begin_commit, EVENT_CONTENT(

    int priority;

));

add_wiiauto_event(__wiiauto_event_alert_end_commit, EVENT_CONTENT(

    int priority;
    
));

add_wiiauto_event(__wiiauto_event_alert_request_has_alert, EVENT_CONTENT(

));

add_wiiauto_event(__wiiauto_event_alert_result_has_alert, EVENT_CONTENT(
    int priority;
));

add_wiiauto_event(__wiiauto_event_alert_request_title, EVENT_CONTENT(
    int priority;
));

add_wiiauto_event(__wiiauto_event_alert_result_title, EVENT_CONTENT(
    char title[1024];
));

add_wiiauto_event(__wiiauto_event_alert_request_action, EVENT_CONTENT(
    int index;
    int priority;
));

add_wiiauto_event(__wiiauto_event_alert_result_action, EVENT_CONTENT(
    char success;
    char title[1024];
    float x;
    float y;
));

add_wiiauto_event(__wiiauto_event_alert_request_label, EVENT_CONTENT(
    int index;
    int priority;
));

add_wiiauto_event(__wiiauto_event_alert_result_label, EVENT_CONTENT(
    char success;
    char title[1024];
    float x;
    float y;
));

#if defined __cplusplus
}
#endif

#endif
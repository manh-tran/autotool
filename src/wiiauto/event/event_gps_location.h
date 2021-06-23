#ifndef __wiiauto_event_gps_location_h
#define __wiiauto_event_gps_location_h

#include "event.h"

#if defined __cplusplus
extern "C" {
#endif

add_wiiauto_event(__wiiauto_event_set_gps_location, EVENT_CONTENT(

    double latitude;
    double longitude;
    double altitude;

));

add_wiiauto_event(__wiiauto_event_override_gps_location, EVENT_CONTENT(

    u8 enable;

));

add_wiiauto_event(__wiiauto_event_request_gps_location, EVENT_CONTENT(

));

add_wiiauto_event(__wiiauto_event_result_gps_location, EVENT_CONTENT(
    double latitude;
    double longitude;
    double altitude;
    char replace;
    char enable;
));

#if defined __cplusplus
}
#endif

#endif
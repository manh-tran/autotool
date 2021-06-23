#ifndef __wiiauto_springboard_handler_gps_location_h
#define __wiiauto_springboard_handler_gps_location_h

#if defined __cplusplus
extern "C" {
#endif

#include "wiiauto/event/event_gps_location.h"

CFDataRef springboard_handle_set_gps_location(const __wiiauto_event_set_gps_location *input);
CFDataRef springboard_handle_request_gps_location(const __wiiauto_event_request_gps_location *input);
CFDataRef springboard_handle_override_gps_location(const __wiiauto_event_override_gps_location *input);

#if defined __cplusplus
}
#endif

#endif
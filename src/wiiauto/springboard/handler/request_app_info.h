#ifndef __wiiauto_springboard_handler_request_app_info_h
#define __wiiauto_springboard_handler_request_app_info_h

#if defined __cplusplus
extern "C" {
#endif

#include "wiiauto/event/event_app_info.h"

CFDataRef springboard_handle_request_app_info(const __wiiauto_event_request_app_info *input);

#if defined __cplusplus
}
#endif

#endif
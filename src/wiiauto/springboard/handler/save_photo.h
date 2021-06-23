#ifndef __wiiauto_springboard_handler_request_save_photo_h
#define __wiiauto_springboard_handler_request_save_photo_h

#if defined __cplusplus
extern "C" {
#endif

#include "wiiauto/event/event_save_photo.h"

CFDataRef springboard_handle_request_save_photo(const __wiiauto_event_request_save_photo *input);

#if defined __cplusplus
}
#endif

#endif
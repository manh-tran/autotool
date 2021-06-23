#ifndef __wiiauto_springboard_handler_open_url_h
#define __wiiauto_springboard_handler_open_url_h

#if defined __cplusplus
extern "C" {
#endif

#include "wiiauto/event/event_open_url.h"

CFDataRef springboard_handle_open_url(const __wiiauto_event_open_url *input);

#if defined __cplusplus
}
#endif

#endif
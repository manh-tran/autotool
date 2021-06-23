#ifndef __wiiauto_springboard_handler_toast_h
#define __wiiauto_springboard_handler_toast_h

#if defined __cplusplus
extern "C" {
#endif

#include "wiiauto/event/event_toast.h"

CFDataRef springboard_handle_toast(const __wiiauto_event_toast *input);

#if defined __cplusplus
}
#endif

#endif
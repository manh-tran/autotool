#ifndef __wiiauto_backboardd_handler_append_text_h
#define __wiiauto_backboardd_handler_append_text_h

#if defined __cplusplus
extern "C" {
#endif

#include "wiiauto/event/event_append_text.h"

CFDataRef backboardd_handle_append_text(const __wiiauto_event_append_text *input);

#if defined __cplusplus
}
#endif

#endif
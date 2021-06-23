#ifndef __wiiauto_daemon_handler_set_timer_h
#define __wiiauto_daemon_handler_set_timer_h

#if defined __cplusplus
extern "C" {
#endif

#include "wiiauto/event/event_timer.h"

extern spin_lock __timer_barrier__;

CFDataRef daemon_handle_set_timer(const __wiiauto_event_set_timer *input);
CFDataRef daemon_handle_remove_timer(const __wiiauto_event_remove_timer *input);

#if defined __cplusplus
}
#endif

#endif
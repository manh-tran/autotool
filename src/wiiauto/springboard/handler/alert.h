#ifndef __wiiauto_springboard_handler_alert_h
#define __wiiauto_springboard_handler_alert_h

#if defined __cplusplus
extern "C" {
#endif

#include "wiiauto/event/event_alert.h"

CFDataRef springboard_handle_alert(const __wiiauto_event_alert *input);
CFDataRef springboard_handle_alert_on_add_title(const __wiiauto_event_alert_on_add_title *input);
CFDataRef springboard_handle_alert_on_add_action(const __wiiauto_event_alert_on_add_action *input);
CFDataRef springboard_handle_alert_on_add_label(const __wiiauto_event_alert_on_add_label *input);
CFDataRef springboard_handle_alert_begin_commit(const __wiiauto_event_alert_begin_commit *input);
CFDataRef springboard_handle_alert_end_commit(const __wiiauto_event_alert_end_commit *input);
CFDataRef springboard_handle_alert_request_title(const __wiiauto_event_alert_request_title *input);
CFDataRef springboard_handle_alert_request_action(const __wiiauto_event_alert_request_action *input);
CFDataRef springboard_handle_alert_request_label(const __wiiauto_event_alert_request_label *input);
CFDataRef springboard_handle_alert_request_has_alert(const __wiiauto_event_alert_request_has_alert *input);

#if defined __cplusplus
}
#endif

#endif
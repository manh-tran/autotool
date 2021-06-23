#include "cherry/core/map.h"
#include "cherry/core/buffer.h"
#include "handler/touch_screen.h"
#include "handler/unlock_screen.h"
#include "handler/undim_display.h"
#include "handler/press_button.h"
#include "handler/turn_on_screen.h"
#include "handler/register_app.h"
#include "handler/request_front_most_app_bundle.h"
#include "handler/append_text.h"
#include "handler/alert.h"
#include "handler/toast.h"
#include "handler/open_url.h"
#include "handler/request_app_info.h"
#include "handler/request_springboard_state.h"
#include "handler/gps_location.h"
#include "handler/screen_buffer_path.h"
#include "handler/set_status_bar.h"
#include "handler/kill_app.h"
#include "handler/save_photo.h"
#include "handler/connect_wifi.h"

static map delegates = {id_null};

void springboard_append_text_register();

static void __springboard_in()
{
    if (id_validate(delegates.iobj)) return;

    map_new(&delegates);

    wiiauto_add_event_delegate(delegates, __wiiauto_event_touch_screen, springboard_handle_touch_screen);
    wiiauto_add_event_delegate(delegates, __wiiauto_event_unlock_screen, springboard_handle_unlock_screen);
    wiiauto_add_event_delegate(delegates, __wiiauto_event_undim_display, springboard_handle_undim_display);
    wiiauto_add_event_delegate(delegates, __wiiauto_event_press_button, springboard_handle_press_button);
    wiiauto_add_event_delegate(delegates, __wiiauto_event_turn_on_screen, springboard_handle_turn_on_screen);
    wiiauto_add_event_delegate(delegates, __wiiauto_event_register_app, springboard_handle_register_app);
    wiiauto_add_event_delegate(delegates, __wiiauto_event_request_front_most_app_bundle, springboard_handle_request_front_most_app_bundle);
    wiiauto_add_event_delegate(delegates, __wiiauto_event_append_text, springboard_handle_append_text);
    wiiauto_add_event_delegate(delegates, __wiiauto_event_alert, springboard_handle_alert);
    wiiauto_add_event_delegate(delegates, __wiiauto_event_toast, springboard_handle_toast);
    wiiauto_add_event_delegate(delegates, __wiiauto_event_open_url, springboard_handle_open_url);
    wiiauto_add_event_delegate(delegates, __wiiauto_event_request_app_info, springboard_handle_request_app_info);
    wiiauto_add_event_delegate(delegates, __wiiauto_event_request_springboard_state, springboard_handle_request_springboard_state);
    wiiauto_add_event_delegate(delegates, __wiiauto_event_alert_on_add_title, springboard_handle_alert_on_add_title);
    wiiauto_add_event_delegate(delegates, __wiiauto_event_alert_on_add_action, springboard_handle_alert_on_add_action);
    wiiauto_add_event_delegate(delegates, __wiiauto_event_alert_on_add_label, springboard_handle_alert_on_add_label);
    wiiauto_add_event_delegate(delegates, __wiiauto_event_alert_begin_commit, springboard_handle_alert_begin_commit);
    wiiauto_add_event_delegate(delegates, __wiiauto_event_alert_end_commit, springboard_handle_alert_end_commit);
    wiiauto_add_event_delegate(delegates, __wiiauto_event_alert_request_has_alert, springboard_handle_alert_request_has_alert);
    wiiauto_add_event_delegate(delegates, __wiiauto_event_alert_request_title, springboard_handle_alert_request_title);
    wiiauto_add_event_delegate(delegates, __wiiauto_event_alert_request_action, springboard_handle_alert_request_action);
    wiiauto_add_event_delegate(delegates, __wiiauto_event_alert_request_label, springboard_handle_alert_request_label);
    wiiauto_add_event_delegate(delegates, __wiiauto_event_set_gps_location, springboard_handle_set_gps_location);
    wiiauto_add_event_delegate(delegates, __wiiauto_event_request_gps_location, springboard_handle_request_gps_location);
    wiiauto_add_event_delegate(delegates, __wiiauto_event_override_gps_location, springboard_handle_override_gps_location);
    wiiauto_add_event_delegate(delegates, __wiiauto_event_request_screen_buffer_path, springboard_handle_request_screen_buffer_path);
    wiiauto_add_event_delegate(delegates, __wiiauto_event_set_status_bar, springboard_handle_set_status_bar);
    wiiauto_add_event_delegate(delegates, __wiiauto_event_set_status_bar_state, springboard_handle_set_status_bar_state);
    wiiauto_add_event_delegate(delegates, __wiiauto_event_kill_app, springboard_handle_kill_app);
    wiiauto_add_event_delegate(delegates, __wiiauto_event_request_save_photo, springboard_handle_request_save_photo);
    wiiauto_add_event_delegate(delegates, __wiiauto_event_connect_wifi, springboard_handle_connect_wifi);

    springboard_append_text_register();
}

static void __attribute__((destructor)) __springboard_out()
{
    // release(delegates.iobj);
}

void springboard_get_handler(const __wiiauto_event *data, const u32 in_size, wiiauto_event_delegate *del)
{
    __springboard_in();

    wiiauto_get_event_delegate(delegates, data->name, in_size, del);
}
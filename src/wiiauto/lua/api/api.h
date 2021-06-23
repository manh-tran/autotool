#ifndef __wiiauto_lua_api_h
#define __wiiauto_lua_api_h

#if defined __cplusplus
extern "C" {
#endif

#include "lua/lua.h"
#include "lua/lauxlib.h"
#include "lua/lualib.h"

#define WIIAUTO_DEBUG_LUA_API 0

void wiiauto_lua_register_state(lua_State *ls);
void wiiauto_lua_register_json(lua_State *ls);

int wiiauto_lua_touch_down(lua_State *ls);
int wiiauto_lua_touch_move(lua_State *ls);
int wiiauto_lua_touch_up(lua_State *ls);
int wiiauto_lua_zoom_down(lua_State *ls);
int wiiauto_lua_zoom_move(lua_State *ls);
int wiiauto_lua_zoom_up(lua_State *ls);
int wiiauto_lua_key_down(lua_State *ls);
int wiiauto_lua_key_up(lua_State *ls);
int wiiauto_lua_key_down_detail(lua_State *ls);
int wiiauto_lua_key_up_detail(lua_State *ls);
int wiiauto_lua_get_color(lua_State *ls);
int wiiauto_lua_get_colors(lua_State *ls);
int wiiauto_lua_find_color(lua_State *ls);
int wiiauto_lua_find_colors(lua_State *ls);
int wiiauto_lua_find_image_v2(lua_State *ls);
int wiiauto_lua_find_image(lua_State *ls);
int wiiauto_lua_find_image_grayscale(lua_State *ls);
int wiiauto_lua_find_image_blackwhite(lua_State *ls);
int wiiauto_lua_screen_shot(lua_State *ls);
int wiiauto_lua_root_dir(lua_State *ls);
int wiiauto_lua_current_path(lua_State *ls);
int wiiauto_lua_usleep(lua_State *ls);
int wiiauto_lua_log(lua_State *ls);
int wiiauto_lua_get_orientation(lua_State *ls);
int wiiauto_lua_get_screen_resolution(lua_State *ls);
int wiiauto_lua_get_screen_size(lua_State *ls);
int wiiauto_lua_get_front_most_app_id(lua_State *ls);
int wiiauto_lua_get_front_most_app_orientation(lua_State *ls);
int wiiauto_lua_int_to_rgb(lua_State *ls);
int wiiauto_lua_rgb_to_int(lua_State *ls);
int wiiauto_lua_set_clipboard_text(lua_State *ls);
int wiiauto_lua_get_clipboard_text(lua_State *ls);
int wiiauto_lua_input_text(lua_State *ls);
int wiiauto_lua_input_text_paste(lua_State *ls);
int wiiauto_lua_run_app(lua_State *ls);
int wiiauto_lua_kill_app(lua_State *ls);
int wiiauto_lua_get_app_state(lua_State *ls);
int wiiauto_lua_alert(lua_State *ls);
int wiiauto_lua_toast(lua_State *ls);
int wiiauto_lua_vibrate(lua_State *ls);
int wiiauto_lua_get_serial_number(lua_State *ls);
int wiiauto_lua_open_url(lua_State *ls);
int wiiauto_lua_set_timer(lua_State *ls);
int wiiauto_lua_remove_timer(lua_State *ls);
int wiiauto_lua_get_app_info(lua_State *ls);
int wiiauto_lua_exe(lua_State *ls);
int wiiauto_lua_has_alert(lua_State *ls);
int wiiauto_lua_awake(lua_State *ls);
int wiiauto_lua_get_memory_usage(lua_State *ls);
int wiiauto_lua_set_gps_location(lua_State *ls);
int wiiauto_lua_override_gps_location(lua_State *ls);
int wiiauto_lua_uninstall_app(lua_State *ls);
int wiiauto_lua_get_version(lua_State *ls);
int wiiauto_lua_find_image_in_image(lua_State *ls);
int wiiauto_lua_stop(lua_State *ls);
int wiiauto_lua_reset_advertising_id(lua_State *ls);
int wiiauto_lua_test_screen(lua_State *ls);
int wiiauto_lua_remote_log(lua_State *ls);
int wiiauto_lua_set_status_bar(lua_State *ls);
int wiiauto_lua_get_local_ipv4_address(lua_State *ls);
int wiiauto_lua_clear_account(lua_State *ls);
int wiiauto_lua_set_bundle_preference(lua_State *ls);
int wiiauto_lua_get_bundle_preference(lua_State *ls);
int wiiauto_lua_set_bundle_share(lua_State *ls);
int wiiauto_lua_get_bundle_share(lua_State *ls);
int wiiauto_lua_get_bundle_share_all(lua_State *ls);
int wiiauto_lua_get_new_uuid(lua_State *ls);
int wiiauto_lua_save_bundle_keychain(lua_State *ls);
int wiiauto_lua_load_bundle_keychain(lua_State *ls);

int wiiauto_lua_set_bundle_keychain_state(lua_State *ls);
int wiiauto_lua_get_bundle_keychain_state(lua_State *ls);

int wiiauto_lua_add_bundle_key_multi_value(lua_State *ls);
int wiiauto_lua_delete_bundle_key_multi_value(lua_State *ls);
int wiiauto_lua_get_bundle_key_multi_value(lua_State *ls);

int wiiauto_lua_gzip_string(lua_State *ls);

// int wiiauto_lua_set_app_preference(lua_State *ls);
// int wiiauto_lua_get_app_preference(lua_State *ls);
// int wiiauto_lua_set_app_preference_state(lua_State *ls);
// int wiiauto_lua_get_app_preference_state(lua_State *ls);
// int wiiauto_lua_set_app_bundle_overrided(lua_State *ls);
// int wiiauto_lua_set_app_bundle_original(lua_State *ls);

int wiiauto_lua_respring_and_clear_account(lua_State *ls);
int wiiauto_lua_clone_facebook(lua_State *ls);
int wiiauto_lua_clone_facebook_batch(lua_State *ls);
int wiiauto_lua_remove_clone_facebook(lua_State *ls);
int wiiauto_lua_clear_itunes_cache(lua_State *ls);
int wiiauto_lua_remove_all_clone_facebook(lua_State *ls);

int wiiauto_lua_clone_messenger(lua_State *ls);
int wiiauto_lua_remove_clone_messenger(lua_State *ls);
int wiiauto_lua_remove_all_clone_messenger(lua_State *ls);

int wiiauto_lua_clone_zalo(lua_State *ls);
int wiiauto_lua_remove_all_clone_zalo(lua_State *ls);
int wiiauto_lua_clone_chrome(lua_State *ls);
int wiiauto_lua_remove_all_clone_chrome(lua_State *ls);
int wiiauto_lua_clone_youtube(lua_State *ls);
int wiiauto_lua_remove_all_clone_youtube(lua_State *ls);
int wiiauto_lua_clone_firefox(lua_State *ls);
int wiiauto_lua_remove_all_clone_firefox(lua_State *ls);
int wiiauto_lua_set_status_bar_state(lua_State *ls);
int wiiauto_lua_md5(lua_State *ls);
int wiiauto_lua_remember_hashcode(lua_State *ls);
int wiiauto_lua_is_hashcode_remembered(lua_State *ls);
int wiiauto_lua_download_image_to_photo_library(lua_State *ls);
int wiiauto_lua_download_image(lua_State *ls);
int wiiauto_lua_get_ios_system_version(lua_State *ls);
int wiiauto_lua_get_app_group_folder(lua_State *ls);
int wiiauto_lua_delete_keychain_by_name(lua_State *ls);
int wiiauto_lua_delete_keychain_by_name_exactly(lua_State *ls);
int wiiauto_lua_delete_keychain_all(lua_State *ls);
int wiiauto_lua_delete_keychain_genp(lua_State *ls);
int wiiauto_lua_check_has_keychain_cert(lua_State *ls);
int wiiauto_lua_is_file_exist(lua_State *ls);
int wiiauto_lua_get_device_name(lua_State *ls);
int wiiauto_lua_get_device_model(lua_State *ls);
int wiiauto_lua_get_system_build_version(lua_State *ls);
int wiiauto_lua_get_system_version(lua_State *ls);
int wiiauto_lua_delete_app_data_start_with(lua_State *ls);
int wiiauto_lua_delete_app_group_start_with(lua_State *ls);
int wiiauto_lua_delete_app_data_exactly(lua_State *ls);
int wiiauto_lua_delete_app_group_exactly(lua_State *ls);
int wiiauto_lua_add_contact(lua_State *ls);
int wiiauto_lua_delete_all_contacts(lua_State *ls);

int wiiauto_lua_connect_to_wifi(lua_State *ls);
int wiiauto_lua_set_airplane_mode(lua_State *ls);

int wiiauto_lua_post_notification(lua_State *ls);

int wiiauto_lua_register_application(lua_State *ls);
int wiiauto_lua_unregister_application(lua_State *ls);

int wiiauto_lua_get_container_metadata(lua_State *ls);
int wiiauto_lua_set_container_metadata(lua_State *ls);

int wiiauto_lua_db_email_add(lua_State *ls);
int wiiauto_lua_db_email_set_appleid_register_state(lua_State *ls);
int wiiauto_lua_db_email_get_appleid_unregistered(lua_State *ls);
int wiiauto_lua_db_email_get_appleid_unregistered_alike(lua_State *ls);
int wiiauto_lua_db_email_add_appleid_machine(lua_State *ls);

// int wiiauto_lua_set_bundle_key_number(lua_State *ls);
// int wiiauto_lua_get_bundle_key_number(lua_State *ls);
// int wiiauto_lua_remove_bundle_key_number(lua_State *ls);

int wiiauto_lua_db_imessage_add(lua_State *ls);
int wiiauto_lua_db_imessage_get(lua_State *ls);
int wiiauto_lua_db_imessage_set_status(lua_State *ls);
int wiiauto_lua_db_imessage_delete_processeds(lua_State *ls);




int wiiauto_lua_get_phone_number(lua_State *ls);

int wiiauto_lua_get_running_scripts(lua_State *ls);
int wiiauto_lua_run_script(lua_State *ls);
int wiiauto_lua_stop_script(lua_State *ls);
int wiiauto_lua_send_sms(lua_State *ls);

int wiiauto_lua_get_total_zaccounts(lua_State *ls);
int wiiauto_lua_check_has_zaccount(lua_State *ls);
int wiiauto_lua_set_system_version_plist(lua_State *ls);

int wiiauto_lua_set_system_proxy(lua_State *ls);

int wiiauto_lua_validate_image(lua_State *ls);

int wiiauto_lua_send_http_request(lua_State *ls);

int wiiauto_lua_generate_persona_kb(lua_State *ls);

#if defined __cplusplus
}
#endif

#endif
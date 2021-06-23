#ifndef __wiiauto_common_h
#define __wiiauto_common_h

#if defined __cplusplus
extern "C" {
#endif

#include "wiiauto/device/device.h"
#include "cherry/core/buffer.h"

// extern spin_lock __color_barrier__;

void common_get_internal_url(const char *path, const buffer b);
void common_get_script_url(const char *path, const buffer b);
void common_get_view_size(u32 *width, u32 *height);
void common_get_screen_size(u32 *width, u32 *height);
void common_get_orientation(__wiiauto_device_orientation *o);
void common_get_front_most_app_port(int *port);
void common_get_front_most_app_bundle_id(const char **bundle);
void common_get_current_app_id(const buffer b);
void common_touch_down(const u8 index, const f32 x, const f32 y);
void common_touch_move(const u8 index, const f32 x, const f32 y);
void common_touch_up(const u8 index, const f32 x, const f32 y);
void common_zoom_down(const u8 index, const f32 x1, const f32 y1, const f32 x2, const f32 y2);
void common_zoom_move(const u8 index, const f32 x1, const f32 y1, const f32 x2, const f32 y2);
void common_zoom_up(const u8 index, const f32 x1, const f32 y1, const f32 x2, const f32 y2);
void common_key_down(const i32 type);
void common_key_up(const i32 type);
void common_key_down_detail(const i32 usage_page, const i32 usage);
void common_key_up_detail(const i32 usage_page, const i32 usage);
void common_get_device_color_pointer(const __wiiauto_pixel **ptr);
void common_get_rgb(const f32 x, const f32 y, u8 *r, u8 *g, u8 *b);
void common_get_color(const f32 x, const f32 y, i32 *color);
void common_rgb_to_int(const u8 r, const u8 g, const u8 b, i32 *color);
void common_int_to_rgb(const i32 color, u8 *r, u8 *g, u8 *b);
void common_find_color(const i32 color, const u32 count, const i32 range[4], const buffer result);
void common_find_colors(const buffer colors, const u32 count, const i32 range[4], const buffer result, const u8 check_color_offset);
void common_find_image_v2(const char *path, const u32 count, const f32 theshold, const i32 range[4], const buffer result);
void common_find_image(const char *path, const u32 count, const f32 theshold, const i32 range[4], const buffer result);
void common_find_image_grayscale(const char *path, const u32 count, const f32 theshold, const i32 range[4], const buffer result);
void common_find_image_blackwhite(const char *path, const u32 count, const f32 theshold, const i32 range[4], const buffer result);
void common_find_image_in_image(const char *path1, const char *path2, const u32 count, const buffer result);
void common_save_screen_shot(const char *path, const i32 range[4]);
void common_write_png(const char *path, const u8 *ptr, const u32 width, const u32 height);
void common_append_text(const char *text, const int word_by_word);
void common_append_text_paste(const char *text, const int word_by_word);
void common_alert(const char *text);
void common_toast(const char *text, const float delay);
void common_set_status_bar(const char *text);
void common_set_status_bar_state(const u8 visible);
void common_open_url(const char *text);
void common_undim_display();
void common_minisleep();
void common_get_app_info(const char *bundle, const buffer data_container_path, const buffer display_name, const buffer bundle_container_path, const buffer executable_path);
void common_set_timer(const char *url, const time_t fire_time, const u8 repeat, const i32 interval);
void common_remove_timer(const char *url);
void common_is_daemon_running(u8 *r);
void common_is_springboard_running(u8 *r, int32_t *pid);
void common_set_gps_location(const double latitude, const double longitude, const double altitude);
void common_override_gps_location(const u8 v);
void common_is_gps_overrided(u8 *v);
void common_get_gps_location(f64 *latitude, f64 *longitude, u8 *overrided);
void common_kill_app(const char *bundle);
void common_save_photo(const char *full_path, u8 *success);
void common_connect_wifi(const char *ssid, const char *pass);

#if defined __cplusplus
}
#endif

#endif
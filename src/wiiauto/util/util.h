#ifndef __wiiauto_util_h
#define __wiiauto_util_h

#if defined __cplusplus
extern "C" {
#endif

#include "cherry/def.h"
#include "cherry/core/buffer.h"

void wiiauto_util_uicache(const char *app_path);
void wiiauto_util_unregister_app(const char *app_path);

void wiiauto_util_cpy_raw4(const u8 *src, u8 *dst, const u32 width, const u32 height, const u32 allocation_size);

int wiiauto_util_clone_facebook(const char *bundle_id, const unsigned char group);
int wiiauto_util_remove_clone_facebook(const char *bundle_id);
void wiiauto_util_remove_all_clone_facebook();
void wiiauto_util_reinstall_facebook();
void wiiauto_util_group_facebook();

int wiiauto_util_clone_messenger(const char *bundle_id, const unsigned char group);
int wiiauto_util_remove_clone_messenger(const char *bundle_id);
void wiiauto_util_remove_all_clone_messenger();

int wiiauto_util_clone_zalo(const char *bundle_id, const unsigned char group);
int wiiauto_util_remove_clone_zalo(const char *bundle_id);
void wiiauto_util_remove_all_clone_zalo();

int wiiauto_util_clone_youtube(const char *bundle_id, const unsigned char group);
void wiiauto_util_remove_all_clone_youtube();

int wiiauto_util_clone_chrome(const char *bundle_id, const unsigned char group);
void wiiauto_util_remove_all_clone_chrome();

int wiiauto_util_clone_firefox(const char *bundle_id, const unsigned char group);
void wiiauto_util_remove_all_clone_firefox();

int wiiauto_util_clone_textnow(const char *bundle_id, const unsigned char group);
void wiiauto_util_remove_all_clone_textnow();

time_t wiiauto_util_get_uptime();
time_t wiiauto_util_get_boottime();

void wiiauto_util_find_image(
    const u8 *src, const u32 src_channels, const u32 src_width, const u32 src_height, const u32 src_allocation_size,
    const u8 *dst, const u32 dst_channels, const u32 dst_width, const u32 dst_height, const u32 dst_allocation_size,
    const u32 grid, const float threshold, const u32 max_result, 
    const int from_x, const int from_y, const int to_x, const int to_y,
    const buffer result);

void wiiauto_util_find_image_grayscale(
    const u8 *src, const u32 src_channels, const u32 src_width, const u32 src_height, const u32 src_allocation_size,
    const u8 *dst, const u32 dst_channels, const u32 dst_width, const u32 dst_height, const u32 dst_allocation_size,
    const u32 grid, const float threshold, const u32 max_result, 
    const int from_x, const int from_y, const int to_x, const int to_y,
    const buffer result);

void wiiauto_util_find_image_blackwhite(
    const u8 *src, const u32 src_channels, const u32 src_width, const u32 src_height, const u32 src_allocation_size,
    const u8 *dst, const u32 dst_channels, const u32 dst_width, const u32 dst_height, const u32 dst_allocation_size,
    const u32 grid, const float threshold, const u32 max_result, 
    const int from_x, const int from_y, const int to_x, const int to_y,
    const buffer result);

void wiiauto_util_find_image_v2(
    const u8 *src, const u32 src_channels, const u32 src_width, const u32 src_height, const u32 src_allocation_size,
    const u8 *dst, const u32 dst_channels, const u32 dst_width, const u32 dst_height, const u32 dst_allocation_size,
    const u32 grid, const float threshold, const u32 max_result, 
    const int from_x, const int from_y, const int to_x, const int to_y,
    const buffer result);


void wiiauto_util_find_colors(
    const u8 *src, const u32 src_channels, const u32 src_width, const u32 src_height, const u32 src_allocation_size,
    const u8 *colors, const int *offsets, const u32 length, const u32 max_result, const buffer result);

void wiiauto_util_fill_screenbuffer(u8 *ptr);

#if defined __cplusplus
}
#endif


#endif
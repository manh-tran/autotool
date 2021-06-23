#include "cherry/core/buffer.h"
#include "wiiauto/device/device.h"
#include "wiiauto/file/file.h"
#include "cherry/graphic/image.h"
#include "wiiauto/util/util.h"
#include "wiiauto/daemon/screenbuffer/screenbuffer.h"
#include "common.h"

void common_find_image_v2(const char *path, const u32 count, const f32 threshold, const i32 range[4], const buffer result)
{
    image img;
    buffer burl;
    const char *full_path;
    u32 img_width, img_height, img_channels, img_allocated_size;
    u32 view_width, view_height;
    u32 screen_width, screen_height;
    const u8 *screen_ptr, *img_ptr;
    u32 len;
    float search_threshold;

    buffer result_i32;
    buffer_new(&result_i32);

    buffer_erase(result);

    wiiauto_device_get_current_screen_buffer(&screen_ptr, &screen_width, &screen_height);

    common_get_view_size(&view_width, &view_height);
    int pageSize = getpagesize();
    u32 bytes = view_width * view_height * 4;
    u32 mod = bytes % pageSize;
    if (mod != 0) {
        bytes = (bytes / pageSize + 1) * pageSize;
    }

    /* load image */
    buffer_new(&burl);
    common_get_script_url(path, burl);
    buffer_get_ptr(burl, &full_path);

    image_new(&img);
    image_load_file(img, full_path, (f32[3]){1, 1, 1});
    image_get_size(img, &img_width, &img_height);
    image_get_ptr(img, &img_ptr);
    image_get_number_channels(img, &img_channels);
    image_get_allocated_size(img, &img_allocated_size);

    search_threshold = threshold - 0.01;
    if (search_threshold < 0) {
        search_threshold = 0;
    }

    /* find result */
    lock(&__screenbuffer_lock__);
    wiiauto_util_find_image_v2(screen_ptr, 4, view_width, view_height, bytes,
        img_ptr, img_channels, img_width, img_height, img_allocated_size, 20, search_threshold, count, 
        range[0], range[1], range[0] + range[2], range[1] + range[3],
        result_i32);
    unlock(&__screenbuffer_lock__);

    buffer_length(result_i32, sizeof(int[2]), &len);
    i32 xy[2];
    for (int i = 0; i < len; ++i) {
        buffer_get(result_i32, sizeof(int[2]), i, xy);
        if (xy[0] >= range[0] && xy[0] <= (range[0] + range[2]) && xy[1] >= range[1] && xy[1] <= (range[1] + range[3])) {
            buffer_append(result, &(f32[2]){xy[0], xy[1]}, sizeof(f32[2]));
        }
    }

finish:
    release(result_i32.iobj);
    release(burl.iobj);
    release(img.iobj);
}

void common_find_image(const char *path, const u32 count, const f32 threshold, const i32 range[4], const buffer result)
{
    image img;
    buffer burl;
    const char *full_path;
    u32 img_width, img_height, img_channels, img_allocated_size;
    u32 view_width, view_height;
    u32 screen_width, screen_height;
    const u8 *screen_ptr, *img_ptr;
    u32 len;
    float search_threshold;

    buffer result_i32;
    buffer_new(&result_i32);

    buffer_erase(result);

    wiiauto_device_get_current_screen_buffer(&screen_ptr, &screen_width, &screen_height);

    common_get_view_size(&view_width, &view_height);
    int pageSize = getpagesize();
    u32 bytes = view_width * view_height * 4;
    u32 mod = bytes % pageSize;
    if (mod != 0) {
        bytes = (bytes / pageSize + 1) * pageSize;
    }

    /* load image */
    buffer_new(&burl);
    common_get_script_url(path, burl);
    buffer_get_ptr(burl, &full_path);

    image_new(&img);
    image_load_file(img, full_path, (f32[3]){1, 1, 1});
    image_get_size(img, &img_width, &img_height);
    image_get_ptr(img, &img_ptr);
    image_get_number_channels(img, &img_channels);
    image_get_allocated_size(img, &img_allocated_size);

    search_threshold = threshold - 0.01;
    if (search_threshold < 0) {
        search_threshold = 0;
    }

    /* find result */
    lock(&__screenbuffer_lock__);
    wiiauto_util_find_image(screen_ptr, 4, view_width, view_height, bytes,
        img_ptr, img_channels, img_width, img_height, img_allocated_size, 20, search_threshold, count, 
        range[0], range[1], range[0] + range[2], range[1] + range[3],
        result_i32);
    unlock(&__screenbuffer_lock__);

    buffer_length(result_i32, sizeof(int[2]), &len);
    i32 xy[2];
    for (int i = 0; i < len; ++i) {
        buffer_get(result_i32, sizeof(int[2]), i, xy);
        if (xy[0] >= range[0] && xy[0] <= (range[0] + range[2]) && xy[1] >= range[1] && xy[1] <= (range[1] + range[3])) {
            buffer_append(result, &(f32[2]){xy[0], xy[1]}, sizeof(f32[2]));
        }
    }

finish:
    release(result_i32.iobj);
    release(burl.iobj);
    release(img.iobj);
}

void common_find_image_grayscale(const char *path, const u32 count, const f32 threshold, const i32 range[4], const buffer result)
{
    image img;
    buffer burl;
    const char *full_path;
    u32 img_width, img_height, img_channels, img_allocated_size;
    u32 view_width, view_height;
    u32 screen_width, screen_height;
    const u8 *screen_ptr, *img_ptr;
    u32 len;
    float search_threshold;

    buffer result_i32;
    buffer_new(&result_i32);

    buffer_erase(result);

    wiiauto_device_get_current_screen_buffer(&screen_ptr, &screen_width, &screen_height);

    common_get_view_size(&view_width, &view_height);
    int pageSize = getpagesize();
    u32 bytes = view_width * view_height * 4;
    u32 mod = bytes % pageSize;
    if (mod != 0) {
        bytes = (bytes / pageSize + 1) * pageSize;
    }

    /* load image */
    buffer_new(&burl);
    common_get_script_url(path, burl);
    buffer_get_ptr(burl, &full_path);

    image_new(&img);
    image_load_file(img, full_path, (f32[3]){1, 1, 1});
    image_get_size(img, &img_width, &img_height);
    image_get_ptr(img, &img_ptr);
    image_get_number_channels(img, &img_channels);
    image_get_allocated_size(img, &img_allocated_size);

    search_threshold = threshold - 0.01;
    if (search_threshold < 0) {
        search_threshold = 0;
    }

    /* find result */
    lock(&__screenbuffer_lock__);
    wiiauto_util_find_image_grayscale(screen_ptr, 4, view_width, view_height, bytes,
        img_ptr, img_channels, img_width, img_height, img_allocated_size, 20, search_threshold, count, 
        range[0], range[1], range[0] + range[2], range[1] + range[3],
        result_i32);
    unlock(&__screenbuffer_lock__);

    buffer_length(result_i32, sizeof(int[2]), &len);
    i32 xy[2];
    for (int i = 0; i < len; ++i) {
        buffer_get(result_i32, sizeof(int[2]), i, xy);
        if (xy[0] >= range[0] && xy[0] <= (range[0] + range[2]) && xy[1] >= range[1] && xy[1] <= (range[1] + range[3])) {
            buffer_append(result, &(f32[2]){xy[0], xy[1]}, sizeof(f32[2]));
        }
    }

finish:
    release(result_i32.iobj);
    release(burl.iobj);
    release(img.iobj);
}

void common_find_image_blackwhite(const char *path, const u32 count, const f32 threshold, const i32 range[4], const buffer result)
{
    image img;
    buffer burl;
    const char *full_path;
    u32 img_width, img_height, img_channels, img_allocated_size;
    u32 view_width, view_height;
    u32 screen_width, screen_height;
    const u8 *screen_ptr, *img_ptr;
    u32 len;
    float search_threshold;

    buffer result_i32;
    buffer_new(&result_i32);

    buffer_erase(result);

    wiiauto_device_get_current_screen_buffer(&screen_ptr, &screen_width, &screen_height);

    common_get_view_size(&view_width, &view_height);
    int pageSize = getpagesize();
    u32 bytes = view_width * view_height * 4;
    u32 mod = bytes % pageSize;
    if (mod != 0) {
        bytes = (bytes / pageSize + 1) * pageSize;
    }

    /* load image */
    buffer_new(&burl);
    common_get_script_url(path, burl);
    buffer_get_ptr(burl, &full_path);

    image_new(&img);
    image_load_file(img, full_path, (f32[3]){1, 1, 1});
    image_get_size(img, &img_width, &img_height);
    image_get_ptr(img, &img_ptr);
    image_get_number_channels(img, &img_channels);
    image_get_allocated_size(img, &img_allocated_size);

    search_threshold = threshold - 0.01;
    if (search_threshold < 0) {
        search_threshold = 0;
    }

    /* find result */
    lock(&__screenbuffer_lock__);
    wiiauto_util_find_image_blackwhite(screen_ptr, 4, view_width, view_height, bytes,
        img_ptr, img_channels, img_width, img_height, img_allocated_size, 20, search_threshold, count, 
        range[0], range[1], range[0] + range[2], range[1] + range[3],
        result_i32);
    unlock(&__screenbuffer_lock__);

    buffer_length(result_i32, sizeof(int[2]), &len);
    i32 xy[2];
    for (int i = 0; i < len; ++i) {
        buffer_get(result_i32, sizeof(int[2]), i, xy);
        if (xy[0] >= range[0] && xy[0] <= (range[0] + range[2]) && xy[1] >= range[1] && xy[1] <= (range[1] + range[3])) {
            buffer_append(result, &(f32[2]){xy[0], xy[1]}, sizeof(f32[2]));
        }
    }

finish:
    release(result_i32.iobj);
    release(burl.iobj);
    release(img.iobj);
}

typedef struct
{
    i32 color;
    i32 x;
    i32 y;
}
__base;

static inline void __rgb_to_int(const u8 r, const u8 g, const u8 b, i32 *color)
{
    *color = ((r&0x0ff)<<16)|((g&0x0ff)<<8)|(b&0x0ff);
}

static inline void __int_to_rgb(const i32 color, u8 *r, u8 *g, u8 *b)
{
    *r = (color >> 16) & 0x000000ff;
    *g = (color >> 8) & 0x000000ff;
    *b = color & 0x000000ff;
}

void common_find_colors(const buffer colors, const u32 count, const i32 range[4], const buffer result, const u8 check_color_offset)
{
    u32 len;
    const __base *ptr = NULL;
    u8 *in_colors;
    int *in_offsets;
    int i, j, k;
    u32 view_width, view_height;
    u32 screen_width, screen_height;
    const u8 *screen_ptr;

    buffer result_i32;

    buffer_length(colors, sizeof(__base), &len);
    if (len == 0) goto finish;

    buffer_new(&result_i32);

    wiiauto_device_get_current_screen_buffer(&screen_ptr, &screen_width, &screen_height);
    common_get_view_size(&view_width, &view_height);

    int pageSize = getpagesize();
    u32 bytes = view_width * view_height * 4;
    u32 mod = bytes % pageSize;
    if (mod != 0) {
        bytes = (bytes / pageSize + 1) * pageSize;
    }

    buffer_get_ptr(colors, &ptr);

    in_colors = malloc(len * 4 * sizeof(u8));
    in_offsets = malloc(len * 2 * sizeof(int));

    for (i = 0, j = 0, k = 0; i < len; ++i, j += 2, k += 4) {
        in_offsets[j] = ptr[i].x;
        in_offsets[j + 1] = ptr[i].y;

        __int_to_rgb(ptr[i].color, &in_colors[k], &in_colors[k + 1], &in_colors[k + 2]);
        in_colors[k + 3] = 255;
    }

    wiiauto_util_find_colors(
        screen_ptr, 4, view_width, view_height, bytes,
        in_colors, in_offsets, len, count, result_i32);

    buffer_length(result_i32, sizeof(int[2]), &len);
    i32 xy[2];
    for (int i = 0; i < len; ++i) {
        buffer_get(result_i32, sizeof(int[2]), i, xy);
        if (xy[0] >= range[0] && xy[0] <= (range[0] + range[2]) && xy[1] >= range[1] && xy[1] <= (range[1] + range[3])) {
            buffer_append(result, &(f32[2]){xy[0], xy[1]}, sizeof(f32[2]));
        }
    }

    free(in_colors);
    free(in_offsets);
    release(result_i32.iobj);

finish:
    ;
}
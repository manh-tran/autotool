#include "handler.h"
#include "cherry/graphic/image.h"
#include "wiiauto/util/util.h"
#include "wiiauto/common/common.h"
#include "cherry/util/util.h"
#include "cherry/core/buffer.h"

void wiiauto_tool_run_test_compare(const int argc, const char **argv)
{
    wiiauto_tool_register();

    const u8 *src;
    u32 src_width, src_height, src_allocated_size, src_channels;

    u8 *dst, *output;
    u32 dst_width, dst_height, dst_allocated_size, dst_channels;

    int max_result;
    char src_path[1024];
    char dst_path[1024];

    sprintf(src_path, "wiiauto_internal://Images/%s", argv[2]);
    sprintf(dst_path, "wiiauto_internal://Images/%s", argv[3]);

    max_result = atoi(argv[4]);
    u32 grid = atoi(argv[5]);
    float threshold = atof(argv[6]);
    
    image src_img;
    image_new(&src_img);
    image_load_file(src_img, src_path, (f32[3]){1, 1, 1});
    image_get_ptr(src_img, &src);
    image_get_size(src_img, &src_width, &src_height);
    image_get_allocated_size(src_img, &src_allocated_size);
    image_get_number_channels(src_img, &src_channels);

    image dst_img;
    image_new(&dst_img);
    image_load_file(dst_img, dst_path, (f32[3]){1, 1, 1});
    image_get_ptr(dst_img, &dst);
    image_get_size(dst_img, &dst_width, &dst_height);
    image_get_allocated_size(dst_img, &dst_allocated_size);
    image_get_number_channels(dst_img, &dst_channels);

    posix_memalign(&output, getpagesize(), dst_allocated_size);

    int xy[2];
    buffer result;
    u32 result_len;

    buffer_new(&result);
    wiiauto_util_find_image(src, src_channels, src_width, src_height, src_allocated_size,
        dst, dst_channels, dst_width, dst_height, dst_allocated_size, grid, threshold, max_result, 
        0, 0, src_width, src_height,
        result);

    buffer_length(result, sizeof(int[2]), &result_len);
    for (int i = 0; i < result_len; ++i) {
        buffer_get(result, sizeof(int[2]), i, xy);
        printf("%d, %d\n", xy[0], xy[1]);
    }

    // wiiauto_util_compare_image(src, src_width, src_height, src_allocated_size,
    //     dst, dst_width, dst_height, dst_allocated_size, output);
    // common_write_png("wiiauto_internal://test.png", output, dst_width, dst_height);

    release(result.iobj);
    release(src_img.iobj);
    release(dst_img.iobj);
    free(output);
}
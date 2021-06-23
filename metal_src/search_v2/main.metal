#include <metal_stdlib>
using namespace metal;

struct info
{
    int frame_width;
    int frame_height;
    int image_width;
    int image_height;
    int frame_start_x;
    int frame_start_y;
    int frame_work_width;
    int frame_work_height;

    int found_x[100];
    int found_y[100];
    int max_found;
};

kernel void find(
    device const uchar4 *src, 
    device const uchar4 *dst,
    device info *des,
    volatile device atomic_int &result_counter,
    uint index [[thread_position_in_grid]])
{
    int frame_width = des[0].frame_width;
    int frame_height = des[0].frame_height;
    int image_width = des[0].image_width;
    int image_height = des[0].image_height;
    int max_x = frame_width - image_width + 1;
    int max_y = frame_height - image_height + 1;
    int max_search_x = image_width - 2;
    int max_search_y = image_height - 2;
    int x = des[0].frame_start_x + int(index % des[0].frame_work_width);
    int y = des[0].frame_start_y + int(index / des[0].frame_work_width);

    int step_x = max(1, image_width / 10);
    int step_y = max(1, image_height / 10);

    if (x < max_x && y < max_y) {
        int failed = 0;

        for (int r = 0; r < max_search_y; r += step_y) {
            for (int c = 0; c < max_search_x; c += step_x) {

                int sf = 0;
                int ss = 0;

                for (int i = 0; i < 3; i++) {
                    for (int j = 0; j < 3; j++) {

                        uchar4 cf = src[(y + r + i) * frame_width + x + c + j];
                        uchar4 cs = dst[(r + i) * image_width + c + j];

                        int frgb = (cf.r/3 + cf.g/3 + cf.b/3);
                        sf = sf + frgb / 9;

                        int srgb = (cs.r/3 + cs.g/3 + cs.b/3);
                        ss = ss + srgb / 9;

                    }
                }

                if (absdiff(sf, ss) > 20) {
                    failed = 1;
                    break;
                }

            }

            if (failed) {
                break;
            }

        }

        if (failed == 0) {
            int idx = atomic_fetch_add_explicit(&result_counter, 1, memory_order_relaxed);
            if (idx < des[0].max_found) {
                des[0].found_x[idx] = x + image_width / 2;
                des[0].found_y[idx] = y + image_height / 2;
            }
        }

    }
}
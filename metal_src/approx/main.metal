#include <metal_stdlib>
using namespace metal;

/*
 * simple blur
 */
struct neighbor
{
    int ox;
    int oy;
    int rate;
};

static constant neighbor __neighbors__[] = {
    {-2,  2, 1}, {-1,  2, 1}, { 0,  2, 1}, { 1,  2, 1}, { 2,  2, 1},
    {-2,  1, 1}, {-1,  1, 2}, { 0,  1, 2}, { 1,  1, 2}, { 2,  1, 1},
    {-2,  0, 1}, {-1,  0, 2}, { 0,  0, 4}, { 1,  0, 2}, { 2,  0, 1},
    {-2, -1, 1}, {-1, -1, 2}, { 0, -1, 2}, { 1, -1, 2}, { 2, -1, 1},
    {-2, -2, 1}, {-1, -2, 1}, { 0, -2, 1}, { 1, -2, 1}, { 2, -2, 1},
};

static constant int __length__ = 25;

static constant float __sum__ = (
    (1 + 1 + 1 + 1 + 1) + 
    (1 + 2 + 2 + 2 + 1) + 
    (1 + 2 + 4 + 2 + 1) +
    (1 + 2 + 2 + 2 + 1) + 
    (1 + 1 + 1 + 1 + 1)
);

/* 
 * common 
 */
static int2 __get_neighbor(const int2 xy, const int ox, const int oy, const int width, const int height)
{
    return int2(clamp(xy.x + ox, 0, width - 1), clamp(xy.y + oy, 0, height - 1));
}

static float3 __uchar4s_get_float3(device const uchar4 *src, int width, int height, int row, int col)
{
    int r = clamp(row, 0, height - 1);
    int c = clamp(col, 0, width - 1);

    uchar4 cl = src[r * width + c];
    return float3(cl.r / 255.0, cl.g / 255.0, cl.b / 255.0);
}

static float3 __uchar3s_get_float3(device const packed_uchar3 *src, int width, int height, int row, int col)
{
    int r = clamp(row, 0, height - 1);
    int c = clamp(col, 0, width - 1);

    packed_uchar3 cl = src[r * width + c];
    return float3(cl[0] / 255.0, cl[1] / 255.0, cl[2] / 255.0);
}

/*
 * convert rgb to rgba
 */
kernel void rgb_to_rgba(
    device const uchar *src,
    device uchar4 *dst,
    uint index [[thread_position_in_grid]])
{
    int sindex = index * 3;
    dst[index] = uchar4(src[sindex], src[sindex + 1], src[sindex + 2], 255);
}

/*
 * approx
 */
struct approx_description
{
    float width;
    float height;
};

kernel void approx(device const uchar4 *src, 
    device const approx_description *des,
    device uchar4 *dst,
    uint index [[thread_position_in_grid]])
{
    int width = int(des[0].width);
    int height = int(des[0].height);

    int2 xy = int2(index % width, index / width);
    float3 combine = float3(0, 0, 0);

    for (int i = 0; i < __length__; i++) {
        neighbor n = __neighbors__[i];
        int2 point = __get_neighbor(xy, n.ox, n.oy, width, height);
        float3 color = __uchar4s_get_float3(src, width, height, point.y, point.x);
        combine += color * n.rate / __sum__;
    }

    dst[index] = uchar4(combine[0] * 255, combine[1] * 255, combine[2] * 255, 255);
}

kernel void approx_grayscale(device const uchar4 *src, 
    device const approx_description *des,
    device uchar4 *dst,
    uint index [[thread_position_in_grid]])
{
    int width = int(des[0].width);
    int height = int(des[0].height);

    int2 xy = int2(index % width, index / width);
    float3 combine = float3(0, 0, 0);

    for (int i = 0; i < __length__; i++) {
        neighbor n = __neighbors__[i];
        int2 point = __get_neighbor(xy, n.ox, n.oy, width, height);
        float3 color = __uchar4s_get_float3(src, width, height, point.y, point.x);
        combine += color * n.rate / __sum__;
    }

    float gs = (combine[0] + combine[1] + combine[2]) / 3.0;

    dst[index] = uchar4(gs * 255, gs * 255, gs * 255, 255);
}

kernel void approx_blackwhite(device const uchar4 *src, 
    device const approx_description *des,
    device uchar4 *dst,
    uint index [[thread_position_in_grid]])
{
    int width = int(des[0].width);
    int height = int(des[0].height);
    
    int2 xy = int2(index % width, index / width);
    float3 combine = float3(0, 0, 0);

    for (int i = 0; i < __length__; i++) {
        neighbor n = __neighbors__[i];
        int2 point = __get_neighbor(xy, n.ox, n.oy, width, height);
        float3 color = __uchar4s_get_float3(src, width, height, point.y, point.x);
        float gs = (color[0] + color[1] + color[2]) / 3;
        if (gs > 0.94) {
            color = float3(1, 1, 1);
        } else {
            color = float3(0, 0, 0);
        }
        combine += color * n.rate / __sum__;
    }

    // float gs = (combine[0] + combine[1] + combine[2]) / 3.0;
    // if (gs > 0.94) {
    //     gs = 1;
    // } else {
    //     gs = 0;
    // }

    // dst[index] = uchar4(gs * 255, gs * 255, gs * 255, 255);
    dst[index] = uchar4(combine[0] * 255, combine[1] * 255, combine[2] * 255, 255);
}

kernel void approx_rgb(device const packed_uchar3 *src, 
    device const approx_description *des,
    device uchar4 *dst,
    uint index [[thread_position_in_grid]])
{
    int width = int(des[0].width);
    int height = int(des[0].height);

    int2 xy = int2(index % width, index / width);
    float3 combine = float3(0, 0, 0);

    for (int i = 0; i < __length__; i++) {
        neighbor n = __neighbors__[i];
        int2 point = __get_neighbor(xy, n.ox, n.oy, width, height);
        float3 color = __uchar3s_get_float3(src, width, height, point.y, point.x);
        combine += color * n.rate / __sum__;
    }

    dst[index] = uchar4(combine[0] * 255, combine[1] * 255, combine[2] * 255, 255);
}

kernel void approx_rgb_grayscale(device const packed_uchar3 *src, 
    device const approx_description *des,
    device uchar4 *dst,
    uint index [[thread_position_in_grid]])
{
    int width = int(des[0].width);
    int height = int(des[0].height);

    int2 xy = int2(index % width, index / width);
    float3 combine = float3(0, 0, 0);

    for (int i = 0; i < __length__; i++) {
        neighbor n = __neighbors__[i];
        int2 point = __get_neighbor(xy, n.ox, n.oy, width, height);
        float3 color = __uchar3s_get_float3(src, width, height, point.y, point.x);
        combine += color * n.rate / __sum__;
    }

    float gs = (combine[0] + combine[1] + combine[2]) / 3.0;

    dst[index] = uchar4(gs * 255, gs * 255, gs * 255, 255);
}

kernel void approx_rgb_blackwhite(device const packed_uchar3 *src, 
    device const approx_description *des,
    device uchar4 *dst,
    uint index [[thread_position_in_grid]])
{
    int width = int(des[0].width);
    int height = int(des[0].height);

    int2 xy = int2(index % width, index / width);
    float3 combine = float3(0, 0, 0);

    for (int i = 0; i < __length__; i++) {
        neighbor n = __neighbors__[i];
        int2 point = __get_neighbor(xy, n.ox, n.oy, width, height);
        float3 color = __uchar3s_get_float3(src, width, height, point.y, point.x);
        float gs = (color[0] + color[1] + color[2]) / 3;
        if (gs > 0.94) {
            color = float3(1, 1, 1);
        } else {
            color = float3(0, 0, 0);
        }
        combine += color * n.rate / __sum__;
    }

    // float gs = (combine[0] + combine[1] + combine[2]) / 3.0;
    // if (gs > 0.94) {
    //     gs = 1;
    // } else {
    //     gs = 0;
    // }

    // dst[index] = uchar4(gs * 255, gs * 255, gs * 255, 255);
    dst[index] = uchar4(combine[0] * 255, combine[1] * 255, combine[2] * 255, 255);
}

/*
 * find image
 */
struct find_description
{
    float src_width;
    float src_height;
    float dst_width;
    float dst_height;
    float grid;
    float threshold;
    int max_result;
    int from_x;
    int from_y;
    int to_x;
    int to_y;
};

kernel void find(
    device const uchar4 *src, 
    device const uchar4 *dst,
    device const find_description *des,
    device int2 *result,
    volatile device atomic_int &result_counter,
    uint index [[thread_position_in_grid]])
{
    const int src_width = int(des[0].src_width);
    const int src_height = int(des[0].src_height);

    const int dst_width = int(des[0].dst_width);
    const int dst_height = int(des[0].dst_height);

    const int from_x = des[0].from_x;
    const int from_y = des[0].from_y;
    const int to_x = des[0].to_x;
    const int to_y = des[0].to_y;

    const float grid = des[0].grid;
    const float threshold = des[0].threshold;
    const int max_result = des[0].max_result;

    int same = 0;
    int iterate = 0;
    int2 xy = int2(index % src_width, index / src_width);

    const int max_x = src_width - dst_width;
    const int max_y = src_height - dst_height;

    if (xy.x <= max_x && xy.y <= max_y) {
        int oi = dst_width / grid;
        int oj = dst_height / grid;
        oi = max(oi, 1);
        oj = max(oj, 1);
        for (int i = 2; i < dst_width - 2; i += oi) {
            for (int j = 2; j < dst_height - 2; j += oj) {
                iterate++;

                uchar4 dp = dst[j * dst_width + i];
                uchar4 sp = src[(xy.y + j) * src_width + xy.x + i];

                float3 p1 = float3(dp.r, dp.g, dp.b);
                float3 p2 = float3(sp.r, sp.g, sp.b);
                float d = distance(p1, p2);
        
                if (d < 25) {
                    same++;
                }
            }
        }

        if (same * 1.0f / iterate >= threshold) {
            int target_x = xy.x + dst_width / 2;
            int target_y = xy.y + dst_height / 2;
            if (target_x >= from_x && target_x <= to_x && target_y >= from_y && target_y <= to_y) {
                int value = atomic_fetch_add_explicit(&result_counter, 1, memory_order_relaxed);
                if (value < max_result) {
                    result[value].x = target_x;
                    result[value].y = target_y;
                }
            }
        }
    }
}

/*
 * find points
 */

struct find_points_description
{
    float src_width;
    float src_height;
    int points_length;
    int max_result;
};

kernel void find_points(
    device const uchar4 *src, 
    device const uchar4 *dst,
    device const int2 *offset,
    device const find_points_description *des,
    device int2 *result,
    volatile device atomic_int &result_counter,
    uint index [[thread_position_in_grid]])
{
    const int src_width = int(des[0].src_width);
    const int src_height = int(des[0].src_height);
    const int points_length = des[0].points_length;
    const int max_result = des[0].max_result;
    int same = 1;

    int2 xy = int2(index % src_width, index / src_width);

    for (int i = 0; i < points_length; i++) {
        int2 oxy = int2(xy.x + offset[i].x - offset[0].x, xy.y + offset[i].y - offset[0].y);
        if (oxy.x < 0 || oxy.x >= src_width || oxy.y < 0 || oxy.y >= src_height) {
            same = 0;
            break;
        }

        uchar4 dp = dst[i];
        uchar4 sp = src[oxy.y * src_width + oxy.x];

        float3 p1 = float3(dp.r, dp.g, dp.b);
        float3 p2 = float3(sp.r, sp.g, sp.b);
        float d = distance(p1, p2);
        if (d > 10) {
            same = 0;
            break;
        }
    }

    if (same > 0) {
        int value = atomic_fetch_add_explicit(&result_counter, 1, memory_order_relaxed);
        if (value < max_result) {
            result[value].x = xy.x;
            result[value].y = xy.y;
        }
    }
}
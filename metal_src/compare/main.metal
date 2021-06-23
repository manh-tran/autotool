#include <metal_stdlib>
using namespace metal;

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

struct description
{
    float src_Ox;
    float src_Oy;
    float src_width;
    float src_height;
    float dst_width;
    float dst_height;
};

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

kernel void compare(device const uchar4 *src, 
                    device const uchar4 *dst,
                    device const description *des,
                    device uchar4 *result,
                    uint index [[thread_position_in_grid]])
{
    int dst_width = int(des[0].dst_width);
    int dst_height = int(des[0].dst_height);

    int src_width = int(des[0].src_width);
    int src_height = int(des[0].src_height);

    int2 Oxy = int2(des[0].src_Ox, des[0].src_Oy);
    int2 dst_xy = int2(index % dst_width, index / dst_width);

    float3 dst_check = float3(0, 0, 0);
    float3 src_check = float3(0, 0, 0);

    for (int i = 0; i < __length__; i++) {

        neighbor n = __neighbors__[i];

        int2 dst_point = __get_neighbor(dst_xy, n.ox, n.oy, dst_width, dst_height);
        int2 src_point = dst_point + Oxy;

        float3 dst_color = __uchar4s_get_float3(dst, dst_width, dst_height, dst_point.y, dst_point.x);
        float3 src_color = __uchar4s_get_float3(src, src_width, src_height, src_point.y, src_point.x);

        dst_check += dst_color * n.rate / __sum__;
        src_check += src_color * n.rate / __sum__;
    }

    float3 dst_color = float3(uchar3(dst_check[0] * 255, dst_check[1] * 255, dst_check[2] * 255));
    float3 src_color = float3(uchar3(src_check[0] * 255, src_check[1] * 255, src_check[2] * 255));

    float d = distance(dst_color, src_color);

    result[index] = d <= 50 ? uchar4(d, d, d, 255) : uchar4(255, 255, 255, 255);
}
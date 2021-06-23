#include <metal_stdlib>
using namespace metal;

struct description
{
    float width;
    float height;
    float dx;
    float dy;
};

static float3 __uchar4s_get_float3(device const uchar4 *src, int width, int height, int row, int col)
{
    int r = clamp(row, 0, height - 1);
    int c = clamp(col, 0, width - 1);

    uchar4 cl = src[r * width + c];
    return float3(cl.r / 255.0, cl.g / 255.0, cl.b / 255.0);
}

kernel void blur(   device const uchar4 *src, 
                    device uchar4 *dst,
                    device const description *des,
                    uint index [[thread_position_in_grid]])
{
    int width = int(des[0].width);
    int height = int(des[0].height);
    float dx = des[0].dx;
    float dy = des[0].dy;

    int row = index / width;
    int col = index % width;

    float3 sum = float3(0, 0, 0);
    
    sum += __uchar4s_get_float3(src, width, height, row - 4 * dy, col - 4 * dx) * 0.0162162162;
    sum += __uchar4s_get_float3(src, width, height, row - 3 * dy, col - 3 * dx) * 0.0540540541;
    sum += __uchar4s_get_float3(src, width, height, row - 2 * dy, col - 2 * dx) * 0.1216216216;
    sum += __uchar4s_get_float3(src, width, height, row - 1 * dy, col - 1 * dx) * 0.1945945946;
    sum += __uchar4s_get_float3(src, width, height, row, col) * 0.2270270270;
    sum += __uchar4s_get_float3(src, width, height, row + 1 * dy, col + 1 * dx) * 0.1945945946;
    sum += __uchar4s_get_float3(src, width, height, row + 2 * dy, col + 2 * dx) * 0.1216216216;
    sum += __uchar4s_get_float3(src, width, height, row + 3 * dy, col + 3 * dx) * 0.0540540541;
    sum += __uchar4s_get_float3(src, width, height, row + 4 * dy, col + 4 * dx) * 0.0162162162;

    dst[index] = uchar4(sum[0] * 255, sum[1] * 255, sum[2] * 255, 255);
}
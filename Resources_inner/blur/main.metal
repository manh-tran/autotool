/*
See LICENSE folder for this sample’s licensing information.

Abstract:
A shader that adds two arrays of floats.
*/

#include <metal_stdlib>
using namespace metal;

struct description
{
    float width;
    float height;
};

static float4 __get_pixel(device const float4 *src, int width, int height, int row, int col)
{
    int r = clamp(row, 0, height - 1);
    int c = clamp(col, 0, width - 1);

    return src[r * width + c];
}

kernel void blur(   device const float4 *src, 
                    device float4 *dst,
                    device const description *des,
                    uint index [[thread_position_in_grid]])
{
    int width = int(des[0].width);
    int height = int(des[0].height);

    int row = index / width;
    int col = index % width;

    float3 sum = float3(0.0, 0.0, 0.0);
    
    sum += __get_pixel(src, width, height, row - 4, col - 4).rgb * 0.0162162162;
    sum += __get_pixel(src, width, height, row - 3, col - 3).rgb * 0.0540540541;
    sum += __get_pixel(src, width, height, row - 2, col - 2).rgb * 0.1216216216;
    sum += __get_pixel(src, width, height, row - 1, col - 1).rgb * 0.1945945946;
    sum += __get_pixel(src, width, height, row, col).rgb * 0.2270270270;
    sum += __get_pixel(src, width, height, row + 1, col + 1).rgb * 0.1945945946;
    sum += __get_pixel(src, width, height, row + 2, col + 2).rgb * 0.1216216216;
    sum += __get_pixel(src, width, height, row + 3, col + 3).rgb * 0.0540540541;
    sum += __get_pixel(src, width, height, row + 4, col + 4).rgb * 0.0162162162;

    dst[index] = float4(sum[0], sum[1], sum[2], 1.0);
}
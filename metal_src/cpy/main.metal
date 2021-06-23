#include <metal_stdlib>
using namespace metal;

kernel void cpy_raw4(
    device const uchar4 *src,
    device uchar4 *dst,
    uint index [[thread_position_in_grid]])
{
    dst[index] = src[index];
}

kernel void cpy_bgra_to_rgba(
    device const uchar4 *src,
    device uchar4 *dst,
    uint index [[thread_position_in_grid]])
{
    uchar4 cv = src[index];
    uchar t = cv[0];
    cv[0] = cv[2];
    cv[2] = t;
    dst[index] = cv;
}
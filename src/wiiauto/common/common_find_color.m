#include "common.h"
#include "cherry/graphic/image.h"
#include "wiiauto/device/device.h"
#include "cherry/math/cmath.h"
#include <pthread.h>


// static inline int __same_color_off(const int a, const int b, const int off)
// {
//     int o = abs(a - b);
//     return (o <= off) ? 1 : 0;
// }

static inline int __same_color_off(const int r1, const int g1, const int b1, const int r2, const int g2, const int b2, const int check)
{
    if (!check) {
        return (r1 == r2) && (g1 == g2) && (b1 == b2);
    }

    int off1 = r1 - r2;
    int off2 = g1 - g2;
    int off3 = b1 - b2;

    int dst = sqrt(off1 * off1 + off2 * off2 + off3 * off3);

    return dst <= 2 ? 1 : 0;
}


static inline int __same_color(const int r1, const int g1, const int b1, const int r2, const int g2, const int b2)
{
    int off1 = r1 - r2;
    int off2 = g1 - g2;
    int off3 = b1 - b2;

    int dst = sqrt(off1 * off1 + off2 * off2 + off3 * off3);

    return dst <= 50 ? 1 : 0;
}


typedef struct
{
    float x;
    float y;
}
__xy;

static __xy __qpoints[] = {
    {0, 0}, {0.5, 0}, {1.0, 0},
    {0.25, 0.25}, {0.75, 0.25},
    {0, 0.5}, {0.5, 0.5}, {1.0, 0.5},
    {0.25, 0.75}, {0.75, 0.75},
    {0, 1.0}, {0.5, 1.0}, {1.0, 1.0} 
};

typedef struct
{
    int x;
    int y;
} 
__ixy;

static __ixy __qoffsets[] = {
    {0, 0}, {1, 0}, {-1, 0}, {0, 1}, {0, -1},{-1, -1}, {1, -1}, {-1, 1}, {1, 1}
};

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

void common_find_color(const i32 base, const u32 count, const i32 range[4], const buffer result)
{
    // lock(&__color_barrier__);

    i32 i, j, mi, mj, found, current, idx;
    const __wiiauto_pixel *pixels;
    u32 view_width, view_height;

    buffer_erase(result);

    common_get_view_size(&view_width, &view_height);
    common_get_device_color_pointer(&pixels);
    if (!pixels) {
        goto finish;
    }

    current = 0;

    mi = range[0] + range[2];
    mj = range[1] + range[3];
    for (i = range[0]; i < mi; ++i) {
        for (j = range[1]; j < mj; ++j) {
            idx = j * view_width + i;
            __rgb_to_int(pixels[idx].r, pixels[idx].g, pixels[idx].b, &found);

            if (found == base) {
                buffer_append(result, &(f32[2]){i, j}, sizeof(f32[2]));
                
                current++;
                if (count >= 0 && current == count) goto finish;
            }   
        }
    }
finish:;
    // unlock(&__color_barrier__);
}

typedef struct
{
    i32 color;
    i32 x;
    i32 y;
}
__base;

// void common_find_colors(const buffer colors, const u32 count, const i32 range[4], const buffer result, const u8 check_color_offset)
// {
//     // lock(&__color_barrier__);

//     i32 i, j, x, y, xx, yy, k, l, mi, mj, current, idx, same, offset;
//     u32 len;
//     const __base *ptr = NULL;
//     const __wiiauto_pixel *pixels;
//     u32 view_width, view_height;
//     u8 ir, ig, ib, tr, tg, tb;

//     common_get_view_size(&view_width, &view_height);

//     current = 0;

//     buffer_erase(result);
//     mi = range[0] + range[2];
//     mj = range[1] + range[3];

//     buffer_length(colors, sizeof(__base), &len);
    
//     if (len == 0) goto finish;

//     buffer_get_ptr(colors, &ptr);

//     common_get_device_color_pointer(&pixels);
//     if (!pixels) {
//         goto finish;
//     }

//     offset = check_color_offset ? 1 : 0;

//     for (i = range[0]; i < mi; ++i) {
//         for (j = range[1]; j < mj; ++j) {
            
//             same = 0;
//             for (k = 0; k < len; ++k) {
//                 x = i + ptr[k].x - ptr[0].x;
//                 y = j + ptr[k].y - ptr[0].y;

//                 __int_to_rgb(ptr[k].color, &tr, &tg, &tb);

//                 same = 0;
//                 for (l = 0; l < sizeof(__qoffsets) / sizeof(__qoffsets[0]); ++l) {
//                     xx = x + __qoffsets[l].x;
//                     yy = y + __qoffsets[l].y;
//                     if (xx < 0 || yy < 0 || xx >= mi || yy >= mj) continue;

//                     idx = yy * view_width + xx;
//                     ir = pixels[idx].r;
//                     ig = pixels[idx].g;
//                     ib = pixels[idx].b;

//                     if (__same_color_off(ir, ig, ib, tr, tg, tb, offset)) {
//                     // if (__same_color_off(ir, tr, offset) && __same_color_off(ig, tg, offset) && __same_color_off(ib, tb, offset)) {
//                         same = 1;
//                         break;
//                     }
//                     // if (offset == 0) break;
//                     break;
//                 }
//                 if (!same) {
//                     break;
//                 }
//             }
//             if (same) {
//                 buffer_append(result, &(f32[2]){i, j}, sizeof(f32[2]));

//                 current++;
//                 if (count >= 0 && current == count) goto finish;
//             }
//         }
//     }

// finish:;
//     // unlock(&__color_barrier__);
// }

// void common_find_image(const char *path, const u32 count, const f32 threshold, const i32 range[4], const buffer result)
// {
//     // lock(&__color_barrier__);

//     image img;
//     buffer burl;
//     const char *full_path;
//     u32 width = 0, height = 0, channels = 0;
//     u32 view_width, view_height;
//     const u8 *ptr;
//     i32 i, j, k, l, ii, jj, idx, mi, mj, x, y, current, ce, iwidth, iheight, checkw, checkh;
//     u8 ir, ig, ib, tr, tg, tb;
//     i32 max_error;
//     const __wiiauto_pixel *pixels;

//     common_get_view_size(&view_width, &view_height);

//     current = 0;
    
//     buffer_erase(result);
//     mi = range[0] + range[2];
//     mj = range[1] + range[3];

//     buffer_new(&burl);
//     common_get_script_url(path, burl);
//     buffer_get_ptr(burl, &full_path);

//     image_new(&img);
//     image_load_file(img, full_path, (f32[3]){1, 1, 1});
//     image_get_size(img, &width, &height);
//     image_get_ptr(img, &ptr);
//     image_get_number_channels(img, &channels);

//     iwidth = width;
//     iheight = height;

//     if (width == 0 || height == 0 || !ptr || channels < 3) goto finish;

//     common_get_device_color_pointer(&pixels);
//     if (!pixels) {
//         goto finish;
//     }

//     max_error = iwidth * iheight * (1.0 - threshold);
//     if (max_error < 0) max_error = 0;

//     checkw = mi - iwidth + 1;
//     checkh = mj - iheight + 1;

// #define CHECK(CI, CJ, CX, CY) \
//     do {\
//         int same = 0;\
// \
//         idx = (CY * iwidth + CX) * channels;\
//         tr = ptr[idx];\
//         tg = ptr[idx + 1];\
//         tb = ptr[idx + 2];\
// \
//         same = 0;\
// \
//         for (int OO = 0; OO < sizeof(__qoffsets) / sizeof(__qoffsets[0]); OO++) {\
//             ii = CI + CX + __qoffsets[OO].x;\
//             jj = CJ + CY + __qoffsets[OO].y;\
//             if (ii < 0 || jj < 0 || ii >= view_width || jj >= view_height) continue;\
// \
//             idx = jj * view_width + ii;\
//             ir = pixels[idx].r;\
//             ig = pixels[idx].g;\
//             ib = pixels[idx].b;\
// \
//             if (__same_color(ir, ig, ib, tr, tg, tb)) { \
//                 same = 1;\
//                 break;\
//             }\
//         }\
//         if (!same) {\
//             ce++;\
//             if (ce > max_error) goto next;\
//         }\
// \
//     } while (0);
    
//     for (i = range[0]; i < checkw; ++i) {
//         for (j = range[1]; j < checkh; ++j) {

//             ce = 0;

//             /*
//              * check pattern firsts
//              */
//             for (k = 0; k < sizeof(__qpoints) / sizeof(__qpoints[0]); ++k) {
//                 x = __qpoints[k].x * (iwidth - 1);
//                 y = __qpoints[k].y * (iheight - 1);

//                 CHECK(i, j, x, y);
//             }

//             /*
//              * deep check
//              */
//             for (k = iwidth / 2; k >= 0; k -= 3) {
//                 for (l = iheight / 2; l >= 0; l -= 3) {
//                     CHECK(i, j, k, l);
//                 }
//             }
//             for (k = iwidth / 2; k < iwidth; k += 3) {
//                 for (l = iheight / 2; l >= 0; l -= 3) {
//                     CHECK(i, j, k, l);
//                 }
//             }
//             for (k = iwidth / 2; k >= 0; k -= 3) {
//                 for (l = iheight / 2; l < iheight; l += 3) {
//                     CHECK(i, j, k, l);
//                 }
//             }
//             for (k = iwidth / 2; k < iwidth; k += 3) {
//                 for (l = iheight / 2; l < iheight; l += 3) {
//                     CHECK(i, j, k, l);
//                 }
//             }

//             buffer_append(result, &(f32[2]){i + iwidth * 0.5f, j  + iheight * 0.5f}, sizeof(f32[2]));

//             current++;
//             if (count >= 0 && current == count) goto finish;

//         next:
//             ;
//         }
//     }

// finish:
//     release(img.iobj);
//     release(burl.iobj);
//     // unlock(&__color_barrier__);

// #undef CHECK
// }

void common_find_image_in_image(const char *path1, const char *path2, const u32 count, const buffer result)
{
    buffer burl;
    const char *full_path;
    image img1, img2;
    u32 width1, height1, width2, height2;
    const u8 *ptr1, *ptr2;
    u32 channels1, channels2;
    int ii, jj, idx, i, j, k, l,x , y;
    u8 ir, ig, ib, tr, tg, tb;
    int ce, max_error;
    int current = 0;

    buffer_new(&burl);

    common_get_script_url(path1, burl);
    buffer_get_ptr(burl, &full_path);
    image_new(&img1);
    image_load_file(img1, full_path, (f32[3]){1, 1, 1});
    image_get_size(img1, &width1, &height1);
    image_get_ptr(img1, &ptr1);
    image_get_number_channels(img1, &channels1);

    common_get_script_url(path2, burl);
    buffer_get_ptr(burl, &full_path);
    image_new(&img2);
    image_load_file(img2, full_path, (f32[3]){1, 1, 1});
    image_get_size(img2, &width2, &height2);
    image_get_ptr(img2, &ptr2);
    image_get_number_channels(img2, &channels2);

    buffer_erase(result);

    if (width1 == 0 || height1 == 0 || !ptr1 || channels1 < 3) goto finish;
    if (width2 == 0 || height2 == 0 || !ptr2 || channels2 < 3) goto finish;

    max_error = 0;

#define CHECK(CI, CJ, CX, CY) \
    do {\
        int same = 0;\
\
        idx = (CY * width2 + CX) * channels2;\
        tr = ptr2[idx];\
        tg = ptr2[idx + 1];\
        tb = ptr2[idx + 2];\
\
        same = 0;\
\
        for (int OO = 0; OO < sizeof(__qoffsets) / sizeof(__qoffsets[0]); OO++) {\
            ii = CI + CX + __qoffsets[OO].x;\
            jj = CJ + CY + __qoffsets[OO].y;\
            if (ii < 0 || jj < 0 || ii >= width1 || jj >= height1) continue;\
\
            idx = (jj * width1 + ii) * channels1;\
            ir = ptr1[idx];\
            ig = ptr1[idx + 1];\
            ib = ptr1[idx + 2];\
\
            if (__same_color(ir, ig, ib, tr, tg, tb)) { \
                same = 1;\
                break;\
            }\
        }\
        if (!same) {\
            ce++;\
            if (ce > max_error) goto next;\
        }\
\
    } while (0);   

    for (i = 0; i < width1; ++i) {
        for (j = 0; j < height1; ++j) {

            ce = 0;

            /*
             * check pattern firsts
             */
            for (k = 0; k < sizeof(__qpoints) / sizeof(__qpoints[0]); ++k) {
                x = __qpoints[k].x * (width2 - 1);
                y = __qpoints[k].y * (height2 - 1);

                CHECK(i, j, x, y);
            }

            /*
             * deep check
             */
            for (k = width2 / 2; k >= 0; k -= 3) {
                for (l = height2 / 2; l >= 0; l -= 3) {
                    CHECK(i, j, k, l);
                }
            }
            for (k = width2 / 2; k < width2; k += 3) {
                for (l = height2 / 2; l >= 0; l -= 3) {
                    CHECK(i, j, k, l);
                }
            }
            for (k = width2 / 2; k >= 0; k -= 3) {
                for (l = height2 / 2; l < height2; l += 3) {
                    CHECK(i, j, k, l);
                }
            }
            for (k = width2 / 2; k < width2; k += 3) {
                for (l = height2 / 2; l < height2; l += 3) {
                    CHECK(i, j, k, l);
                }
            }

            buffer_append(result, &(f32[2]){i + width2 * 0.5f, j  + height2 * 0.5f}, sizeof(f32[2]));

            current++;
            if (count > 0 && current == count) goto finish;

        next:
            ;
        }
    }
    
finish:
    release(img1.iobj);
    release(img2.iobj);
    release(burl.iobj);

#undef CHECK
}
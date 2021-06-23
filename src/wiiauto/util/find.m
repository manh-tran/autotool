#include "util.h"
#include "cherry/core/buffer.h"
#include "wiiauto/file/file.h"
#include "wiiauto/common/common.h"

#import <Metal/Metal.h>
#import <MetalKit/MetalKit.h>
#import <stdatomic.h>

struct description
{
    float width;
    float height;
};

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

static id<MTLDevice> __device__ = nil;
static id<MTLComputePipelineState> __pipeline_approx__ = nil;
static id<MTLComputePipelineState> __pipeline_approx_rgb__ = nil;
static id<MTLComputePipelineState> __pipeline_approx_grayscale__ = nil;
static id<MTLComputePipelineState> __pipeline_approx_rgb_grayscale__ = nil;
static id<MTLComputePipelineState> __pipeline_approx_blackwhite__ = nil;
static id<MTLComputePipelineState> __pipeline_approx_rgb_blackwhite__ = nil;
static id<MTLComputePipelineState> __pipeline_find__ = nil;
static id<MTLComputePipelineState> __pipeline_find_points__ = nil;
static id<MTLComputePipelineState> __pipeline_find_v2__ = nil;
static id<MTLCommandQueue> __queue__ = nil;
static id<MTLLibrary> __lib__ = nil;
static id<MTLFunction> __method_approx__ = nil;
static id<MTLFunction> __method_approx_rgb__ = nil;
static id<MTLFunction> __method_approx_grayscale__ = nil;
static id<MTLFunction> __method_approx_rgb_grayscale__ = nil;
static id<MTLFunction> __method_approx_blackwhite__ = nil;
static id<MTLFunction> __method_approx_rgb_blackwhite__ = nil;
static id<MTLFunction> __method_find__ = nil;
static id<MTLFunction> __method_find_points__ = nil;
static id<MTLFunction> __method_find_v2__ = nil;

static void __setup()
{
    static spin_lock __barrier__ = SPIN_LOCK_INIT;
    buffer b;
    const char *ptr;

    lock(&__barrier__);

    if (__queue__) {
        goto finish;
    }

    @autoreleasepool {

        buffer_new(&b);
        wiiauto_convert_url("wiiauto_internal://Metals/approx/main.metallib", b);
        buffer_get_ptr(b, &ptr);
        NSString *nspath = [NSString stringWithUTF8String: ptr];
        NSError* error = nil;
        release(b.iobj);

        __device__ = MTLCreateSystemDefaultDevice();

        __lib__ = [__device__ newLibraryWithFile:nspath error:&error];
        if (__lib__ == nil)
        {
            goto finish;
        }

        /*
         * approx
         */
        __method_approx__ = [__lib__ newFunctionWithName:@"approx"];
        if (__method_approx__ == nil)
        {
            goto finish;
        }

        __pipeline_approx__ = [__device__ newComputePipelineStateWithFunction:__method_approx__ error:&error];
        if (__pipeline_approx__ == nil)
        {
            goto finish;
        }

        /*
         * approx grayscale
         */
        __method_approx_grayscale__ = [__lib__ newFunctionWithName:@"approx_grayscale"];
        if (__method_approx_grayscale__ == nil)
        {
            goto finish;
        }

        __pipeline_approx_grayscale__ = [__device__ newComputePipelineStateWithFunction:__method_approx_grayscale__ error:&error];
        if (__pipeline_approx_grayscale__ == nil)
        {
            goto finish;
        }

        /*
         * approx blackwhite
         */
        __method_approx_blackwhite__ = [__lib__ newFunctionWithName:@"approx_blackwhite"];
        if (__method_approx_blackwhite__ == nil)
        {
            goto finish;
        }

        __pipeline_approx_blackwhite__ = [__device__ newComputePipelineStateWithFunction:__method_approx_blackwhite__ error:&error];
        if (__pipeline_approx_blackwhite__ == nil)
        {
            goto finish;
        }

        /*
         * approx_rgb
         */
        __method_approx_rgb__ = [__lib__ newFunctionWithName:@"approx_rgb"];
        if (__method_approx_rgb__ == nil)
        {
            goto finish;
        }

        __pipeline_approx_rgb__ = [__device__ newComputePipelineStateWithFunction:__method_approx_rgb__ error:&error];
        if (__pipeline_approx_rgb__ == nil)
        {
            goto finish;
        }

        /*
         * approx_rgb grayscale
         */
        __method_approx_rgb_grayscale__ = [__lib__ newFunctionWithName:@"approx_rgb_grayscale"];
        if (__method_approx_rgb_grayscale__ == nil)
        {
            goto finish;
        }

        __pipeline_approx_rgb_grayscale__ = [__device__ newComputePipelineStateWithFunction:__method_approx_rgb_grayscale__ error:&error];
        if (__pipeline_approx_rgb_grayscale__ == nil)
        {
            goto finish;
        }

        /*
         * approx_rgb blackwhite
         */
        __method_approx_rgb_blackwhite__ = [__lib__ newFunctionWithName:@"approx_rgb_blackwhite"];
        if (__method_approx_rgb_blackwhite__ == nil)
        {
            goto finish;
        }

        __pipeline_approx_rgb_blackwhite__ = [__device__ newComputePipelineStateWithFunction:__method_approx_rgb_blackwhite__ error:&error];
        if (__pipeline_approx_rgb_blackwhite__ == nil)
        {
            goto finish;
        }

        /*
         * find
         */
        __method_find__ = [__lib__ newFunctionWithName:@"find"];
        if (__method_find__ == nil)
        {
            goto finish;
        }

        __pipeline_find__ = [__device__ newComputePipelineStateWithFunction:__method_find__ error:&error];
        if (__pipeline_find__ == nil)
        {
            goto finish;
        }

        /*
         * find_points
         */
        __method_find_points__ = [__lib__ newFunctionWithName:@"find_points"];
        if (__method_find_points__ == nil)
        {
            goto finish;
        }

        __pipeline_find_points__ = [__device__ newComputePipelineStateWithFunction:__method_find_points__ error:&error];
        if (__pipeline_find_points__ == nil)
        {
            goto finish;
        }

        /*
         * find_v2
         */
        __method_find_v2__ = [__lib__ newFunctionWithName:@"find_v2"];
        if (__method_find_v2__ == nil)
        {
            if (error) {
                NSString *ers = [error localizedDescription];
                const char *ss = [ers UTF8String];
                printf("error1: %s\n", ss);
            } else {
                printf("error1-unknown\n");
            }

            goto finish;
        }

        __pipeline_find_v2__ = [__device__ newComputePipelineStateWithFunction:__method_find_v2__ error:&error];
        if (__pipeline_find_v2__ == nil)
        {
            if (error) {
                NSString *ers = [error localizedDescription];
                const char *ss = [ers UTF8String];
                printf("error2: %s\n", ss);
            } else {
                printf("error2-unknown\n");
            }
            goto finish;
        }



        __queue__ = [__device__ newCommandQueue];
        if (__queue__ == nil)
        {
            goto finish;
        }
    }

finish:
    unlock(&__barrier__);
}

typedef struct __attribute__((packed))
{
    u8 r;
    u8 g;
    u8 b;
    u8 a;
}
__pixel;

static id<MTLBuffer> __approx(
    id<MTLCommandBuffer> cmb, const u8 *src, const u32 width, const u32 height, const u32 allocation_size)
{
    id<MTLBuffer> b_approx_src = [__device__ 
            newBufferWithLength:allocation_size
            options:MTLResourceStorageModeShared];

    @autoreleasepool {
        id<MTLBuffer> b_src = [__device__ 
            newBufferWithBytesNoCopy:src
            length:allocation_size
            options:MTLResourceStorageModeShared
            deallocator:nil];

        struct description des;
        des.width = width;
        des.height = height;

        id<MTLBuffer> b_des = [__device__ 
            newBufferWithBytes:&des 
            length:sizeof(des) 
            options:MTLResourceStorageModeShared];

        id<MTLComputeCommandEncoder> encoder = [cmb computeCommandEncoder];
        [encoder setComputePipelineState:__pipeline_approx__];
        [encoder setBuffer:b_src offset:0 atIndex:0];
        [encoder setBuffer:b_des offset:0 atIndex:1];
        [encoder setBuffer:b_approx_src offset:0 atIndex:2];

        int arrayLength = width * height;
        MTLSize gridSize = MTLSizeMake(arrayLength, 1, 1);
        NSUInteger threadGroupSize = __pipeline_approx__.maxTotalThreadsPerThreadgroup;
        if (threadGroupSize > arrayLength) {
            threadGroupSize = arrayLength;
        }
        MTLSize threadgroupSize = MTLSizeMake(threadGroupSize, 1, 1);
        [encoder dispatchThreadgroups:MTLSizeMake((arrayLength + threadGroupSize - 1) / threadGroupSize, 1, 1) threadsPerThreadgroup:threadgroupSize];
        [encoder endEncoding];
    }

    return b_approx_src;
}

static id<MTLBuffer> __approx_grayscale(
    id<MTLCommandBuffer> cmb, const u8 *src, const u32 width, const u32 height, const u32 allocation_size)
{
    id<MTLBuffer> b_approx_src = [__device__ 
            newBufferWithLength:allocation_size
            options:MTLResourceStorageModeShared];

    @autoreleasepool {
        id<MTLBuffer> b_src = [__device__ 
            newBufferWithBytesNoCopy:src
            length:allocation_size
            options:MTLResourceStorageModeShared
            deallocator:nil];

        struct description des;
        des.width = width;
        des.height = height;

        id<MTLBuffer> b_des = [__device__ 
            newBufferWithBytes:&des 
            length:sizeof(des) 
            options:MTLResourceStorageModeShared];

        id<MTLComputeCommandEncoder> encoder = [cmb computeCommandEncoder];
        [encoder setComputePipelineState:__pipeline_approx_grayscale__];
        [encoder setBuffer:b_src offset:0 atIndex:0];
        [encoder setBuffer:b_des offset:0 atIndex:1];
        [encoder setBuffer:b_approx_src offset:0 atIndex:2];

        int arrayLength = width * height;
        MTLSize gridSize = MTLSizeMake(arrayLength, 1, 1);
        NSUInteger threadGroupSize = __pipeline_approx_grayscale__.maxTotalThreadsPerThreadgroup;
        if (threadGroupSize > arrayLength) {
            threadGroupSize = arrayLength;
        }
        MTLSize threadgroupSize = MTLSizeMake(threadGroupSize, 1, 1);
        [encoder dispatchThreadgroups:MTLSizeMake((arrayLength + threadGroupSize - 1) / threadGroupSize, 1, 1) threadsPerThreadgroup:threadgroupSize];
        [encoder endEncoding];
    }

    return b_approx_src;
}

static id<MTLBuffer> __approx_blackwhite(
    id<MTLCommandBuffer> cmb, const u8 *src, const u32 width, const u32 height, const u32 allocation_size)
{
    id<MTLBuffer> b_approx_src = [__device__ 
            newBufferWithLength:allocation_size
            options:MTLResourceStorageModeShared];

    @autoreleasepool {
        id<MTLBuffer> b_src = [__device__ 
            newBufferWithBytesNoCopy:src
            length:allocation_size
            options:MTLResourceStorageModeShared
            deallocator:nil];

        struct description des;
        des.width = width;
        des.height = height;

        id<MTLBuffer> b_des = [__device__ 
            newBufferWithBytes:&des 
            length:sizeof(des) 
            options:MTLResourceStorageModeShared];

        id<MTLComputeCommandEncoder> encoder = [cmb computeCommandEncoder];
        [encoder setComputePipelineState:__pipeline_approx_blackwhite__];
        [encoder setBuffer:b_src offset:0 atIndex:0];
        [encoder setBuffer:b_des offset:0 atIndex:1];
        [encoder setBuffer:b_approx_src offset:0 atIndex:2];

        int arrayLength = width * height;
        MTLSize gridSize = MTLSizeMake(arrayLength, 1, 1);
        NSUInteger threadGroupSize = __pipeline_approx_blackwhite__.maxTotalThreadsPerThreadgroup;
        if (threadGroupSize > arrayLength) {
            threadGroupSize = arrayLength;
        }
        MTLSize threadgroupSize = MTLSizeMake(threadGroupSize, 1, 1);
        [encoder dispatchThreadgroups:MTLSizeMake((arrayLength + threadGroupSize - 1) / threadGroupSize, 1, 1) threadsPerThreadgroup:threadgroupSize];
        [encoder endEncoding];
    }

    return b_approx_src;
}

static id<MTLBuffer> __approx_rgb(
    id<MTLCommandBuffer> cmb, const u8 *src, const u32 width, const u32 height, const u32 allocation_size)
{  
    /* convert rgb to rgba */
    int pageSize = getpagesize();
    u32 bytes = 4 * width * height;
    u32 mod = bytes % pageSize;
    if (mod != 0) {
        bytes = (bytes / pageSize + 1) * pageSize;
    }

    id<MTLBuffer> b_approx_src = [__device__ 
            newBufferWithLength:bytes
            options:MTLResourceStorageModeShared];

    @autoreleasepool {
        id<MTLBuffer> b_src = [__device__ 
            newBufferWithBytesNoCopy:src
            length:allocation_size
            options:MTLResourceStorageModeShared
            deallocator:nil];

        struct description des;
        des.width = width;
        des.height = height;

        id<MTLBuffer> b_des = [__device__ 
            newBufferWithBytes:&des 
            length:sizeof(des) 
            options:MTLResourceStorageModeShared];

        id<MTLComputeCommandEncoder> encoder = [cmb computeCommandEncoder];
        [encoder setComputePipelineState:__pipeline_approx_rgb__];
        [encoder setBuffer:b_src offset:0 atIndex:0];
        [encoder setBuffer:b_des offset:0 atIndex:1];
        [encoder setBuffer:b_approx_src offset:0 atIndex:2];

        int arrayLength = width * height;
        MTLSize gridSize = MTLSizeMake(arrayLength, 1, 1);
        NSUInteger threadGroupSize = __pipeline_approx_rgb__.maxTotalThreadsPerThreadgroup;
        if (threadGroupSize > arrayLength) {
            threadGroupSize = arrayLength;
        }
        MTLSize threadgroupSize = MTLSizeMake(threadGroupSize, 1, 1);
        [encoder dispatchThreadgroups:MTLSizeMake((arrayLength + threadGroupSize - 1) / threadGroupSize, 1, 1) threadsPerThreadgroup:threadgroupSize];
        [encoder endEncoding];
    }

    return b_approx_src;
}

static id<MTLBuffer> __approx_rgb_grayscale(
    id<MTLCommandBuffer> cmb, const u8 *src, const u32 width, const u32 height, const u32 allocation_size)
{  
    /* convert rgb to rgba */
    int pageSize = getpagesize();
    u32 bytes = 4 * width * height;
    u32 mod = bytes % pageSize;
    if (mod != 0) {
        bytes = (bytes / pageSize + 1) * pageSize;
    }

    id<MTLBuffer> b_approx_src = [__device__ 
            newBufferWithLength:bytes
            options:MTLResourceStorageModeShared];

    @autoreleasepool {
        id<MTLBuffer> b_src = [__device__ 
            newBufferWithBytesNoCopy:src
            length:allocation_size
            options:MTLResourceStorageModeShared
            deallocator:nil];

        struct description des;
        des.width = width;
        des.height = height;

        id<MTLBuffer> b_des = [__device__ 
            newBufferWithBytes:&des 
            length:sizeof(des) 
            options:MTLResourceStorageModeShared];

        id<MTLComputeCommandEncoder> encoder = [cmb computeCommandEncoder];
        [encoder setComputePipelineState:__pipeline_approx_rgb_grayscale__];
        [encoder setBuffer:b_src offset:0 atIndex:0];
        [encoder setBuffer:b_des offset:0 atIndex:1];
        [encoder setBuffer:b_approx_src offset:0 atIndex:2];

        int arrayLength = width * height;
        MTLSize gridSize = MTLSizeMake(arrayLength, 1, 1);
        NSUInteger threadGroupSize = __pipeline_approx_rgb_grayscale__.maxTotalThreadsPerThreadgroup;
        if (threadGroupSize > arrayLength) {
            threadGroupSize = arrayLength;
        }
        MTLSize threadgroupSize = MTLSizeMake(threadGroupSize, 1, 1);
        [encoder dispatchThreadgroups:MTLSizeMake((arrayLength + threadGroupSize - 1) / threadGroupSize, 1, 1) threadsPerThreadgroup:threadgroupSize];
        [encoder endEncoding];
    }

    return b_approx_src;
}

static id<MTLBuffer> __approx_rgb_blackwhite(
    id<MTLCommandBuffer> cmb, const u8 *src, const u32 width, const u32 height, const u32 allocation_size)
{  
    /* convert rgb to rgba */
    int pageSize = getpagesize();
    u32 bytes = 4 * width * height;
    u32 mod = bytes % pageSize;
    if (mod != 0) {
        bytes = (bytes / pageSize + 1) * pageSize;
    }

    id<MTLBuffer> b_approx_src = [__device__ 
            newBufferWithLength:bytes
            options:MTLResourceStorageModeShared];

    @autoreleasepool {
        id<MTLBuffer> b_src = [__device__ 
            newBufferWithBytesNoCopy:src
            length:allocation_size
            options:MTLResourceStorageModeShared
            deallocator:nil];

        struct description des;
        des.width = width;
        des.height = height;

        id<MTLBuffer> b_des = [__device__ 
            newBufferWithBytes:&des 
            length:sizeof(des) 
            options:MTLResourceStorageModeShared];

        id<MTLComputeCommandEncoder> encoder = [cmb computeCommandEncoder];
        [encoder setComputePipelineState:__pipeline_approx_rgb_blackwhite__];
        [encoder setBuffer:b_src offset:0 atIndex:0];
        [encoder setBuffer:b_des offset:0 atIndex:1];
        [encoder setBuffer:b_approx_src offset:0 atIndex:2];

        int arrayLength = width * height;
        MTLSize gridSize = MTLSizeMake(arrayLength, 1, 1);
        NSUInteger threadGroupSize = __pipeline_approx_rgb_blackwhite__.maxTotalThreadsPerThreadgroup;
        if (threadGroupSize > arrayLength) {
            threadGroupSize = arrayLength;
        }
        MTLSize threadgroupSize = MTLSizeMake(threadGroupSize, 1, 1);
        [encoder dispatchThreadgroups:MTLSizeMake((arrayLength + threadGroupSize - 1) / threadGroupSize, 1, 1) threadsPerThreadgroup:threadgroupSize];
        [encoder endEncoding];
    }

    return b_approx_src;
}

@interface result_find : NSObject
@property (strong) id<MTLBuffer> result;
@property (strong) id<MTLBuffer> counter;
@end

@implementation result_find
@end

static result_find *__find(
    id<MTLCommandBuffer> cmb, 
    id<MTLBuffer> b_src, const u32 src_width, const u32 src_height,
    id<MTLBuffer> b_dst, const u32 dst_width, const u32 dst_height,
    const u32 max_result, const u32 grid, const float threshold,
    const int from_x, const int from_y, const int to_x, const int to_y)
{
    result_find *ret = [[result_find alloc] init];

    int *r = malloc(sizeof(int[2]) * max_result);
    for (int i = 0; i < max_result * 2; ++i) {
        r[i] = -1;
    }

    @autoreleasepool {
        id<MTLBuffer> b_result = [__device__ 
            newBufferWithBytes:r
            length:(sizeof(int[2]) * max_result)
            options:MTLResourceStorageModeShared];
        ret.result = b_result;
        free(r);
    
        struct find_description des;
        des.src_width = src_width;
        des.src_height = src_height;
        des.dst_width = dst_width;
        des.dst_height = dst_height;
        des.grid = grid;
        des.threshold = threshold;
        des.max_result = max_result;
        des.from_x = from_x;
        des.from_y = from_y;
        des.to_x = to_x;
        des.to_y = to_y;

        id<MTLBuffer> b_des = [__device__ 
            newBufferWithBytes:&des 
            length:sizeof(des) 
            options:MTLResourceStorageModeShared];

        atomic_int counter = 0;
        id<MTLBuffer> b_counter = [__device__ 
            newBufferWithBytes:&counter 
            length:sizeof(counter) 
            options:MTLResourceStorageModeShared];

        ret.counter = b_counter;

        id<MTLComputeCommandEncoder> encoder = [cmb computeCommandEncoder];
        [encoder setComputePipelineState:__pipeline_find__];
        [encoder setBuffer:b_src offset:0 atIndex:0];
        [encoder setBuffer:b_dst offset:0 atIndex:1];
        [encoder setBuffer:b_des offset:0 atIndex:2];
        [encoder setBuffer:b_result offset:0 atIndex:3];
        [encoder setBuffer:b_counter offset:0 atIndex:4];

        int arrayLength = src_width * src_height;
        MTLSize gridSize = MTLSizeMake(arrayLength, 1, 1);
        NSUInteger threadGroupSize = __pipeline_find__.maxTotalThreadsPerThreadgroup;
        if (threadGroupSize > arrayLength) {
            threadGroupSize = arrayLength;
        }
        MTLSize threadgroupSize = MTLSizeMake(threadGroupSize, 1, 1);
        [encoder dispatchThreadgroups:MTLSizeMake((arrayLength + threadGroupSize - 1) / threadGroupSize, 1, 1) threadsPerThreadgroup:threadgroupSize];
        [encoder endEncoding];
    }

    return ret;
}

void wiiauto_util_find_image(
    const u8 *src, const u32 src_channels, const u32 src_width, const u32 src_height, const u32 src_allocation_size,
    const u8 *dst, const u32 dst_channels, const u32 dst_width, const u32 dst_height, const u32 dst_allocation_size,
    const u32 grid, const float threshold,
    const u32 max_result, 
    const int from_x, const int from_y, const int to_x, const int to_y,
    const buffer result)
{   
    buffer_erase(result);

    __setup();
    if (!__queue__) goto finish;

    @autoreleasepool {  

        int gpu_max_result = max_result * 10;

        id<MTLCommandBuffer> cmb = [__queue__ commandBuffer];
        id<MTLBuffer> b_approx_src;
        id<MTLBuffer> b_approx_dst;
        
        if (src_channels == 4) {
            b_approx_src = __approx(cmb, src, src_width, src_height, src_allocation_size);
        } else {
            b_approx_src = __approx_rgb(cmb, src, src_width, src_height, src_allocation_size);
        }
        
        if (dst_channels == 4) {
            b_approx_dst = __approx(cmb, dst, dst_width, dst_height, dst_allocation_size);
        } else {
            b_approx_dst = __approx_rgb(cmb, dst, dst_width, dst_height, dst_allocation_size);
        }
        result_find *rf = __find(cmb, b_approx_src, src_width, src_height, b_approx_dst, dst_width, dst_height, gpu_max_result, grid, threshold, from_x, from_y, to_x, to_y);
        [cmb commit];
        [cmb waitUntilCompleted];

        id<MTLBuffer> b_result = rf.result;
        int *r = b_result.contents;

        u32 len;
        int bxy[2];
        float dst;
        u32 count = 0;
        int hw = dst_width / 2;
        int hh = dst_height / 2;
        for (int i = 0; i < gpu_max_result * 2; i += 2) {
            if (r[i] > 0 && r[i] < src_width && r[i + 1] > 0 && r[i + 1] < src_height) {
                
                u8 pass = 1;
                buffer_length(result, sizeof(int[2]), &len);
                for (int j = 0; j < len; ++j) {
                    buffer_get(result, sizeof(int[2]), j, bxy);
                    if ((abs(bxy[0] - r[i]) <= hw) && (abs(bxy[1] - r[i + 1]) <= hh)) {
                        pass = 0;
                    }
                }

                if (pass) {
                    buffer_append(result, r + i, sizeof(int));
                    buffer_append(result, r + i + 1, sizeof(int));
                    count++;
                    if (count == max_result) break;
                }
            }
        }
    }

finish:
    ;
}

void wiiauto_util_find_image_grayscale(
    const u8 *src, const u32 src_channels, const u32 src_width, const u32 src_height, const u32 src_allocation_size,
    const u8 *dst, const u32 dst_channels, const u32 dst_width, const u32 dst_height, const u32 dst_allocation_size,
    const u32 grid, const float threshold, const u32 max_result, 
    const int from_x, const int from_y, const int to_x, const int to_y,
    const buffer result)
{
    buffer_erase(result);

    __setup();
    if (!__queue__) goto finish;

    @autoreleasepool {  

        int gpu_max_result = max_result * 10;

        id<MTLCommandBuffer> cmb = [__queue__ commandBuffer];
        id<MTLBuffer> b_approx_src;
        id<MTLBuffer> b_approx_dst;
        
        if (src_channels == 4) {
            b_approx_src = __approx_grayscale(cmb, src, src_width, src_height, src_allocation_size);
        } else {
            b_approx_src = __approx_rgb_grayscale(cmb, src, src_width, src_height, src_allocation_size);
        }
        
        if (dst_channels == 4) {
            b_approx_dst = __approx_grayscale(cmb, dst, dst_width, dst_height, dst_allocation_size);
        } else {
            b_approx_dst = __approx_rgb_grayscale(cmb, dst, dst_width, dst_height, dst_allocation_size);
        }
        result_find *rf = __find(cmb, b_approx_src, src_width, src_height, b_approx_dst, dst_width, dst_height, gpu_max_result, grid, threshold, from_x, from_y, to_x, to_y);
        [cmb commit];
        [cmb waitUntilCompleted];

        id<MTLBuffer> b_result = rf.result;
        int *r = b_result.contents;

        u32 len;
        int bxy[2];
        float dst;
        u32 count = 0;
        int hw = dst_width / 2;
        int hh = dst_height / 2;
        for (int i = 0; i < gpu_max_result * 2; i += 2) {
            if (r[i] > 0 && r[i] < src_width && r[i + 1] > 0 && r[i + 1] < src_height) {
                
                u8 pass = 1;
                buffer_length(result, sizeof(int[2]), &len);
                for (int j = 0; j < len; ++j) {
                    buffer_get(result, sizeof(int[2]), j, bxy);
                    if ((abs(bxy[0] - r[i]) <= hw) && (abs(bxy[1] - r[i + 1]) <= hh)) {
                        pass = 0;
                    }
                }

                if (pass) {
                    buffer_append(result, r + i, sizeof(int));
                    buffer_append(result, r + i + 1, sizeof(int));
                    count++;
                    if (count == max_result) break;
                }
            }
        }
    }

finish:
    ;
}

void wiiauto_util_find_image_blackwhite(
    const u8 *src, const u32 src_channels, const u32 src_width, const u32 src_height, const u32 src_allocation_size,
    const u8 *dst, const u32 dst_channels, const u32 dst_width, const u32 dst_height, const u32 dst_allocation_size,
    const u32 grid, const float threshold, const u32 max_result, 
    const int from_x, const int from_y, const int to_x, const int to_y,
    const buffer result)
{
    buffer_erase(result);

    __setup();
    if (!__queue__) goto finish;

    @autoreleasepool {  

        int gpu_max_result = max_result * 10;

        id<MTLCommandBuffer> cmb = [__queue__ commandBuffer];
        id<MTLBuffer> b_approx_src;
        id<MTLBuffer> b_approx_dst;
        
        if (src_channels == 4) {
            b_approx_src = __approx_blackwhite(cmb, src, src_width, src_height, src_allocation_size);
        } else {
            b_approx_src = __approx_rgb_blackwhite(cmb, src, src_width, src_height, src_allocation_size);
        }
        
        if (dst_channels == 4) {
            b_approx_dst = __approx_blackwhite(cmb, dst, dst_width, dst_height, dst_allocation_size);
        } else {
            b_approx_dst = __approx_rgb_blackwhite(cmb, dst, dst_width, dst_height, dst_allocation_size);
        }
        result_find *rf = __find(cmb, b_approx_src, src_width, src_height, b_approx_dst, dst_width, dst_height, gpu_max_result, grid, threshold, from_x, from_y, to_x, to_y);
        [cmb commit];
        [cmb waitUntilCompleted];

        id<MTLBuffer> b_result = rf.result;
        int *r = b_result.contents;

        u32 len;
        int bxy[2];
        float dst;
        u32 count = 0;
        int hw = dst_width / 2;
        int hh = dst_height / 2;
        for (int i = 0; i < gpu_max_result * 2; i += 2) {
            if (r[i] > 0 && r[i] < src_width && r[i + 1] > 0 && r[i + 1] < src_height) {
                
                u8 pass = 1;
                buffer_length(result, sizeof(int[2]), &len);
                for (int j = 0; j < len; ++j) {
                    buffer_get(result, sizeof(int[2]), j, bxy);
                    if ((abs(bxy[0] - r[i]) <= hw) && (abs(bxy[1] - r[i + 1]) <= hh)) {
                        pass = 0;
                    }
                }

                if (pass) {
                    buffer_append(result, r + i, sizeof(int));
                    buffer_append(result, r + i + 1, sizeof(int));
                    count++;
                    if (count == max_result) break;
                }
            }
        }
    }

finish:
    ;
}

struct info_v2
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

void wiiauto_util_find_image_v2(
    const u8 *src, const u32 src_channels, const u32 src_width, const u32 src_height, const u32 src_allocation_size,
    const u8 *dst, const u32 dst_channels, const u32 dst_width, const u32 dst_height, const u32 dst_allocation_size,
    const u32 grid, const float threshold, const u32 max_result, 
    const int from_x, const int from_y, const int to_x, const int to_y,
    const buffer result)
{
    buffer_erase(result);

    int range_x = from_x;
    int range_y = from_y;
    int range_width = to_x - from_x;
    int range_height = to_y - from_y;

    __setup();
    if (!__queue__) goto finish;

    if (dst_width > 0) {

        if (range_x < 0) {
            range_x = 0;
        } else if (range_x >= src_width) {
            range_x = src_width - 1;
        }

        if (range_y < 0) {
            range_y = 0;
        } else if (range_y >= src_height) {
            range_y = src_height - 1;
        }

        if (range_width == 0 || range_height == 0) {
            range_width = src_width;
            range_height = src_height;
        }
        if (range_x + range_width > src_width) {
            range_width = src_width - range_x;
        }
        if (range_y + range_height > src_height) {
            range_height = src_height - range_y;
        }
        if (range_width == 0 || range_height == 0) {
            goto finish;
        }
    }

    if (dst_width > 0) {

        int cells = 10;

        @autoreleasepool {
            
            id<MTLBuffer> b_src = [__device__ newBufferWithBytesNoCopy:src  length:src_allocation_size
                options:MTLResourceStorageModeShared    deallocator:nil];

            id<MTLBuffer> b_dst = [__device__ newBufferWithBytesNoCopy:dst  length:dst_allocation_size
                options:MTLResourceStorageModeShared    deallocator:nil];

            struct info_v2 des;
            des.frame_width = src_width;
            des.frame_height = src_height;
            des.frame_start_x = 0;
            des.frame_start_y = 0;
            des.frame_work_width = src_width;
            des.frame_work_height = src_height;
            des.max_found = 100;
            des.image_width = dst_width;
            des.image_height = dst_height;
            for (int i = 0; i < 100; ++i) {
                des.found_x[i] = -1;
                des.found_y[i] = -1;
            }

            id<MTLBuffer> b_des = [__device__ 
                newBufferWithBytes:&des 
                length:sizeof(des) 
                options:MTLResourceStorageModeShared];

            atomic_int counter = 0;
            id<MTLBuffer> b_counter = [__device__ 
                newBufferWithBytes:&counter 
                length:sizeof(counter) 
                options:MTLResourceStorageModeShared];

            u32 len;
            int bxy[2];
            float dst;
            u32 count = 0;
            
            for (int n = 0; n < cells; n++) {
                for (int m = 0; m < cells; m++) {

                    struct info_v2 *des2 = (struct info_v2 *)b_des.contents;
                    des2->frame_start_x = range_x + (int)(m * 1.0f / cells * range_width);
                    des2->frame_start_y = range_y + (int)(n * 1.0f / cells * range_height);
                    des2->frame_work_width = (int)(range_width * 1.0f / cells);
                    des2->frame_work_height = (int)(range_height * 1.0f / cells);

                    id<MTLCommandBuffer> cmb = [__queue__ commandBuffer];

                    id<MTLComputeCommandEncoder> encoder = [cmb computeCommandEncoder];
                    [encoder setComputePipelineState:__pipeline_find_v2__];
                    [encoder setBuffer:b_src offset:0 atIndex:0];
                    [encoder setBuffer:b_dst offset:0 atIndex:1];
                    [encoder setBuffer:b_des offset:0 atIndex:2];
                    [encoder setBuffer:b_counter offset:0 atIndex:3];

                    int arrayLength = (int)(range_width * 1.0f / cells) * (int)(range_height * 1.0f / cells);
                    MTLSize gridSize = MTLSizeMake(arrayLength, 1, 1);
                    NSUInteger threadGroupSize = __pipeline_find_v2__.maxTotalThreadsPerThreadgroup;
                    if (threadGroupSize > arrayLength) {
                        threadGroupSize = arrayLength;
                    }
                    MTLSize threadgroupSize = MTLSizeMake(threadGroupSize, 1, 1);
                    [encoder dispatchThreadgroups:MTLSizeMake((arrayLength + threadGroupSize - 1) / threadGroupSize, 1, 1) threadsPerThreadgroup:threadgroupSize];
                    [encoder endEncoding];

                    [cmb commit];
                    [cmb waitUntilCompleted];

                    des2 = (struct info_v2 *)b_des.contents;
                    for (int i = 0; i < 100; ++i) {
                        if (des2->found_x[i] < 0) break;

                        u8 pass = 1;
                        buffer_length(result, sizeof(int[2]), &len);
                        for (int j = 0; j < len; ++j) {
                            buffer_get(result, sizeof(int[2]), j, bxy);

                            float d1 = bxy[0] - des2->found_x[i];
                            float d2 = bxy[1] - des2->found_y[i];
                            float dst = sqrt(d1 * d1 + d2 * d2);
                            if (dst <= 5) {
                                pass = 0;
                                break;
                            }
                        }

                        if (pass) {
                            buffer_append(result, &des2->found_x[i], sizeof(int));
                            buffer_append(result, &des2->found_y[i], sizeof(int));
                            count++;
                            if (count == max_result) break;
                        }
                    }
                    if (count == max_result) break;
                }
                if (count == max_result) break;
            }

        }
        
    }

finish:
    ;
}


struct find_points_description
{
    float src_width;
    float src_height;
    int points_length;
    int max_result;
};

void wiiauto_util_find_colors(
    const u8 *src, const u32 src_channels, const u32 src_width, const u32 src_height, const u32 src_allocation_size,
    const u8 *colors, const int *offsets, const u32 length, const u32 max_result, const buffer result)
{
    buffer_erase(result);

    __setup();
    if (!__queue__) goto finish;

    @autoreleasepool {

        id<MTLCommandBuffer> cmb = [__queue__ commandBuffer];

        id<MTLBuffer> b_src = [__device__ 
            newBufferWithBytesNoCopy:src
            length:src_allocation_size
            options:MTLResourceStorageModeShared
            deallocator:nil];

        id<MTLBuffer> b_colors = [__device__ 
            newBufferWithBytes:colors
            length:sizeof(u8) * 4 * length 
            options:MTLResourceStorageModePrivate];

        id<MTLBuffer> b_offsets = [__device__ 
            newBufferWithBytes:offsets
            length:sizeof(int) * 2 * length 
            options:MTLResourceStorageModePrivate];

        struct find_points_description des;
        des.src_width = src_width;
        des.src_height = src_height;
        des.points_length = length;
        des.max_result = max_result;
        id<MTLBuffer> b_des = [__device__ 
            newBufferWithBytes:&des
            length:sizeof(des)
            options:MTLResourceStorageModePrivate];
        
        volatile int *r = malloc(sizeof(int[2]) * max_result);
        for (int i = 0; i < max_result * 2; ++i) {
            r[i] = -1;
        }
        id<MTLBuffer> b_result = [__device__ 
            newBufferWithBytes:r
            length:(sizeof(int[2]) * max_result)
            options:MTLResourceStorageModeShared];
        free(r);

        atomic_int counter = 0;
        id<MTLBuffer> b_counter = [__device__ 
            newBufferWithBytes:&counter 
            length:sizeof(counter) 
            options:MTLResourceStorageModePrivate];

        id<MTLComputeCommandEncoder> encoder = [cmb computeCommandEncoder];
        [encoder setComputePipelineState:__pipeline_find_points__];
        [encoder setBuffer:b_src offset:0 atIndex:0];
        [encoder setBuffer:b_colors offset:0 atIndex:1];
        [encoder setBuffer:b_offsets offset:0 atIndex:2];
        [encoder setBuffer:b_des offset:0 atIndex:3];
        [encoder setBuffer:b_result offset:0 atIndex:4];
        [encoder setBuffer:b_counter offset:0 atIndex:5];

        int arrayLength = src_width * src_height;
        MTLSize gridSize = MTLSizeMake(arrayLength, 1, 1);
        NSUInteger threadGroupSize = __pipeline_find_points__.maxTotalThreadsPerThreadgroup;
        if (threadGroupSize > arrayLength) {
            threadGroupSize = arrayLength;
        }
        MTLSize threadgroupSize = MTLSizeMake(threadGroupSize, 1, 1);
        [encoder dispatchThreadgroups:MTLSizeMake((arrayLength + threadGroupSize - 1) / threadGroupSize, 1, 1) threadsPerThreadgroup:threadgroupSize];
        [encoder endEncoding];

        [cmb commit];
        [cmb waitUntilCompleted];

        r = b_result.contents;
        for (int i = 0; i < max_result * 2; i += 2) {
            if (r[i] >= 0 && r[i] < src_width && r[i + 1] >= 0 && r[i + 1] < src_height) {
                buffer_append(result, r + i, sizeof(int));
                buffer_append(result, r + i + 1, sizeof(int));
            }
        }
    }

finish:
    ;
}
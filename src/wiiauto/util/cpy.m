#include "util.h"
#include "cherry/core/buffer.h"
#include "wiiauto/file/file.h"
#include "wiiauto/common/common.h"

#import <Metal/Metal.h>
#import <MetalKit/MetalKit.h>
#import <stdatomic.h>

static id<MTLDevice> __device__ = nil;
static id<MTLComputePipelineState> __pipeline_cpy_raw4__ = nil;
static id<MTLComputePipelineState> __pipeline_cpy_bgra_to_rgba__ = nil;
static id<MTLCommandQueue> __queue__ = nil;
static id<MTLLibrary> __lib__ = nil;
static id<MTLFunction> __method_cpy_raw4__ = nil;
static id<MTLFunction> __method_cpy_bgra_to_rgba__ = nil;

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
        wiiauto_convert_url("wiiauto_internal://Metals/cpy/main.metallib", b);
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
         * cpy_raw4
         */
        __method_cpy_raw4__ = [__lib__ newFunctionWithName:@"cpy_raw4"];
        if (__method_cpy_raw4__ == nil)
        {
            goto finish;
        }

        __pipeline_cpy_raw4__ = [__device__ newComputePipelineStateWithFunction:__method_cpy_raw4__ error:&error];
        if (__pipeline_cpy_raw4__ == nil)
        {
            goto finish;
        }

        /*
         * cpy_bgra_to_rgba
         */
        __method_cpy_bgra_to_rgba__ = [__lib__ newFunctionWithName:@"cpy_bgra_to_rgba"];
        if (__method_cpy_bgra_to_rgba__ == nil)
        {
            goto finish;
        }

        __pipeline_cpy_bgra_to_rgba__ = [__device__ newComputePipelineStateWithFunction:__method_cpy_bgra_to_rgba__ error:&error];
        if (__pipeline_cpy_bgra_to_rgba__ == nil)
        {
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

void wiiauto_util_cpy_raw4(const u8 *src, u8 *dst, const u32 width, const u32 height, const u32 allocation_size)
{
    __setup();
    if (!__queue__) return;

    @autoreleasepool {
        id<MTLCommandBuffer> cmb = [__queue__ commandBuffer];

        id<MTLBuffer> b_src = [__device__ 
            newBufferWithBytesNoCopy:src
            length:allocation_size
            options:MTLResourceStorageModeShared
            deallocator:nil];

        id<MTLBuffer> b_dst = [__device__ 
            newBufferWithBytesNoCopy:dst
            length:allocation_size
            options:MTLResourceStorageModeShared
            deallocator:nil];

        id<MTLComputeCommandEncoder> encoder = [cmb computeCommandEncoder];
        [encoder setComputePipelineState:__pipeline_cpy_raw4__];
        [encoder setBuffer:b_src offset:0 atIndex:0];
        [encoder setBuffer:b_dst offset:0 atIndex:1];

        int arrayLength = width * height;
        MTLSize gridSize = MTLSizeMake(arrayLength, 1, 1);
        NSUInteger threadGroupSize = __pipeline_cpy_raw4__.maxTotalThreadsPerThreadgroup;
        if (threadGroupSize > arrayLength) {
            threadGroupSize = arrayLength;
        }
        MTLSize threadgroupSize = MTLSizeMake(threadGroupSize, 1, 1);
        [encoder dispatchThreadgroups:MTLSizeMake((arrayLength + threadGroupSize - 1) / threadGroupSize, 1, 1) threadsPerThreadgroup:threadgroupSize];
        [encoder endEncoding];
        
        [cmb commit];
        [cmb waitUntilCompleted];
    }
}
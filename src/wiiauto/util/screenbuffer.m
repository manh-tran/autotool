#include "util.h"
#include "wiiauto/device/device.h"

#include "log/remote_log.h"

OBJC_EXTERN UIImage *_UICreateScreenUIImage(void) NS_RETURNS_RETAINED;
UIKIT_EXTERN CGImageRef UICreateCGImageFromIOSurface(IOSurfaceRef);

void wiiauto_util_fill_screenbuffer(u8 *ptr)
{
    @autoreleasepool {

        IOSurfaceRef ioSurfaceRef = NULL;
        CGImageRef image = NULL;
        CGDataProviderRef dataProvider;
        CFDataRef data = NULL;
        const UInt8 *bytePtr;
        size_t bytesPerRow;
        u32 width, height;
        const UInt8 *b ;
        int i, j, idx, i4, j4;

        

         @try {
            ioSurfaceRef = (__bridge IOSurfaceRef)([UIWindow performSelector:@selector(createScreenIOSurface)]);
        } @catch (NSException *e) {
            ioSurfaceRef = NULL;
        }
        
        // remote_log("get_image 1\n");

        if (!ioSurfaceRef) goto finish;

        // remote_log("get_image 2\n");

        image = UICreateCGImageFromIOSurface(ioSurfaceRef);
        if (!image) goto finish;

        // remote_log("get_image 3\n");

        dataProvider = CGImageGetDataProvider(image);
        if (!dataProvider) goto finish;

        // remote_log("get_image 4\n");

        data = CGDataProviderCopyData(dataProvider);
        if (!data) goto finish;

        // remote_log("get_image 5\n");

        bytePtr = CFDataGetBytePtr(data);
        width = CGImageGetWidth(image);
        height = CGImageGetHeight(image);
        bytesPerRow = CGImageGetBytesPerRow(image);

        for (i = 0; i < height; ++i) {
            for (j = 0; j < width; ++j) {
                b = bytePtr + bytesPerRow * i;
                idx = i * width + j;
                i4 = idx * 4;
                j4 = j * 4;

                ptr[i4] = b[j4 + 2];
                ptr[i4 + 1] = b[j4 + 1];
                ptr[i4 + 2] = b[j4];
                ptr[i4 + 3] = b[j4 + 3];

                // __device_screen_buffer__[idx].r = b[j * 4 + 2];
                // __device_screen_buffer__[idx].g = b[j * 4 + 1];
                // __device_screen_buffer__[idx].b = b[j * 4 + 0];
                // __device_screen_buffer__[idx].a = b[j * 4 + 3];
            }
        }

    finish:
        if (data) CFRelease(data);
        if (ioSurfaceRef) CFRelease(ioSurfaceRef);
        if (image) CGImageRelease(image);
    }
}
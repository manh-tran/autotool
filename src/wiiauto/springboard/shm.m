// #include "springboard.h"
// // #include "rocketbootstrap/rocketbootstrap.h"
// #include "wiiauto/event/event.h"
// #include "log/remote_log.h"
// #include "wiiauto/device/device.h"
// #include <sys/mman.h>
// #include <sys/time.h>
// #include <pthread.h>

// const char *springboard_get_screen_buffer_path();

// static dispatch_queue_t screen_queue;

// OBJC_EXTERN UIImage *_UICreateScreenUIImage(void) NS_RETURNS_RETAINED;
// UIKIT_EXTERN CGImageRef UICreateCGImageFromIOSurface(IOSurfaceRef);
// static u8 __set__ = 0;
// static int __fd__ = -1;
// static size_t __mem_size__ = 0;
// static u64 __last_time__ = 0;

// static u64 current_timestamp() 
// {
//     struct timeval te; 
//     gettimeofday(&te, NULL);
//     u64 milliseconds = te.tv_sec*1000LL + te.tv_usec/1000;
//     return milliseconds;
// }

// static void __do_refresh()
// {
//     if (__set__ >= 1) {
//         u64 cm = current_timestamp();
//         if (cm - __last_time__ >= 10000) {
//             __last_time__ = cm;
//             __set__ = 0;
//         }
//         return;
//     }

//     __set__ = 1;

//     dispatch_async(screen_queue, ^{

//         u32 width, height;
//         int i, j, idx;

//         IOSurfaceRef ioSurfaceRef = (__bridge IOSurfaceRef)([UIWindow performSelector:@selector(createScreenIOSurface)]);
//         CGImageRef image = UICreateCGImageFromIOSurface(ioSurfaceRef);
        
//         CGDataProviderRef dataProvider = CGImageGetDataProvider(image);
//         CFDataRef data = CGDataProviderCopyData(dataProvider);

//         const UInt8 *bytePtr = CFDataGetBytePtr(data);
//         width = CGImageGetWidth(image);
//         height = CGImageGetHeight(image);
//         size_t bytesPerRow = CGImageGetBytesPerRow(image);

//         for (i = 0; i < height; ++i) {
//             for (j = 0; j < width; ++j) {
//                 const UInt8 *b = bytePtr + bytesPerRow * i;
//                 idx = i * width + j;
//                 __device_screen_buffer__[idx].r = b[j * 4 + 2];
//                 __device_screen_buffer__[idx].g = b[j * 4 + 1];
//                 __device_screen_buffer__[idx].b = b[j * 4 + 0];
//                 __device_screen_buffer__[idx].a = b[j * 4 + 3];
//             }
//         }

//         msync(__device_screen_buffer__, __mem_size__, MS_SYNC);

//         CFRelease(data);

//         CFRelease(ioSurfaceRef);
//         CGImageRelease(image);

//         // UIImage *screenshot = _UICreateScreenUIImage();

//         // CGImageRef image = screenshot.CGImage;

//         // CGDataProviderRef dataProvider = CGImageGetDataProvider(image);
//         // CFDataRef data = CGDataProviderCopyData(dataProvider);

//         // const UInt8 *bytePtr = CFDataGetBytePtr(data);
//         // width = CGImageGetWidth(image);
//         // height = CGImageGetHeight(image);
//         // size_t bytesPerRow = CGImageGetBytesPerRow(image);

//         // for (i = 0; i < height; ++i) {
//         //     for (j = 0; j < width; ++j) {
//         //         const UInt8 *b = bytePtr + bytesPerRow * i;
//         //         idx = i * width + j;
//         //         __device_screen_buffer__[idx].r = b[j * 4 + 2];
//         //         __device_screen_buffer__[idx].g = b[j * 4 + 1];
//         //         __device_screen_buffer__[idx].b = b[j * 4 + 0];
//         //         __device_screen_buffer__[idx].a = b[j * 4 + 3];
//         //     }
//         // }

//         // msync(__device_screen_buffer__, __mem_size__, MS_SYNC);

//         // CFRelease(data);
//         // CGImageRelease(image);
//         // screenshot = nil;

//         __set__ = 2;

//         CFNotificationCenterPostNotification(
//             CFNotificationCenterGetDarwinNotifyCenter(), 
//             CFSTR("WIIAUTO_DAEMON_REFRESH_SCREEN_BUFFER"), 
//             NULL, 
//             NULL, 
//             TRUE);

//         sched_yield();
//     });
// }

// static void refresh_callback(CFRunLoopTimerRef tm, void *t)
// {
//     __do_refresh();

//     CFRunLoopTimerSetNextFireDate(tm, CFAbsoluteTimeGetCurrent() + 1.0f / 2);
// }

// static void __attribute__((destructor)) __fd_out()
// {
//     if (__fd__ >= 0) {
//         const char *spath = springboard_get_screen_buffer_path();

//         munmap(__device_screen_buffer__, __mem_size__);
//         close(__fd__);
//         shm_unlink(spath);
//     }
// }

// static void notify_refresh_screen_buffer(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) 
// {
//     if (__set__ == 2) {
//         __set__ = 0;
//     }    
// }

// void springboard_shm_init()
// {    
//     screen_queue = dispatch_queue_create("com.wiimob.wiiauto.springboard_refreshscreen", NULL);
//     float width, height , factor;

//     wiiauto_device_get_screen_size(&width, &height);
//     wiiauto_device_get_retina_factor(&factor);

//     width *= factor;
//     height *= factor;    

//     __mem_size__ = width * height * 4;

//     const char *spath = springboard_get_screen_buffer_path();
//     shm_unlink(spath);
    
//     int shFD = shm_open(spath, (O_CREAT | O_EXCL | O_RDWR), S_IRWXO|S_IRWXG|S_IRWXU);
//     int error = 0;
//     if (shFD >= 0) {
//         if (ftruncate(shFD, __mem_size__) == 0) {
//             __device_screen_buffer__ = mmap(NULL, __mem_size__, (PROT_READ | PROT_WRITE), MAP_SHARED, shFD, 0);
//             if (__device_screen_buffer__ != MAP_FAILED) {
//                 error = 0;
//             } else {
//                 error = 1;
//             }
//         } else {
//             error = 1;
//         }
//     } else {
//         error = 1;
//     }

//     __fd__ = shFD;

//     {
//         CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), 
//             NULL, 
//             notify_refresh_screen_buffer,
//             CFSTR("WIIAUTO_SPRINGBOARD_REFRESH_SCREEN_BUFFER"), 
//             NULL, 
//             CFNotificationSuspensionBehaviorCoalesce);
//     }
// }

// void springboard_init_refresh()
// {
//     static u8 __inited__ = 0;

//     if (!__inited__) {
//         __inited__ = 1;

//         CFRunLoopRef rl = CFRunLoopGetCurrent();
//         CFRunLoopTimerContext ctx;
//         ctx.retain = NULL;
//         ctx.release = NULL;
//         ctx.copyDescription = NULL;
//         ctx.version = 0;
//         ctx.info = NULL;
//         CFRunLoopTimerRef timer = CFRunLoopTimerCreate(kCFAllocatorDefault, 0, 9999999, 0, 0, (void(*)(CFRunLoopTimerRef, void *))refresh_callback, &ctx);

//         CFRunLoopAddTimer(rl, timer, kCFRunLoopCommonModes);  
//     }
// }
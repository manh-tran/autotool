// #include "springboard.h"
// #include "wiiauto/event/event.h"
// #include "log/remote_log.h"
// #include "wiiauto/device/device.h"
// #include <sys/mman.h>
// #include <sys/time.h>
// #include <pthread.h>
// #include "cherry/net/socket.h"

// static dispatch_queue_t screen_queue;

// UIKIT_EXTERN CGImageRef UICreateCGImageFromIOSurface(IOSurfaceRef);
// static u8 __set__ = 0;
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
//     if (__last_time__ == 0) {
//         __last_time__ = current_timestamp();
//     }
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
//         int i, j, idx, ret;
//         net_socket sock;

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

//         net_socket_new(&sock);
//         // net_socket_connect_unix(sock, "/wiiauto_daemon_screenbuffer");
//         net_socket_connect(sock, "localhost", 9999);
//         net_socket_send(sock, sock, __device_screen_buffer__, __mem_size__, &ret);
//         release(sock.iobj);

//         CFRelease(data);

//         CFRelease(ioSurfaceRef);
//         CGImageRelease(image);

//         __set__ = 2;

//         // CFNotificationCenterPostNotification(
//         //     CFNotificationCenterGetDarwinNotifyCenter(), 
//         //     CFSTR("WIIAUTO_DAEMON_REFRESH_SCREEN_BUFFER"), 
//         //     NULL, 
//         //     NULL, 
//         //     TRUE);

//         sched_yield();
//     });
// }

// static void refresh_callback(CFRunLoopTimerRef tm, void *t)
// {
//     __do_refresh();

//     CFRunLoopTimerSetNextFireDate(tm, CFAbsoluteTimeGetCurrent() + 1.0f / 2);
// }

// static void notify_refresh_screen_buffer(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) 
// {
//     if (__set__ == 2) {
//         __set__ = 0;
//     }    
// }

// void springboard_screenbuffer_unix_init()
// {
//     screen_queue = dispatch_queue_create("com.wiimob.wiiauto.springboard_refreshscreen", NULL);
//     float width, height , factor;

//     wiiauto_device_get_screen_size(&width, &height);
//     wiiauto_device_get_retina_factor(&factor);

//     width *= factor;
//     height *= factor;    

//     __mem_size__ = width * height * 4;

//     __device_screen_buffer__ = malloc(__mem_size__);

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
//     CFRunLoopRef rl = CFRunLoopGetCurrent();
//     CFRunLoopTimerContext ctx;
//     ctx.retain = NULL;
//     ctx.release = NULL;
//     ctx.copyDescription = NULL;
//     ctx.version = 0;
//     ctx.info = NULL;
//     CFRunLoopTimerRef timer = CFRunLoopTimerCreate(kCFAllocatorDefault, 0, 9999999, 0, 0, (void(*)(CFRunLoopTimerRef, void *))refresh_callback, &ctx);

//     CFRunLoopAddTimer(rl, timer, kCFRunLoopCommonModes);  
// }
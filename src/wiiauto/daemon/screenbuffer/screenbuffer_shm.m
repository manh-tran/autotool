// #include "screenbuffer.h"
// #include "wiiauto/device/device.h"
// #include "log/remote_log.h"
// #include <sys/mman.h>
// #include "wiiauto/event/event_screen_buffer_path.h"
// #include "wiiauto/springboard/springboard.h"
// #include <sys/time.h>

// static u64 current_timestamp() 
// {
//     struct timeval te; 
//     gettimeofday(&te, NULL);
//     u64 milliseconds = te.tv_sec*1000LL + te.tv_usec/1000;
//     return milliseconds;
// }

// static int __fd__ = -1;
// static size_t __mem_size__ = 0;
// static char __current_screen_path__[1024] = {'\0'};
// static __wiiauto_pixel *__shared_mem__ = NULL;
// static dispatch_queue_t screen_queue;
// static u64 __screen_timestamp__ = 0;

// static void map_screen_buffer_callback(CFRunLoopTimerRef tm, void *t)
// {
//     __wiiauto_event_request_screen_buffer_path rq;
//     const __wiiauto_event_result_screen_buffer_path *rt;
//     CFDataRef ref;

//     __wiiauto_event_request_screen_buffer_path_init(&rq);   
//     wiiauto_send_event(1, &rq, sizeof(rq), SPRINGBOARD_MACH_PORT_NAME, &ref);

//     __wiiauto_event_result_screen_buffer_path_fetch(ref, &rt);
//     if (rt && strlen(rt->path) > 0 
//         && ((strcmp(rt->path, __current_screen_path__) != 0) || rt->timestamp != __screen_timestamp__)) {
        
//         if (__fd__ >= 0) {
//             close(__fd__);
//         }
//         if (__shared_mem__) {
//             munmap(__shared_mem__, __mem_size__);
//             __shared_mem__ = NULL;
//         }
//         int fd = -1;

//         fd = shm_open(rt->path, O_RDONLY, S_IRUSR | S_IWUSR);
//         if (fd != -1) {
//             __shared_mem__ = mmap(NULL, __mem_size__, PROT_READ, MAP_SHARED, fd, 0);
//             __fd__ = fd;
//             strcpy(__current_screen_path__, rt->path);
//             __screen_timestamp__ = rt->timestamp;
//         }        
//     }

//     if (ref) {
//         CFRelease(ref);
//     }

//     CFRunLoopTimerSetNextFireDate(tm, CFAbsoluteTimeGetCurrent() + 3);
//     return;
// }

// static void notify_refresh_screen_buffer(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) 
// {
//     dispatch_async(screen_queue, ^{

//         if (__shared_mem__) {
//             memcpy(__device_screen_buffer__, __shared_mem__, __mem_size__);
//         }

//         CFNotificationCenterPostNotification(
//             CFNotificationCenterGetDarwinNotifyCenter(), 
//             CFSTR("WIIAUTO_SPRINGBOARD_REFRESH_SCREEN_BUFFER"), 
//             NULL, 
//             NULL, 
//             TRUE);

//     });
// }


// void wiiauto_daemon_screenbuffer_init_shm()
// {
//     {
//         float width, height , factor;

//         wiiauto_device_get_screen_size(&width, &height);
//         wiiauto_device_get_retina_factor(&factor);

//         width *= factor;
//         height *= factor;    

//         size_t shmemSize = width * height * 4;
//         __mem_size__ = shmemSize;

//         __device_screen_buffer__ = malloc(__mem_size__);
//     }
//     screen_queue = dispatch_queue_create("com.wiimob.wiiauto.daemon_refreshscreen", NULL);
//     {
//         CFRunLoopRef rl = CFRunLoopGetCurrent();
//         CFRunLoopTimerContext ctx;
//         ctx.retain = NULL;
//         ctx.release = NULL;
//         ctx.copyDescription = NULL;
//         ctx.version = 0;
//         ctx.info = NULL;
//         CFRunLoopTimerRef timer = CFRunLoopTimerCreate(kCFAllocatorDefault, 0, 9999999, 0, 0, (void(*)(CFRunLoopTimerRef, void *))map_screen_buffer_callback, &ctx);

//         CFRunLoopAddTimer(rl, timer, kCFRunLoopCommonModes);   
//     }    
//     {
//         CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), 
//             NULL, 
//             notify_refresh_screen_buffer,
//             CFSTR("WIIAUTO_DAEMON_REFRESH_SCREEN_BUFFER"), 
//             NULL, 
//             CFNotificationSuspensionBehaviorCoalesce);
//     }
// }
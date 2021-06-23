#include "screenbuffer.h"
#include "cherry/net/socket.h"
#include "cherry/core/buffer.h"
#include "wiiauto/thread/thread.h"
#include "wiiauto/device/device.h"
#include "cherry/core/map.h"
#include "wiiauto/springboard/springboard.h"
#include "wiiauto/daemon/daemon.h"
#include "wiiauto/util/util.h"

spin_lock __screenbuffer_lock__ = SPIN_LOCK_INIT;

// void net_socket_get_descriptor(const net_socket p, int *d);

static size_t __mem_size__ = 0;
// static dispatch_queue_t __queue;
// static buffer buf, content;
// static net_socket client = {id_null};

// static void __refresh_image()
// {
//     dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), __queue , ^{

//         int fd;
//         i32 r;
//         u32 blen;

//         size_t total;
//         const char *ptr;
        
//         if (!__daemon_avaliable__) goto next_step;

//         if (!id_validate(client.iobj)) {
//             net_socket_new(&client);
//             net_socket_connect_unix(client, SPRINGBOARD_SCREENBUFFER_DOMAIN);
//             net_socket_set_read_timeout(client, 2000);
//         }

//         net_socket_get_descriptor(client, &fd);
//         if (fd >= 0) {
//             total = 0;
//             buffer_erase(content);
//             net_socket_send(client, client, "request_buffer", strlen("request_buffer"), &r);

//         try_read:
//             net_socket_read(client, buf);
//             buffer_length(buf, 1 , &blen);

//             if (blen > 0) {
//                 buffer_append_buffer(content, buf);

//                 total += blen;
//                 if (total < __mem_size__) {
//                     buffer_erase(buf);
//                     goto try_read;
//                 }
//             }

//             if (total < __mem_size__) {
//                 release(client.iobj);
//             } else {
//                 buffer_get_ptr(content, &ptr);
                
//                 lock(&__screenbuffer_lock__);
//                 memcpy(__device_screen_buffer__, ptr, __mem_size__);
//                 unlock(&__screenbuffer_lock__);
//             }

//         } else {
//             release(client.iobj);
//         }
//     next_step:
//         __yield();
//         __refresh_image();
//     });
// }

void wiiauto_daemon_screenbuffer_init_unix()
{
    thread_job job;
    thread_pool pool;

    float width, height , factor;

    wiiauto_device_get_screen_size(&width, &height);
    wiiauto_device_get_retina_factor(&factor);

    width *= factor;
    height *= factor;    

    __mem_size__ = width * height * 4;

    int pageSize = getpagesize();
    u32 bytes = __mem_size__;
    u32 mod = bytes % pageSize;
    if (mod != 0) {
        bytes = (bytes / pageSize + 1) * pageSize;
    }
    posix_memalign(&__device_screen_buffer__, pageSize, bytes);

    // buffer_new(&buf);
    // buffer_new(&content);
    // buffer_reserve(content, __mem_size__);

    // __queue = dispatch_queue_create("com.wiimob.wiiauto.daemon_screen_queue", NULL);

    // __refresh_image();
}
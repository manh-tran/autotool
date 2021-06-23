#include "springboard.h"
#include "wiiauto/device/device.h"
#include "cherry/net/socket.h"
#include "wiiauto/thread/thread.h"
#include "log/remote_log.h"

UIKIT_EXTERN CGImageRef UICreateCGImageFromIOSurface(IOSurfaceRef);
OBJC_EXTERN UIImage *_UICreateScreenUIImage(void) NS_RETURNS_RETAINED;

static size_t __mem_size__ = 0;
static dispatch_queue_t screen_queue;

static void add_connection(const net_socket server,  const iobj user, const net_socket sock)
{
}

static void read_data(const net_socket server, const iobj user, const net_socket sock)
{
    buffer bf;

    buffer_new(&bf);
    net_socket_read(sock, bf);
    release(bf.iobj);

    u32 width, height;
    int i, j, idx;
    i32 ret;
    IOSurfaceRef ioSurfaceRef = NULL;
    CGImageRef image = NULL;
    CGDataProviderRef dataProvider;
    CFDataRef data = NULL;
    const UInt8 *bytePtr;
    size_t bytesPerRow;
    const UInt8 *b ;

    @try {
        ioSurfaceRef = (__bridge IOSurfaceRef)([UIWindow performSelector:@selector(createScreenIOSurface)]);
    } @catch (NSException *e) {
        ioSurfaceRef = NULL;
    }
    
    if (!ioSurfaceRef) goto finish;

    image = UICreateCGImageFromIOSurface(ioSurfaceRef);
    if (!image) goto finish;

    dataProvider = CGImageGetDataProvider(image);
    if (!dataProvider) goto finish;

    data = CGDataProviderCopyData(dataProvider);
    if (!data) goto finish;

    bytePtr = CFDataGetBytePtr(data);
    width = CGImageGetWidth(image);
    height = CGImageGetHeight(image);
    bytesPerRow = CGImageGetBytesPerRow(image);

    for (i = 0; i < height; ++i) {
        for (j = 0; j < width; ++j) {
            b = bytePtr + bytesPerRow * i;
            idx = i * width + j;
            __device_screen_buffer__[idx].r = b[j * 4 + 2];
            __device_screen_buffer__[idx].g = b[j * 4 + 1];
            __device_screen_buffer__[idx].b = b[j * 4 + 0];
            __device_screen_buffer__[idx].a = b[j * 4 + 3];
        }
    }

finish: 
    if (data) CFRelease(data);

    if (ioSurfaceRef) CFRelease(ioSurfaceRef);
    if (image) CGImageRelease(image);

    net_socket_send(server, sock, (const unsigned char *)__device_screen_buffer__, __mem_size__, &ret);
}

static void remove_connection(const net_socket server,  const iobj user, const net_socket sock)
{

}

static void __callback(const thread_pool pool)
{
    net_socket server;

roll_back:
    net_socket_new(&server);
    net_socket_bind_unix(server, SPRINGBOARD_SCREENBUFFER_DOMAIN);
    net_socket_run(server, server.iobj, (__net_socket_callback){
        .add_connection = add_connection,
        .read_data = (void(*)(const net_socket, const iobj, const net_socket))read_data,
        .remove_connection = remove_connection
    });
    release(server.iobj);

    usleep(1000000);
    goto roll_back;

    wiiauto_recycle_thread_pool(pool);
}

void springboard_screenbuffer_unix_init()
{

}

#include <mach/mach_time.h>
#include "wiiauto/device/device.h"
#include "wiiauto/device/device_iohid.h"

void springboard_init_refresh()
{
    screen_queue = dispatch_queue_create("com.wiimob.wiiauto.springboard_refreshscreen", NULL);

    thread_job job;
    thread_pool pool;

    float width, height , factor;

    wiiauto_device_init();
    wiiauto_device_get_screen_size(&width, &height);
    wiiauto_device_get_retina_factor(&factor);

    width *= factor;
    height *= factor;    
    
    __mem_size__ = width * height * 4;
    __device_screen_buffer__ = malloc(__mem_size__);

    wiiauto_get_thread_pool(&pool);
    thread_job_new(&job);
    thread_job_set_callback(job, (thread_job_callback)__callback);
    thread_job_add_arguments(job, pool.iobj);
    thread_pool_add_job(pool, job);
    release(job.iobj);

    // dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue() , ^{
        
    //     int usage_page, usage;
    //     usage_page = 12;
    //     usage = 0x40;
    //     wiiauto_device_iohid_send(IOHIDEventCreateKeyboardEvent(kCFAllocatorDefault, mach_absolute_time(), usage_page, usage, 1, 0));
    //     wiiauto_device_iohid_send(IOHIDEventCreateKeyboardEvent(kCFAllocatorDefault, mach_absolute_time(), usage_page, usage, 0, 0));
        
    // });
}
#include "springboard.h"
#include "wiiauto/event/event.h"
#include "wiiauto/device/device.h"
#include "wiiauto/intercom/intercom.h"
#include "cherry/net/socket.h"
#include "cherry/thread/thread.h"
#include "log/remote_log.h"

static spin_lock __barrier__ = SPIN_LOCK_INIT;
static dispatch_queue_t check_queue;

void springboard_get_handler(const __wiiauto_event *data, const u32 in_size, wiiauto_event_delegate *del);

static CFDataRef callback(CFMessagePortRef local, SInt32 msgid, CFDataRef cfData, void *info) 
{
    lock(&__barrier__);
    u32 len;
    CFDataRef ref = NULL;

    wiiauto_event_delegate del = NULL;

    len = CFDataGetLength(cfData);

    const __wiiauto_event *data = (const __wiiauto_event *) CFDataGetBytePtr(cfData);
    springboard_get_handler(data, len, &del);

    if (del) {
        ref = del(data);
    }

    if (!ref) {
        __wiiauto_event_null evt;
        __wiiauto_event_null_init(&evt);
        ref = CFDataCreate(NULL, (const UInt8 *)&evt, sizeof(evt));
    }

    unlock(&__barrier__);
    return ref;
}

CFDataRef springboard_callback(CFMessagePortRef local, SInt32 msgid, CFDataRef cfData, void *info)
{
    return callback(local, msgid, cfData, info);
}

static u16 __sport[9] = {
	SPRINGBOARD_LOCAL_PORT_1,
	SPRINGBOARD_LOCAL_PORT_2,
	SPRINGBOARD_LOCAL_PORT_3,
	SPRINGBOARD_LOCAL_PORT_4,
	SPRINGBOARD_LOCAL_PORT_5,
	SPRINGBOARD_LOCAL_PORT_6,
	SPRINGBOARD_LOCAL_PORT_7,
	SPRINGBOARD_LOCAL_PORT_8,
	SPRINGBOARD_LOCAL_PORT_9
};

// #import <mach/mach.h>

// static unsigned long __report_memory() 
// {
//     struct task_basic_info info;
//     mach_msg_type_number_t size = TASK_BASIC_INFO_COUNT;
//     kern_return_t kerr = task_info(mach_task_self(),
//                                     TASK_BASIC_INFO,
//                                     (task_info_t)&info,
//                                     &size);
//     if( kerr == KERN_SUCCESS ) {
//         return info.resident_size;
//         // NSLog(@"Memory in use (in bytes): %lu", info.resident_size);
//         // NSLog(@"Memory in use (in MiB): %f", ((CGFloat)info.resident_size / 1048576));
//     } else {
//         // NSLog(@"Error with task_info(): %s", mach_error_string(kerr));
//         return 0;
//     }
// }

// static void __check_mem()
// {
//     dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), check_queue, ^{
        
//         unsigned long mem = __report_memory();

//         remote_log("mem: %lu | %f\n", mem, mem / 1048576.0f);

//         __check_mem();
//     });
// }

void springboard_init()
{    
    int memorystatus_control(uint32_t command, int32_t pid, uint32_t flags, void *buffer, size_t buffersize);
    memorystatus_control(5, getpid(), 1024, 0, 0);

    check_queue = dispatch_queue_create("com.wiimob.wiiauto.springboard_mem_check", NULL);
    wiiauto_device_init();
    springboard_screenbuffer_unix_init();

    wiiauto_intercom_register_unix(SPRINGBOARD_MACH_PORT_NAME, callback);
    wiiauto_intercom_register_local_port(9, __sport, callback);  

    remote_log_set_process("springboard");
}
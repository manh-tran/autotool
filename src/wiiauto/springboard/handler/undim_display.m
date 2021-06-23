#include "undim_display.h"
#include "wiiauto/device/device.h"
#include "wiiauto/device/device_iohid.h"
#include <mach/mach_time.h>

CFDataRef springboard_handle_undim_display(const __wiiauto_event_undim_display *input)
{
    u8 on;
    int usage_page, usage;
    u8 locked;
    usage_page = 12;
    usage = 0x40;

    wiiauto_device_is_screen_on(&on);
    if (on) {
        wiiauto_device_is_locked(&locked);
        if (locked) {
            wiiauto_device_iohid_send(IOHIDEventCreateKeyboardEvent(kCFAllocatorDefault, mach_absolute_time(), usage_page, usage, 1, 0));
            wiiauto_device_iohid_send(IOHIDEventCreateKeyboardEvent(kCFAllocatorDefault, mach_absolute_time(), usage_page, usage, 0, 0));
        }
        goto finish;
    }   

    /* press homebutton to turnon screen */
    wiiauto_device_iohid_send(IOHIDEventCreateKeyboardEvent(kCFAllocatorDefault, mach_absolute_time(), usage_page, usage, 1, 0));
    wiiauto_device_iohid_send(IOHIDEventCreateKeyboardEvent(kCFAllocatorDefault, mach_absolute_time(), usage_page, usage, 0, 0));

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue() , ^{
        wiiauto_device_iohid_send(IOHIDEventCreateKeyboardEvent(kCFAllocatorDefault, mach_absolute_time(), usage_page, usage, 1, 0));
        wiiauto_device_iohid_send(IOHIDEventCreateKeyboardEvent(kCFAllocatorDefault, mach_absolute_time(), usage_page, usage, 0, 0));
    });

    @try {
        wiiauto_device_undim_display();
    } @catch (NSException *e) {
        
    }

finish:
    return NULL;
}
#include "turn_on_screen.h"
#include "wiiauto/device/device.h"
#include "wiiauto/device/device_iohid.h"
#include <mach/mach_time.h>

CFDataRef springboard_handle_turn_on_screen(const __wiiauto_event_turn_on_screen *input)
{
    u8 on;
    int usage_page, usage;

    wiiauto_device_is_screen_on(&on);
    if (on) goto finish;

    usage_page = 12;
    usage = 0x40;

    /* press homebutton to turnon screen */
    wiiauto_device_iohid_send(IOHIDEventCreateKeyboardEvent(kCFAllocatorDefault, mach_absolute_time(), usage_page, usage, 1, 0));
    wiiauto_device_iohid_send(IOHIDEventCreateKeyboardEvent(kCFAllocatorDefault, mach_absolute_time(), usage_page, usage, 0, 0));

finish:    
    return NULL;
}
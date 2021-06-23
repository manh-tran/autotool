#include "press_button.h"
#include "wiiauto/device/device_iohid.h"
#include <mach/mach_time.h>
#include "log/remote_log.h"

CFDataRef springboard_handle_press_button(const __wiiauto_event_press_button *input)
{
    int usage_page = 0;
    int usage = 0;

    switch (input->type) {
        case WIIAUTO_BUTTON_HOME:
            usage_page = 12;
            usage = 0x40;
            break;
        case WIIAUTO_BUTTON_LOCK:
            usage_page = 12;
            usage = 0x30;
            break;
        case WIIAUTO_BUTTON_VOLUME_UP:
            usage_page = 0xe9;
            usage = 0x40;
            break;
        case WIIAUTO_BUTTON_VOLUME_DOWN:
            usage_page = 12;
            usage = 0xea;
            break;
        case WIIAUTO_BUTTON_ENTER:
            usage_page = 0x07;
            usage = 0x58;
            break;
        case WIIAUTO_BUTTON_BACKSPACE:
            usage_page = 0x07;
            usage = 0x2A;
            break;
        default:
            goto finish;
    }

    wiiauto_device_iohid_send(IOHIDEventCreateKeyboardEvent(kCFAllocatorDefault, mach_absolute_time(), usage_page, usage, input->down, 0));

finish:
    return NULL;
}
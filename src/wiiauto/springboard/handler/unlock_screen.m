#include "unlock_screen.h"
#include "wiiauto/device/device.h"
#include "log/remote_log.h"

CFDataRef springboard_handle_unlock_screen(const __wiiauto_event_unlock_screen *input)
{
    u8 locked;

    wiiauto_device_is_locked(&locked);
    if (locked) {
        wiiauto_device_unlock();
    }
    
    return NULL;
}
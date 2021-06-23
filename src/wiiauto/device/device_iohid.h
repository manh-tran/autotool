#ifndef __wiiauto_device_iohid_h
#define __wiiauto_device_iohid_h

#if defined __cplusplus
extern "C" {
#endif

#include <IOKit/hid/IOHIDEvent.h>
#include <IOKit/hid/IOHIDEventSystemClient.h>

void wiiauto_device_iohid_send(IOHIDEventRef event);
void wiiauto_device_iohid_set_sender_id(IOHIDEventRef event, uint64_t senderID);

#if defined __cplusplus
}
#endif

#endif
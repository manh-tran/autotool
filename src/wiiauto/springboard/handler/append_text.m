#include "append_text.h"
#include "wiiauto/device/device.h"
#include "wiiauto/common/common.h"
#include "cherry/core/buffer.h"
#include "log/remote_log.h"
#include "cherry/encoding/utf8.h"

#include "wiiauto/device/device_iohid.h"
#include <mach/mach_time.h>

@interface UIKeyboardImpl : NSObject
+(UIKeyboardImpl*)sharedInstance;
-(void)addInputString:(NSString*)string;
@end

typedef struct
{
    int usage_page;
    int usage;
    int down;
    float next_sec;
}
__input_key;

static buffer buf = {id_null};
static u8 __registered__ = 0;
static i32 __count__ = 0;
static spin_lock __barrier__ = SPIN_LOCK_INIT;
static buffer __keys__ = {id_null};
static int __processing__ = 0;
static int __key_index__ = 0;

static void __in()
{
    if (!id_validate(buf.iobj)) {
        buffer_new(&buf);
    }
    if (!id_validate(__keys__.iobj)) {
        buffer_new(&__keys__);
    }
}

static void __attribute__((destructor)) __out()
{
    // release(buf.iobj);
    // release(__keys__.iobj);
}

static void __process_input(float sec)
{
    __processing__ = 1;

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, sec * NSEC_PER_SEC), dispatch_get_main_queue() , ^{
        
        lock(&__barrier__);
        __input_key ik;
        u32 len;
        u8 ok = 0;
        buffer_length(__keys__, sizeof(__input_key), &len);
        if (__key_index__ < len) {            
            buffer_get(__keys__, sizeof(__input_key), __key_index__, &ik);
            __key_index__++;
            if (ik.down == 2) {
                wiiauto_device_iohid_send(IOHIDEventCreateKeyboardEvent(kCFAllocatorDefault, mach_absolute_time(), ik.usage_page, ik.usage, 1, 0 ));
                wiiauto_device_iohid_send(IOHIDEventCreateKeyboardEvent(kCFAllocatorDefault, mach_absolute_time(), ik.usage_page, ik.usage, 0, 0 ));
            } else {
                wiiauto_device_iohid_send(IOHIDEventCreateKeyboardEvent(kCFAllocatorDefault, mach_absolute_time(), ik.usage_page, ik.usage, ik.down, 0 ));
            }            
            ok = 1;
        } else {
            __key_index__ = 0;
            buffer_erase(__keys__);

            __processing__ = 0;
        }
        unlock(&__barrier__);

        if (ok) {
            __process_input(ik.next_sec);
        }
    });
}

void notificationCallback (CFNotificationCenterRef center,
    void * observer,
    CFStringRef name,
    const void * object,
    CFDictionaryRef userInfo) 
{
    u8 flag = 0;
    __input_key ik;

    lock(&__barrier__);
    if (__count__ > 0) {
        flag = 1;
        __count__--;
    }

    /* press some character */

    // ik.usage_page = 0x07;
    // ik.usage = 0x2C;
    // ik.down = 1;
    // ik.next_sec = 0.02;
    // buffer_append(__keys__, &ik, sizeof(ik));

    // ik.usage_page = 0x07;
    // ik.usage = 0x2C;
    // ik.down = 0;
    // ik.next_sec = 0.02;
    // buffer_append(__keys__, &ik, sizeof(ik));

    // /* press back button */
    // ik.usage_page = 0x07;
    // ik.usage = 0x2A;
    // ik.down = 1;
    // ik.next_sec = 0.02;
    // buffer_append(__keys__, &ik, sizeof(ik));

    // ik.usage_page = 0x07;
    // ik.usage = 0x2A;
    // ik.down = 0;
    // ik.next_sec = 0.02;
    // buffer_append(__keys__, &ik, sizeof(ik));

    // /* press back button */
    // ik.usage_page = 0x07;
    // ik.usage = 0x2A;
    // ik.down = 1;
    // ik.next_sec = 0.02;
    // buffer_append(__keys__, &ik, sizeof(ik));

    // ik.usage_page = 0x07;
    // ik.usage = 0x2A;
    // ik.down = 0;
    // ik.next_sec = 0.05;
    // buffer_append(__keys__, &ik, sizeof(ik));

    /* patse */
    ik.usage_page = 0x07;
    ik.usage = 0xE3;
    ik.down = 1;
    ik.next_sec = 0.02;
    buffer_append(__keys__, &ik, sizeof(ik));

    ik.usage_page = 0x07;
    ik.usage = 0xE3;
    ik.down = 0;
    ik.next_sec = 0.06;
    buffer_append(__keys__, &ik, sizeof(ik));

    ik.usage_page = 0x07;
    ik.usage = 0xE3;
    ik.down = 1;
    ik.next_sec = 0.02;
    buffer_append(__keys__, &ik, sizeof(ik));

    ik.usage_page = 0x07;
    ik.usage = 0x19;
    ik.down = 1;
    ik.next_sec = 0.02;
    buffer_append(__keys__, &ik, sizeof(ik));

    ik.usage_page = 0x07;
    ik.usage = 0x19;
    ik.down = 0;
    ik.next_sec = 0.02;
    buffer_append(__keys__, &ik, sizeof(ik));

    ik.usage_page = 0x07;
    ik.usage = 0xE3;
    ik.down = 0;
    ik.next_sec = 0.02;
    buffer_append(__keys__, &ik, sizeof(ik));

    unlock(&__barrier__);

    /* paste */
    if (flag) {

        if (!__processing__) {
            __process_input(0.0175);
        }
    }
}

void springboard_append_text_register()
{
    if (!__registered__) {
        __registered__ = 1;
        CFNotificationCenterAddObserver(CFNotificationCenterGetLocalCenter(), 
                                        NULL, 
                                        notificationCallback, 
                                        (__bridge CFStringRef)UIPasteboardChangedNotification, 
                                        NULL, 
                                        CFNotificationSuspensionBehaviorDeliverImmediately);
    }
}

static void __do_append(NSString *s)
{
    springboard_append_text_register();
    
    @try {
        lock(&__barrier__);
        __count__++;        
        unlock(&__barrier__);

        [[UIPasteboard generalPasteboard] setString:s]; 
        [[UIPasteboard generalPasteboard] changeCount];   
    } @catch (NSException *exception) {
    }   
}

CFDataRef springboard_handle_append_text(const __wiiauto_event_append_text *input)
{
    __in();
    
    const char *ptr;
    u32 len;
    
    len = strlen(input->text);
    if (len > sizeof(input->text)) {
        len = sizeof(input->text);
    }
    buffer_append(buf, input->text, len);

    if (input->complete) {

        buffer_get_ptr(buf, &ptr);

        /* set new clipboard */
        @autoreleasepool {
            NSString *s = [NSString stringWithUTF8String:ptr];

            // __do_append(s);

            UIKeyboardImpl * keyboardImpl = (UIKeyboardImpl*) [UIKeyboardImpl sharedInstance];
            [keyboardImpl addInputString:s];

            s = nil;
        }

        buffer_erase(buf);
    }

    return NULL;
}
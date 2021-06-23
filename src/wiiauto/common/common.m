#include "common.h"
#include <sys/time.h>
#include "wiiauto/device/device.h"
#include "wiiauto/device/device_iohid.h"
#include <mach/mach_time.h>
#include "wiiauto/springboard/springboard.h"
#include "wiiauto/backboardd/backboardd.h"
#include "wiiauto/daemon/daemon.h"
#include "wiiauto/app/app.h"
#include "wiiauto/event/event_front_most_app_bundle.h"
#include "wiiauto/event/event_front_most_app_orientation.h"
#include "wiiauto/event/event_front_most_app_port.h"
#include "wiiauto/event/event_touch_screen.h"
#include "wiiauto/event/event_press_button.h"
#include "wiiauto/event/event_append_text.h"
#include "wiiauto/event/event_alert.h"
#include "wiiauto/event/event_toast.h"
#include "wiiauto/event/event_open_url.h"
#include "wiiauto/event/event_app_info.h"
#include "wiiauto/event/event_timer.h"
#include "wiiauto/event/event_daemon_state.h"
#include "wiiauto/event/event_springboard_state.h"
#include "wiiauto/event/event_undim_display.h"
#include "wiiauto/event/event_gps_location.h"
#include "wiiauto/event/event_set_status_bar.h"
#include "wiiauto/event/event_kill_app.h"
#include "wiiauto/event/event_save_photo.h"
#include "wiiauto/event/event_connect_wifi.h"
#include "cherry/math/cmath.h"
#include "cherry/core/file.h"
#include "png/png.h"
#include "png/pngstruct.h"
#include "wiiauto/file/file.h"
#include "wiiauto/daemon/daemon.h"
#include "cherry/util/util.h"
#include "cherry/json/json.h"
#include "cherry/encoding/utf8.h"

// spin_lock __color_barrier__ = 0;

/*
 * helpers
 */
static u64 current_timestamp() 
{
    struct timeval te; 
    gettimeofday(&te, NULL);
    u64 milliseconds = te.tv_sec*1000LL + te.tv_usec/1000;
    return milliseconds;
}

static const char *__get_front_most_bundle(char bundle[256])
{
    static u64 last_milliseconds = 0;
    static char last[256];
    u64 cm;

    cm = current_timestamp();
    if (cm - last_milliseconds >= 16) { /* iphone's refresh rate is 60Hz */
        last_milliseconds = cm;
    } else {
        strcpy(bundle, last);
        return last;
    }

    CFDataRef ref = NULL;
    __wiiauto_event_request_front_most_app_bundle rq;
    const __wiiauto_event_result_front_most_app_bundle *rt;

    __wiiauto_event_request_front_most_app_bundle_init(&rq);
    wiiauto_send_event(1, &rq, sizeof(rq), SPRINGBOARD_MACH_PORT_NAME, &ref);

    __wiiauto_event_result_front_most_app_bundle_fetch(ref, &rt);
    if (rt) {
        strcpy(bundle, rt->bundle);
        strcpy(last, bundle);
    } else {
        bundle[0] = '\0';
        last[0] = '\0';
    }    

    if (ref) {
        CFRelease(ref);
    }

    return last;
}

/*
 * screen_buffer
 */
local_type(screen_buffer);

typedef struct
{
    const __wiiauto_pixel *ptr;
    u32 width;
    u32 height;
    __wiiauto_device_orientation orientation;
}
__screen_buffer;

make_local_type(screen_buffer, __screen_buffer);

static void __screen_buffer_init(__screen_buffer *__p)
{
    wiiauto_device_get_current_screen_buffer(&__p->ptr, &__p->width, &__p->height);
    wiiauto_device_get_orientation(&__p->orientation);
}

static void __screen_buffer_clear(__screen_buffer *__p)
{

}

static void screen_buffer_get_ptr(const screen_buffer p, const __wiiauto_pixel **ptr, u32 *width, u32 *height)
{
    __screen_buffer *__p;

    screen_buffer_fetch(p, &__p);
    assert(__p != NULL);

    *ptr = __p->ptr;
    *width = __p->width;
    *height = __p->height;
}

static void screen_buffer_get_color(const screen_buffer p, const float x, const float y, const __wiiauto_device_orientation o, __wiiauto_pixel *pixel)
{
    __screen_buffer *__p;
    i32 ix = 0, iy = 0, offset = 0;

    screen_buffer_fetch(p, &__p);
    assert(__p != NULL);

    if (!__p->ptr) {
        pixel->r = 0;
        pixel->g = 0;
        pixel->b = 0;
        pixel->a = 0;
        return;
    }

    if (__p->orientation == o) {

        ix = floor(x);
        iy = floor(y);

        if (ix < 0)  {
            ix = 0;
        } else if (ix >= __p->width) {
            ix = __p->width - 1;
        }

        if (iy < 0) {
            iy = 0;
        } else if (iy >= __p->height) {
            iy = __p->height - 1;
        }
    }

    offset = iy * __p->width + ix;

    *pixel = __p->ptr[offset];
}

static screen_buffer __screen_buffer__ = {id_null};

static void __refresh_screen_buffer()
{
    if (!id_validate(__screen_buffer__.iobj)) {
        screen_buffer_new(&__screen_buffer__);
    }

    __screen_buffer *__p;
    screen_buffer_fetch(__screen_buffer__, &__p);
    wiiauto_device_get_current_screen_buffer(&__p->ptr, &__p->width, &__p->height);
    wiiauto_device_get_orientation(&__p->orientation);
}

/*
 * common functions
 */
void common_get_front_most_app_bundle_id(const char **bundle)
{
    char buf[256];

    *bundle = __get_front_most_bundle(buf);
}

void common_get_front_most_app_port(int *port)
{
    static spin_lock __local_barrier__ = SPIN_LOCK_INIT;
    static u64 last_milliseconds = 0;
    static int cache_port = 0;
    int cm = 0;

    lock(&__local_barrier__);

    cm = current_timestamp();
    if (cm - last_milliseconds >= 16) { /* iphone's refresh rate is 60Hz */
        last_milliseconds = cm;
    } else {
        *port = cache_port;
        goto finish;
    }

     CFDataRef ref = NULL;
    __wiiauto_event_request_front_most_app_port rq;
    const __wiiauto_event_result_front_most_app_port *rt;

    __wiiauto_event_request_front_most_app_port_init(&rq);
    wiiauto_send_event(1, &rq, sizeof(rq), BACKBOARDD_MACH_PORT_NAME, &ref);

    __wiiauto_event_result_front_most_app_port_fetch(ref, &rt);
    if (rt) {
        *port = rt->port;
    } else {
        *port = 0;
    } 
    cache_port = *port;   

    if (ref) {
        CFRelease(ref);
    }    

finish:
    unlock(&__local_barrier__);
}

void common_get_screen_size(u32 *width, u32 *height)
{
    static spin_lock __local_barrier__ = SPIN_LOCK_INIT;
    f32 w, h;
    __wiiauto_device_orientation o;

    lock(&__local_barrier__);

    wiiauto_device_get_screen_size(&w, &h);
    common_get_orientation(&o);

    switch (o) {
        case WIIAUTO_DEVICE_ORIENTATION_UNKNOWN:
        case WIIAUTO_DEVICE_ORIENTATION_PORTRAIT:
        case WIIAUTO_DEVICE_ORIENTATION_PORTRAIT_UPSIDE_DOWN:
            *width = MIN(w, h);
            *height = MAX(w, h);
            break;
        case WIIAUTO_DEVICE_ORIENTATION_LANDSCAPE_LEFT:
        case WIIAUTO_DEVICE_ORIENTATION_LANDSCAPE_RIGHT:
            *width = MAX(w, h);
            *height = MIN(w, h);
            break;
    }

    unlock(&__local_barrier__);
}

void common_get_view_size(u32 *width, u32 *height)
{
    static spin_lock __local_barrier__ = SPIN_LOCK_INIT;
    f32 w, h, factor;
    __wiiauto_device_orientation o;

    lock(&__local_barrier__);

    wiiauto_device_get_screen_size(&w, &h);
    wiiauto_device_get_retina_factor(&factor);
    common_get_orientation(&o);

    w *= factor;
    h *= factor;

    switch (o) {
        case WIIAUTO_DEVICE_ORIENTATION_UNKNOWN:
        case WIIAUTO_DEVICE_ORIENTATION_PORTRAIT:
        case WIIAUTO_DEVICE_ORIENTATION_PORTRAIT_UPSIDE_DOWN:
            *width = MIN(w, h);
            *height = MAX(w, h);
            break;
        case WIIAUTO_DEVICE_ORIENTATION_LANDSCAPE_LEFT:
        case WIIAUTO_DEVICE_ORIENTATION_LANDSCAPE_RIGHT:
            *width = MAX(w, h);
            *height = MIN(w, h);
            break;
    }

    unlock(&__local_barrier__);
}

void common_get_orientation(__wiiauto_device_orientation *o)
{
    // static spin_lock __local_barrier__ = 0;
    // static u64 last_milliseconds = 0;
    // static __wiiauto_device_orientation lo = 0;
    // u64 cm;

    // lock(&__local_barrier__);

    // cm = current_timestamp();
    // if (cm - last_milliseconds >= 16) { /* iphone's refresh rate is 60Hz */
    //     last_milliseconds = cm;
    // } else {
    //     *o = lo;
    //     goto finish;
    // }

    // char buf[256];

    // *o = WIIAUTO_DEVICE_ORIENTATION_UNKNOWN;

    // __get_front_most_bundle(buf);
    // if (!buf[0]) {
    //     wiiauto_device_get_orientation(o);
    // } else {


        wiiauto_device_get_app_orientation(o);


        
//     }    
//     lo = *o;

// finish:
//     unlock(&__local_barrier__);
}

void common_get_current_app_id(const buffer b)
{
    static spin_lock __local_barrier__ = SPIN_LOCK_INIT;
    char buf[256];

    buffer_erase(b);

    lock(&__local_barrier__);

    __get_front_most_bundle(buf);
    if (buf[0]) {
        buffer_append(b, buf, strlen(buf));
    }

    unlock(&__local_barrier__);
}

static void __convert_point(const f32 x, const f32 y, f32 *ox, f32 *oy)
{
    static spin_lock __local_barrier__ = SPIN_LOCK_INIT;
    f32 w, h, factor;
    __wiiauto_device_orientation o;

    lock(&__local_barrier__);

    wiiauto_device_get_screen_size(&w, &h);
    wiiauto_device_get_retina_factor(&factor);

    w *= factor;
    h *= factor;

    common_get_orientation(&o);

    switch (o) {
        case WIIAUTO_DEVICE_ORIENTATION_UNKNOWN:
        case WIIAUTO_DEVICE_ORIENTATION_PORTRAIT:
            *ox = x;
            *oy = y;
            break;
        case WIIAUTO_DEVICE_ORIENTATION_PORTRAIT_UPSIDE_DOWN:
            *ox = w - 1 - x;
            *oy = h - 1 - y;
            break;
        case WIIAUTO_DEVICE_ORIENTATION_LANDSCAPE_RIGHT:
            *oy = x;
            *ox = w - 1 - y;
            break;
        case WIIAUTO_DEVICE_ORIENTATION_LANDSCAPE_LEFT:
            *oy = h - 1 - x;
            *ox = y;
            break;
    }

    // *ox /= factor;
    // *oy /= factor;
    *ox /= w;
    *oy /= h;

    unlock(&__local_barrier__);
}

static void __send_zoom(const float x1, const float y1, const float x2, const float y2, const uint32_t index, uint32_t parent_flags, uint32_t child_flags, int in_range, int in_touch)
{
    IOHIDEventRef parent = IOHIDEventCreateDigitizerEvent(kCFAllocatorDefault, mach_absolute_time(), kIOHIDDigitizerTransducerTypeHand, 1 << 22, 1, parent_flags, 0, 0, 0, 0, 0, 0, 0, 0, 0);
    IOHIDEventSetIntegerValue(parent, kIOHIDEventFieldIsBuiltIn, true);
    IOHIDEventSetIntegerValue(parent, kIOHIDEventFieldDigitizerIsDisplayIntegrated, true);

    wiiauto_device_iohid_set_sender_id(parent, 0x8000000817319375);
   
    IOHIDEventRef child = IOHIDEventCreateDigitizerFingerEvent(kCFAllocatorDefault, mach_absolute_time(), index + 5, index + 5 + 2, child_flags, x1, y1, 0, 0, 0, in_range, in_touch, 0);
    IOHIDEventAppendEvent(parent, child);
    CFRelease(child);

    child = IOHIDEventCreateDigitizerFingerEvent(kCFAllocatorDefault, mach_absolute_time(), index + 6, index + 5 + 2, child_flags, x2, y2, 0, 0, 0, in_range, in_touch, 0);
    IOHIDEventAppendEvent(parent, child);
    CFRelease(child);

    wiiauto_device_iohid_send(parent);
}

void common_zoom_down(const u8 index, const f32 x1, const f32 y1, const f32 x2, const f32 y2)
{
    static spin_lock __local_barrier__ = SPIN_LOCK_INIT;
    __wiiauto_event_touch_screen ts; 
    f32 ox1, oy1, ox2, oy2;

    lock(&__local_barrier__);

    __convert_point(x1, y1, &ox1, &oy1);
    __convert_point(x2, y2, &ox2, &oy2);

    __send_zoom(
        ox1, oy1,
        ox2, oy2,
        index,
        kIOHIDDigitizerEventRange | kIOHIDDigitizerEventTouch | kIOHIDDigitizerEventIdentity,
        kIOHIDDigitizerEventRange | kIOHIDDigitizerEventTouch,
        1,
        1
        );

    unlock(&__local_barrier__);
}

void common_zoom_move(const u8 index, const f32 x1, const f32 y1, const f32 x2, const f32 y2)
{
    static spin_lock __local_barrier__ = SPIN_LOCK_INIT;
    __wiiauto_event_touch_screen ts; 
    f32 ox1, oy1, ox2, oy2;

    lock(&__local_barrier__);

    __convert_point(x1, y1, &ox1, &oy1);
    __convert_point(x2, y2, &ox2, &oy2);

    __send_zoom(
        ox1, oy1,
        ox2, oy2,
        index,
        kIOHIDDigitizerEventPosition,
        kIOHIDDigitizerEventPosition,
        1,
        1
        );

    unlock(&__local_barrier__);
}

void common_zoom_up(const u8 index, const f32 x1, const f32 y1, const f32 x2, const f32 y2)
{
    static spin_lock __local_barrier__ = SPIN_LOCK_INIT;
    __wiiauto_event_touch_screen ts; 
    f32 ox1, oy1, ox2, oy2;

    lock(&__local_barrier__);

    __convert_point(x1, y1, &ox1, &oy1);
    __convert_point(x2, y2, &ox2, &oy2);

    __send_zoom(
        ox1, oy1,
        ox2, oy2,
        index,
        kIOHIDDigitizerEventRange | kIOHIDDigitizerEventTouch | kIOHIDDigitizerEventIdentity | kIOHIDDigitizerEventPosition,
        kIOHIDDigitizerEventRange | kIOHIDDigitizerEventTouch,
        0,
        0
        );

    unlock(&__local_barrier__);
}

static void __send(const float x, const float y, const uint32_t index, uint32_t parent_flags, uint32_t child_flags, int in_range, int in_touch)
{
    IOHIDEventRef parent = IOHIDEventCreateDigitizerEvent(kCFAllocatorDefault, mach_absolute_time(), kIOHIDDigitizerTransducerTypeHand, 1 << 22, 1, parent_flags, 0, x, y, 0, 0, 0, 0, 0, 0);
    IOHIDEventSetIntegerValue(parent, kIOHIDEventFieldIsBuiltIn, true);
    IOHIDEventSetIntegerValue(parent, kIOHIDEventFieldDigitizerIsDisplayIntegrated, true);

    wiiauto_device_iohid_set_sender_id(parent, 0x8000000817319375);
    IOHIDEventRef child = IOHIDEventCreateDigitizerFingerEvent(kCFAllocatorDefault, mach_absolute_time(), index + 5, index + 5 + 2, child_flags, x, y, 0, 0, 0, in_range, in_touch, 0);
    IOHIDEventAppendEvent(parent, child);
    CFRelease(child);

    wiiauto_device_iohid_send(parent);
}

void common_touch_down(const u8 index, const f32 x, const f32 y)
{
    static spin_lock __local_barrier__ = SPIN_LOCK_INIT;
    __wiiauto_event_touch_screen ts; 
    f32 ox, oy;

    lock(&__local_barrier__);

    __convert_point(x, y, &ox, &oy);

    __send(
        ox, oy,
        index,
        kIOHIDDigitizerEventRange | kIOHIDDigitizerEventTouch | kIOHIDDigitizerEventIdentity,
        kIOHIDDigitizerEventRange | kIOHIDDigitizerEventTouch,
        1,
        1
        );

    // __wiiauto_event_touch_screen_init(&ts);
    // ts.index = index;
    // ts.type = WIIAUTO_TOUCH_UPDATE;
    // ts.x = ox;
    // ts.y = oy;
    // wiiauto_send_event_uncheck_return(1, &ts, sizeof(ts), SPRINGBOARD_MACH_PORT_NAME);

    unlock(&__local_barrier__);
}

void common_touch_move(const u8 index, const f32 x, const f32 y)
{
    static spin_lock __local_barrier__ = SPIN_LOCK_INIT;
    __wiiauto_event_touch_screen ts; 
    f32 ox, oy;

    lock(&__local_barrier__);

    __convert_point(x, y, &ox, &oy);

    __send(
        ox, oy,
        index,
        kIOHIDDigitizerEventPosition,
        kIOHIDDigitizerEventPosition,
        1,
        1
        );

    // __wiiauto_event_touch_screen_init(&ts);
    // ts.index = index;
    // ts.type = WIIAUTO_TOUCH_UPDATE;
    // ts.x = ox;
    // ts.y = oy;
    // wiiauto_send_event_uncheck_return(1, &ts, sizeof(ts), SPRINGBOARD_MACH_PORT_NAME);

    unlock(&__local_barrier__);
}

void common_touch_up(const u8 index, const f32 x, const f32 y)
{
    static spin_lock __local_barrier__ = SPIN_LOCK_INIT;

    __wiiauto_event_touch_screen ts; 
    f32 ox, oy;

    lock(&__local_barrier__);

    __convert_point(x, y, &ox, &oy);

    __send(
        ox, oy,
        index,
        kIOHIDDigitizerEventRange | kIOHIDDigitizerEventTouch | kIOHIDDigitizerEventIdentity | kIOHIDDigitizerEventPosition,
        kIOHIDDigitizerEventRange | kIOHIDDigitizerEventTouch,
        0,
        0
        );

    // __wiiauto_event_touch_screen_init(&ts);
    // ts.index = index;
    // ts.type = WIIAUTO_TOUCH_EXPIRE;
    // ts.x = ox;
    // ts.y = oy;
    // wiiauto_send_event_uncheck_return(1, &ts, sizeof(ts), SPRINGBOARD_MACH_PORT_NAME);

    unlock(&__local_barrier__);
}

static void __key_type_to_usage(const i32 type, int *usage_page, int *usage)
{
    switch (type) {
        case WIIAUTO_BUTTON_HOME:
            *usage_page = 12;
            *usage = 0x40;
            break;
        case WIIAUTO_BUTTON_LOCK:
            *usage_page = 12;
            *usage = 0x30;
            break;
        case WIIAUTO_BUTTON_VOLUME_UP:
            *usage_page = 0xe9;
            *usage = 0x40;
            break;
        case WIIAUTO_BUTTON_VOLUME_DOWN:
            *usage_page = 12;
            *usage = 0xea;
            break;
        case WIIAUTO_BUTTON_ENTER:
            *usage_page = 0x07;
            *usage = 0x58;
            break;
        case WIIAUTO_BUTTON_BACKSPACE:
            *usage_page = 0x07;
            *usage = 0x2A;
            break;
        default:
            break;
    }
}

void common_key_down(const i32 type)
{
    static spin_lock __local_barrier__ = SPIN_LOCK_INIT;
    __wiiauto_event_press_button pb;

    lock(&__local_barrier__);

    int usage_page = 0;
    int usage = 0;
    __key_type_to_usage(type, &usage_page, &usage);
    wiiauto_device_iohid_send(IOHIDEventCreateKeyboardEvent(kCFAllocatorDefault, mach_absolute_time(), usage_page, usage, 1, 0));


    // __wiiauto_event_press_button_init(&pb);
    // pb.down = 1;
    // pb.type = type;
    // wiiauto_send_event_uncheck_return(1, &pb, sizeof(pb), SPRINGBOARD_MACH_PORT_NAME);

    unlock(&__local_barrier__);
}

void common_key_up(const i32 type)
{
    static spin_lock __local_barrier__ = SPIN_LOCK_INIT;
    __wiiauto_event_press_button pb;

    lock(&__local_barrier__);

    int usage_page = 0;
    int usage = 0;
    __key_type_to_usage(type, &usage_page, &usage);
    wiiauto_device_iohid_send(IOHIDEventCreateKeyboardEvent(kCFAllocatorDefault, mach_absolute_time(), usage_page, usage, 0, 0));


    // __wiiauto_event_press_button_init(&pb);
    // pb.down = 0;
    // pb.type = type;
    // wiiauto_send_event_uncheck_return(1, &pb, sizeof(pb), SPRINGBOARD_MACH_PORT_NAME);

    unlock(&__local_barrier__);
}

void common_key_down_detail(const i32 usage_page, const i32 usage)
{
    static spin_lock __local_barrier__ = SPIN_LOCK_INIT;

    lock(&__local_barrier__);

    wiiauto_device_iohid_send(IOHIDEventCreateKeyboardEvent(kCFAllocatorDefault, mach_absolute_time(), usage_page, usage, 1, 0));

    unlock(&__local_barrier__);
}

void common_key_up_detail(const i32 usage_page, const i32 usage)
{
    static spin_lock __local_barrier__ = SPIN_LOCK_INIT;

    lock(&__local_barrier__);

    wiiauto_device_iohid_send(IOHIDEventCreateKeyboardEvent(kCFAllocatorDefault, mach_absolute_time(), usage_page, usage, 0, 0));

    unlock(&__local_barrier__);
}

#import <BackBoardServices/BackBoardServices.h>

void common_kill_app(const char *bundle)
{
    @try {
        @autoreleasepool {
            NSString *nsbundle = [NSString stringWithUTF8String:bundle];
            BKSTerminateApplicationForReasonAndReportWithDescription((__bridge CFStringRef)nsbundle, 1, 0, NULL);
            nsbundle = nil;
        }
    } 
    @catch (NSException *exception) {
    
    }   
    
    // static spin_lock __local_barrier__ = SPIN_LOCK_INIT;
    // __wiiauto_event_kill_app evt;

    // lock(&__local_barrier__);

    // __wiiauto_event_kill_app_init(&evt);
    // strcpy(evt.bundle, bundle);
    // wiiauto_send_event_uncheck_return(1, &evt, sizeof(evt), SPRINGBOARD_MACH_PORT_NAME);

    // unlock(&__local_barrier__);
}

#import <notify.h>
#include "log/remote_log.h"
void common_append_text(const char *text, const int word_by_word)
{
    static spin_lock __local_barrier__ = SPIN_LOCK_INIT;
    static const char *__files__[] = {
        DAEMON_FILE_INPUT_TEXT_1,
        DAEMON_FILE_INPUT_TEXT_2,
        DAEMON_FILE_INPUT_TEXT_3,
        DAEMON_FILE_INPUT_TEXT_4,
        DAEMON_FILE_INPUT_TEXT_5,
        DAEMON_FILE_INPUT_TEXT_6,
        DAEMON_FILE_INPUT_TEXT_7,
        DAEMON_FILE_INPUT_TEXT_8,
        DAEMON_FILE_INPUT_TEXT_9,
        DAEMON_FILE_INPUT_TEXT_10
    };
    static const char *__signals__[] = {
        "com.wiimob.wiiauto/inputText1",
        "com.wiimob.wiiauto/inputText2",
        "com.wiimob.wiiauto/inputText3",
        "com.wiimob.wiiauto/inputText4",
        "com.wiimob.wiiauto/inputText5",
        "com.wiimob.wiiauto/inputText6",
        "com.wiimob.wiiauto/inputText7",
        "com.wiimob.wiiauto/inputText8",
        "com.wiimob.wiiauto/inputText9",
        "com.wiimob.wiiauto/inputText10"
    };
    static int __index__ = 0;
    // __wiiauto_event_append_text at;
    // u32 len;
    // u32 max;
    // i32 i;

    lock(&__local_barrier__);

    @autoreleasepool {

        @try {
            // [[UIPasteboard generalPasteboard] setString:[NSString stringWithUTF8String:text]]; 
            // NSUserDefaults *prefs = [[NSUserDefaults alloc] initWithSuiteName:@"com.wiimob.wiiautoinputtext"];
            // [prefs setValue:[NSString stringWithUTF8String:text] forKey:@"text"];
            // [prefs synchronize];
            // usleep(20000);

            file f;
            file_new(&f);
            file_open_write(f, __files__[__index__]);
            
            file_write(f, text, strlen(text));
            release(f.iobj);
            usleep(16000);

            const char *bundle;
            common_get_front_most_app_bundle_id(&bundle);

            // if (bundle && strlen(bundle) > 0) {
            //     NSString *msg = [NSString stringWithFormat:@"%s.%s", bundle, __signals__[__index__]];
            //     notify_post([msg UTF8String]);     

            //     msg = [NSString stringWithFormat:@"%s.%s", "com.apple.springboard", __signals__[__index__]];
            //     notify_post([msg UTF8String]);           
            // } else {
            //     // notify_post( __signals__[__index__]);     
            //     NSString *msg = [NSString stringWithFormat:@"%s.%s", "com.apple.springboard", __signals__[__index__]];
            //     notify_post([msg UTF8String]);         
            // }

            notify_post(__signals__[__index__]);
            usleep(16000);

            __index__++;
            if (__index__ >= 10) {
                __index__ = 0;
            }
        } @catch (NSException *e)
        {
            
        }

        // int usage_page;
        // int usage;
        // int down;

        // [[UIPasteboard generalPasteboard] setString:[NSString stringWithUTF8String:text]]; 
        // [[UIPasteboard generalPasteboard] changeCount]; 
        // usleep(1000);

        // usage_page = 0x07;
        // usage = 0x19;
        // down = 0;
        // wiiauto_device_iohid_send(IOHIDEventCreateKeyboardEvent(kCFAllocatorDefault, mach_absolute_time(), usage_page, usage, down, 0 ));
        // usleep(1000);

        // usage_page = 0x07;
        // usage = 0xE3;
        // down = 0;
        // wiiauto_device_iohid_send(IOHIDEventCreateKeyboardEvent(kCFAllocatorDefault, mach_absolute_time(), usage_page, usage, down, 0 ));
        // usleep(1000);

        // usage_page = 0x07;
        // usage = 0xE3;
        // down = 1;
        // wiiauto_device_iohid_send(IOHIDEventCreateKeyboardEvent(kCFAllocatorDefault, mach_absolute_time(), usage_page, usage, down, 0 ));
        // usleep(1000);

        // usage_page = 0x07;
        // usage = 0x19;
        // down = 1;
        // wiiauto_device_iohid_send(IOHIDEventCreateKeyboardEvent(kCFAllocatorDefault, mach_absolute_time(), usage_page, usage, down, 0 ));
        // usleep(1000);

        // usage_page = 0x07;
        // usage = 0x19;
        // down = 0;
        // wiiauto_device_iohid_send(IOHIDEventCreateKeyboardEvent(kCFAllocatorDefault, mach_absolute_time(), usage_page, usage, down, 0 ));
        // usleep(1000);

        // usage_page = 0x07;
        // usage = 0xE3;
        // down = 0;
        // wiiauto_device_iohid_send(IOHIDEventCreateKeyboardEvent(kCFAllocatorDefault, mach_absolute_time(), usage_page, usage, down, 0 ));
        // usleep(1000);

    }

    // __wiiauto_event_append_text_init(&at);

    // len = strlen(text);
    // max = sizeof(at.text) - 1;

    // i = 0;

    // while (i + max < len) {
    //     memcpy(at.text, text + i, max);
    //     at.text[max] = '\0';
    //     at.complete = 0;
    //     wiiauto_send_event_uncheck_return(1, &at, sizeof(at), SPRINGBOARD_MACH_PORT_NAME);

    //     i += max;
    // }

    // at.text[0] = '\0';
    // strncat(at.text, text + i, len - i);
    // at.complete = 1;
    // wiiauto_send_event_uncheck_return(1, &at, sizeof(at), SPRINGBOARD_MACH_PORT_NAME);

    unlock(&__local_barrier__);
}


void common_append_text_paste(const char *text, const int word_by_word)
{
    static spin_lock __local_barrier__ = SPIN_LOCK_INIT;
    
    lock(&__local_barrier__);

    int usage_page;
    int usage;
    int down;

    [[UIPasteboard generalPasteboard] setString:[NSString stringWithUTF8String:text]]; 
    [[UIPasteboard generalPasteboard] changeCount]; 
    usleep(1000);

    usage_page = 0x07;
    usage = 0x19;
    down = 0;
    wiiauto_device_iohid_send(IOHIDEventCreateKeyboardEvent(kCFAllocatorDefault, mach_absolute_time(), usage_page, usage, down, 0 ));
    usleep(1000);

    usage_page = 0x07;
    usage = 0xE3;
    down = 0;
    wiiauto_device_iohid_send(IOHIDEventCreateKeyboardEvent(kCFAllocatorDefault, mach_absolute_time(), usage_page, usage, down, 0 ));
    usleep(1000);

    usage_page = 0x07;
    usage = 0xE3;
    down = 1;
    wiiauto_device_iohid_send(IOHIDEventCreateKeyboardEvent(kCFAllocatorDefault, mach_absolute_time(), usage_page, usage, down, 0 ));
    usleep(1000);

    usage_page = 0x07;
    usage = 0x19;
    down = 1;
    wiiauto_device_iohid_send(IOHIDEventCreateKeyboardEvent(kCFAllocatorDefault, mach_absolute_time(), usage_page, usage, down, 0 ));
    usleep(1000);

    usage_page = 0x07;
    usage = 0x19;
    down = 0;
    wiiauto_device_iohid_send(IOHIDEventCreateKeyboardEvent(kCFAllocatorDefault, mach_absolute_time(), usage_page, usage, down, 0 ));
    usleep(1000);

    usage_page = 0x07;
    usage = 0xE3;
    down = 0;
    wiiauto_device_iohid_send(IOHIDEventCreateKeyboardEvent(kCFAllocatorDefault, mach_absolute_time(), usage_page, usage, down, 0 ));
    usleep(1000);

    unlock(&__local_barrier__);
}


void common_connect_wifi(const char *ssid, const char *pass)
{
    static spin_lock __local_barrier__ = SPIN_LOCK_INIT;
    __wiiauto_event_connect_wifi at;
    
    lock(&__local_barrier__);

    __wiiauto_event_connect_wifi_init(&at);
    strcpy(at.ssid, ssid);
    strcpy(at.pass, pass);

    wiiauto_send_event_uncheck_return(1, &at, sizeof(at), SPRINGBOARD_MACH_PORT_NAME);

    unlock(&__local_barrier__);
}

void common_open_url(const char *text)
{
    static spin_lock __local_barrier__ = SPIN_LOCK_INIT;
    __wiiauto_event_open_url at;
    u32 len;
    u32 max;
    i32 i;

    lock(&__local_barrier__);

    __wiiauto_event_open_url_init(&at);

    len = strlen(text);
    max = sizeof(at.text) - 1;

    i = 0;

    while (i + max < len) {
        memcpy(at.text, text + i, max);
        at.text[max] = '\0';
        at.complete = 0;
        wiiauto_send_event_uncheck_return(1, &at, sizeof(at), SPRINGBOARD_MACH_PORT_NAME);

        i += max;
    }

    at.text[0] = '\0';
    strncat(at.text, text + i, len - i);
    at.complete = 1;
    wiiauto_send_event_uncheck_return(1, &at, sizeof(at), SPRINGBOARD_MACH_PORT_NAME);

    unlock(&__local_barrier__);
}

void common_alert(const char *text)
{
    static spin_lock __local_barrier__ = SPIN_LOCK_INIT;
    __wiiauto_event_alert at;
    u32 len;
    u32 max;
    i32 i;

    lock(&__local_barrier__);

    __wiiauto_event_alert_init(&at);

    len = strlen(text);
    max = sizeof(at.text) - 1;

    i = 0;

    while (i + max < len) {
        memcpy(at.text, text + i, max);
        at.text[max] = '\0';
        at.complete = 0;
        wiiauto_send_event_uncheck_return(1, &at, sizeof(at), SPRINGBOARD_MACH_PORT_NAME);

        i += max;
    }

    at.text[0] = '\0';
    strncat(at.text, text + i, len - i);
    at.complete = 1;
    wiiauto_send_event_uncheck_return(1, &at, sizeof(at), SPRINGBOARD_MACH_PORT_NAME);

    unlock(&__local_barrier__);
}

void common_toast(const char *text, const float delay)
{
    static spin_lock __local_barrier__ = SPIN_LOCK_INIT;
    __wiiauto_event_toast at;
    u32 len;
    u32 max;
    i32 i;

    lock(&__local_barrier__);

    __wiiauto_event_toast_init(&at);

    at.delay = delay;

    len = strlen(text);
    max = sizeof(at.text) - 1;

    i = 0;

    while (i + max < len) {
        memcpy(at.text, text + i, max);
        at.text[max] = '\0';
        at.complete = 0;
        wiiauto_send_event_uncheck_return(1, &at, sizeof(at), SPRINGBOARD_MACH_PORT_NAME);

        i += max;
    }

    at.text[0] = '\0';
    strncat(at.text, text + i, len - i);
    at.complete = 1;
    wiiauto_send_event_uncheck_return(1, &at, sizeof(at), SPRINGBOARD_MACH_PORT_NAME);

    unlock(&__local_barrier__);
}

void common_set_status_bar_state(const u8 visible)
{
    static spin_lock __local_barrier__ = SPIN_LOCK_INIT;
    __wiiauto_event_set_status_bar_state at;

    lock(&__local_barrier__);
    __wiiauto_event_set_status_bar_state_init(&at);
    at.visible = visible;
    wiiauto_send_event_uncheck_return(1, &at, sizeof(at), SPRINGBOARD_MACH_PORT_NAME);
    unlock(&__local_barrier__);
}

void common_set_status_bar(const char *text)
{
    static spin_lock __local_barrier__ = SPIN_LOCK_INIT;
    __wiiauto_event_set_status_bar at;
    u32 len;
    u32 max;
    i32 i;

    lock(&__local_barrier__);

    __wiiauto_event_set_status_bar_init(&at);

    len = strlen(text);
    max = sizeof(at.text) - 1;

    i = 0;

    while (i + max < len) {
        memcpy(at.text, text + i, max);
        at.text[max] = '\0';
        at.complete = 0;
        wiiauto_send_event_uncheck_return(1, &at, sizeof(at), SPRINGBOARD_MACH_PORT_NAME);

        i += max;
    }

    at.text[0] = '\0';
    strncat(at.text, text + i, len - i);
    at.complete = 1;
    wiiauto_send_event_uncheck_return(1, &at, sizeof(at), SPRINGBOARD_MACH_PORT_NAME);

    unlock(&__local_barrier__);
}

void common_get_color(const f32 x, const f32 y, i32 *color)
{
    static spin_lock __local_barrier__ = SPIN_LOCK_INIT;
    __refresh_screen_buffer();

    __wiiauto_pixel pixel;
    __wiiauto_device_orientation o;

    lock(&__local_barrier__);

    common_get_orientation(&o);
    screen_buffer_get_color(__screen_buffer__, x, y, o, &pixel);

    *color = ((pixel.r&0x0ff)<<16)|((pixel.g&0x0ff)<<8)|(pixel.b&0x0ff);

    unlock(&__local_barrier__);
}

void common_get_device_color_pointer(const __wiiauto_pixel **ptr)
{
    static spin_lock __local_barrier__ = SPIN_LOCK_INIT;
    __refresh_screen_buffer();
    __screen_buffer *__p;

    lock(&__local_barrier__);

    screen_buffer_fetch(__screen_buffer__, &__p);
    *ptr = __p->ptr;

    unlock(&__local_barrier__);
}

void common_get_rgb(const f32 x, const f32 y, u8 *r, u8 *g, u8 *b)
{
    static spin_lock __local_barrier__ = SPIN_LOCK_INIT;
    __refresh_screen_buffer();

    __wiiauto_pixel pixel;
    __wiiauto_device_orientation o;

    lock(&__local_barrier__);

    common_get_orientation(&o);
    screen_buffer_get_color(__screen_buffer__, x, y, o, &pixel);

    *r = pixel.r;
    *g = pixel.g;
    *b = pixel.b;

    unlock(&__local_barrier__);
}

void common_rgb_to_int(const u8 r, const u8 g, const u8 b, i32 *color)
{
    *color = ((r&0x0ff)<<16)|((g&0x0ff)<<8)|(b&0x0ff);
}

void common_int_to_rgb(const i32 color, u8 *r, u8 *g, u8 *b)
{
    *r = (color >> 16) & 0x000000ff;
    *g = (color >> 8) & 0x000000ff;
    *b = color & 0x000000ff;
}

void common_get_internal_url(const char *path, const buffer b)
{
    buffer_erase(b);

    if (!path) {
        return;
    }

    if (strncmp(path, WIIAUTO_INTERNAL_URL, sizeof(WIIAUTO_INTERNAL_URL) - 1) != 0) {
        buffer_append(b, WIIAUTO_INTERNAL_URL, sizeof(WIIAUTO_INTERNAL_URL) - 1);
    }

    buffer_append(b, path, strlen(path));
}

void common_get_script_url(const char *path, const buffer b)
{
    buffer_erase(b);

    if (!path) {
        return;
    }

    if (strncmp(path, "/private", strlen("/private")) == 0
        || strncmp(path, "/var", strlen("/var")) == 0
        || strncmp(path, "/System", strlen("/System")) == 0
        || strncmp(path, WIIAUTO_SCRIPT_URL, sizeof(WIIAUTO_SCRIPT_URL) - 1) == 0
        || strncmp(path, IOS_FILE_URL, sizeof(IOS_FILE_URL) - 1) == 0
        || strncmp(path, WIIAUTO_INTERNAL_URL, sizeof(WIIAUTO_INTERNAL_URL) - 1) == 0
        || strncmp(path, WIIAUTO_RESOURCE_URL, sizeof(WIIAUTO_RESOURCE_URL) - 1) == 0) {
        buffer_append(b, path, strlen(path));
    } else {
        if (strncmp(path, WIIAUTO_SCRIPT_URL, sizeof(WIIAUTO_SCRIPT_URL) - 1) != 0) {
            buffer_append(b, WIIAUTO_SCRIPT_URL, sizeof(WIIAUTO_SCRIPT_URL) - 1);
        }

        buffer_append(b, path, strlen(path));
    }
}

/*
 * write PNG - rgb
 */
static void write_png_chunk(png_structp png_ptr, png_bytep data, png_size_t length)
{
    file_write(*(file *)png_ptr->io_ptr, data, length);
}

static void __write_png_flush(png_structp png_ptr)
{
}

static int writeImage(const char* filename, const i32 range[4], const __wiiauto_pixel *buffer, const u32 buffer_width, const u32 buffer_height)
{
	int code = 0;
    file f;
	png_structp png_ptr = NULL;
	png_infop info_ptr = NULL;
	png_bytep row = NULL;
    i32 index;
	
    file_new(&f);
    file_open_write(f, filename);

	png_ptr = png_create_write_struct(PNG_LIBPNG_VER_STRING, NULL, NULL, NULL);
	if (png_ptr == NULL) {
		code = 1;
		goto finalise;
	}

	info_ptr = png_create_info_struct(png_ptr);
	if (info_ptr == NULL) {
		code = 1;
		goto finalise;
	}

	if (setjmp(png_jmpbuf(png_ptr))) {
		code = 1;
		goto finalise;
	}

    png_set_write_fn(png_ptr, &f, write_png_chunk, __write_png_flush);

	png_set_IHDR(png_ptr, info_ptr, range[2], range[3],
			8, PNG_COLOR_TYPE_RGBA, PNG_INTERLACE_NONE,
			PNG_COMPRESSION_TYPE_BASE, PNG_FILTER_TYPE_BASE);

	png_write_info(png_ptr, info_ptr);

	row = (png_bytep) malloc(4 * range[2] * sizeof(png_byte));

	int x, y;
	for (y = 0 ; y < range[3] ; y++) {

		for (x = 0 ; x < range[2] ; x++) {

            index = (range[1] + y) * buffer_width + range[0] + x;
 
            row[x * 4] = buffer[index].r;
            row[x * 4 + 1] = buffer[index].g;
            row[x * 4 + 2] = buffer[index].b; 
            row[x * 4 + 3] = buffer[index].a;

		}
		png_write_row(png_ptr, row);
	}

	png_write_end(png_ptr, NULL);

finalise:
    release(f.iobj);
	if (info_ptr != NULL) png_free_data(png_ptr, info_ptr, PNG_FREE_ALL, -1);
	if (png_ptr != NULL) png_destroy_write_struct(&png_ptr, (png_infopp)NULL);
	if (row != NULL) free(row);

	return code;
}

void common_write_png(const char *path, const u8 *ptr, const u32 width, const u32 height)
{
    buffer b;
    const char *full_path = NULL;

    buffer_new(&b);
    common_get_script_url(path, b);
    buffer_get_ptr(b, &full_path);

    writeImage(full_path, (i32[4]){0, 0, width, height}, ptr, width, height);

    release(b.iobj);
}

void common_save_screen_shot(const char *path, const i32 range[4])
{
    // lock(&__color_barrier__);

    __refresh_screen_buffer();

    // unlock(&__color_barrier__);

    buffer b;
    const __wiiauto_pixel *ptr;
    const char *full_path = NULL;
    u32 width, height;

    buffer_new(&b);

    common_get_script_url(path, b);

    buffer_get_ptr(b, &full_path);
    screen_buffer_get_ptr(__screen_buffer__, &ptr, &width, &height);

    if (ptr) {
        writeImage(full_path, range, ptr, width, height);
    }    
    
    release(b.iobj);    
}

void common_minisleep()
{
    usleep(0.02 * 1000 * 1000);
}

void common_get_app_info(const char *bundle, const buffer data_container_path, const buffer display_name, const buffer bundle_container_path, const buffer executable_path)
{
    static spin_lock __local_barrier__ = SPIN_LOCK_INIT;

    lock(&__local_barrier__);

    CFDataRef ref = NULL;
    __wiiauto_event_request_app_info rq;
    const __wiiauto_event_result_app_info *rt;

    buffer_erase(data_container_path);
    buffer_erase(display_name);
    buffer_erase(bundle_container_path);
    buffer_erase(executable_path);

    __wiiauto_event_request_app_info_init(&rq);
    memcpy(rq.bundle, bundle, strlen(bundle));
    wiiauto_send_event(1, &rq, sizeof(rq), SPRINGBOARD_MACH_PORT_NAME, &ref);

    __wiiauto_event_result_app_info_fetch(ref, &rt);
    if (rt) {
        buffer_append(data_container_path, rt->data_container_path, strlen(rt->data_container_path));
        buffer_append(display_name, rt->display_name, strlen(rt->display_name));
        buffer_append(bundle_container_path, rt->bundle_container_path, strlen(rt->bundle_container_path));
        buffer_append(executable_path, rt->executable_path, strlen(rt->executable_path));
    }

    if (ref) {
        CFRelease(ref);
    }  

    unlock(&__local_barrier__);
}

void common_set_timer(const char *url, const time_t fire_time, const u8 repeat, const i32 interval)
{
    static spin_lock __local_barrier__ = SPIN_LOCK_INIT;

    lock(&__local_barrier__);
    __wiiauto_event_set_timer st;

    __wiiauto_event_set_timer_init(&st);
    strcpy(st.url,  url);
    st.fire_time = fire_time;
    st.repeat = repeat;
    st.interval = interval;

    wiiauto_send_event_uncheck_return(1, &st, sizeof(st), DAEMON_MACH_PORT_NAME);

    unlock(&__local_barrier__);
}

void common_remove_timer(const char *url)
{
    static spin_lock __local_barrier__ = SPIN_LOCK_INIT;
    __wiiauto_event_remove_timer st;

    lock(&__local_barrier__);

    __wiiauto_event_remove_timer_init(&st);
    strcpy(st.url,  url);

    wiiauto_send_event_uncheck_return(1, &st, sizeof(st), DAEMON_MACH_PORT_NAME);

    unlock(&__local_barrier__);
}

void common_is_daemon_running(u8 *r)
{
    char buf[1024];

    *r = 0;
    FILE *fp = popen("ps -u root | grep /usr/bin/wiiauto_run", "r");
    if (fp) {
        while (fgets(buf, 1024, fp) != NULL) {
            if (strstr(buf, "daemon_execute")) {
                *r = 1;
            }
        }
        pclose(fp);
    } else {
        *r = 2;
    }
}

void common_is_springboard_running(u8 *r, int32_t *pid)
{
    static spin_lock __local_barrier__ = SPIN_LOCK_INIT;

    lock(&__local_barrier__);

    CFDataRef ref = NULL;
    __wiiauto_event_request_springboard_state rq;
    const __wiiauto_event_result_springboard_state *rt;

    __wiiauto_event_request_springboard_state_init(&rq);
    wiiauto_send_event(1, &rq, sizeof(rq), SPRINGBOARD_MACH_PORT_NAME, &ref);

    __wiiauto_event_result_springboard_state_fetch(ref, &rt);
    if (rt) {
        *r = rt->state;
        *pid = rt->pid;
    } else {
        *r = WIIAUTO_SPRINGBOARD_STATE_NOT_RUNNING;
        *pid = 0;
    }

    if (ref) {
        CFRelease(ref);
    }

    unlock(&__local_barrier__);
}

void common_undim_display()
{
    __wiiauto_event_undim_display ts; 

    __wiiauto_event_undim_display_init(&ts);
    wiiauto_send_event_uncheck_return(1, &ts, sizeof(ts), SPRINGBOARD_MACH_PORT_NAME);
}

void common_set_gps_location(const double latitude, const double longitude, const double altitude)
{
    json_element e, e_lat, e_long;

    json_element_new(&e);
    json_element_load_file(e, DAEMON_FILE_LOCATION);

    json_element_make_object(e);
    json_object_require_number(e, "latitude", &e_lat);
    json_object_require_number(e, "longitude", &e_long);
    json_number_set(e_lat, latitude);
    json_number_set(e_long, longitude);

    json_element_save_file(e, DAEMON_FILE_LOCATION);

    release(e.iobj);

    // __wiiauto_event_set_gps_location evt;

    // __wiiauto_event_set_gps_location_init(&evt);
    // evt.latitude = latitude;
    // evt.longitude = longitude;
    // evt.altitude = altitude;
    // wiiauto_send_event_uncheck_return(1, &evt, sizeof(evt), SPRINGBOARD_MACH_PORT_NAME);
}

void common_override_gps_location(const u8 v)
{
    json_element e, e_override;

    json_element_new(&e);
    json_element_load_file(e, DAEMON_FILE_LOCATION);

    json_element_make_object(e);
    json_object_require_boolean(e, "override", &e_override);
    json_boolean_set(e_override, v);
    json_element_save_file(e, DAEMON_FILE_LOCATION);

    release(e.iobj);

    // __wiiauto_event_override_gps_location evt;

    // __wiiauto_event_override_gps_location_init(&evt);
    // evt.enable = v;
    // wiiauto_send_event_uncheck_return(1, &evt, sizeof(evt), SPRINGBOARD_MACH_PORT_NAME);
}

void common_is_gps_overrided(u8 *v)
{
    json_element e, e_override, e_lat, e_long;
    f64 latitude, longitude;
    u8 o;

    json_element_new(&e);
    json_element_load_file(e, DAEMON_FILE_LOCATION);

    json_object_require_boolean_default(e, "override", &e_override, 1);
    json_object_require_number(e, "latitude", &e_lat);
    json_object_require_number(e, "longitude", &e_long);
    
    json_number_get(e_lat, &latitude);
    json_number_get(e_long, &longitude);
    json_boolean_get(e_override, &o);

    if (o && (latitude > 0 || longitude > 0)) {
        *v = 1;
    } else {
        *v = 0;
    }

    release(e.iobj);
}

void common_get_gps_location(double *latitude, double *longitude, u8 *overrided)
{
    json_element e, e_lat, e_long, e_override;

    json_element_new(&e);
    json_element_load_file(e, DAEMON_FILE_LOCATION);

    json_object_require_boolean_default(e, "override", &e_override, 1);
    json_object_require_number(e, "latitude", &e_lat);
    json_object_require_number(e, "longitude", &e_long);
    
    json_number_get(e_lat, latitude);
    json_number_get(e_long, longitude);
    json_boolean_get(e_override, overrided);

    release(e.iobj);
}

void common_save_photo(const char *full_path, u8 *success)
{
    static spin_lock __local_barrier__ = SPIN_LOCK_INIT;

    lock(&__local_barrier__);

    CFDataRef ref = NULL;
    __wiiauto_event_request_save_photo rq;
    const __wiiauto_event_result_save_photo *rt;

    __wiiauto_event_request_save_photo_init(&rq);
    strcpy(rq.full_path, full_path);
    wiiauto_send_event(1, &rq, sizeof(rq), SPRINGBOARD_MACH_PORT_NAME, &ref);

    __wiiauto_event_result_save_photo_fetch(ref, &rt);
    *success = rt->result;

    if (ref) {
        CFRelease(ref);
    }

    unlock(&__local_barrier__);
}
#include "touch_screen.h"
#include "wiiauto/device/device.h"
#include "wiiauto/device/device_iohid.h"
#include "cherry/core/map.h"
#include "cherry/math/cmath.h"
#include "log/remote_log.h"
#include <mach/mach_time.h>

/*
 * touch storage
 */
static map touches = {id_null};

static void __touch_screen_in()
{
    if (!id_validate(touches.iobj)) {
        map_new(&touches);
    }
}

static void __attribute__((destructor)) __touch_screen_out()
{
    // release(touches.iobj);
}

/*
 * touch
 */
typedef enum
{
    TOUCH_NONE,
    TOUCH_DOWN,
    TOUCH_MOVE,
    TOUCH_UP,
    TOUCH_CANCEL
}
__touch_type;

local_type(touch);

typedef struct
{
    __touch_type type;
    u8 index;

    float x;
    float y;
}
__touch;

make_local_type(touch, __touch);

static void __touch_init(__touch *__p)
{
    __p->type = TOUCH_NONE;
    __p->index = 0;
    __p->x = 0;
    __p->y = 0;
}

static void __touch_clear(__touch *__p)
{

}

static void __get_touch(const u8 index, touch *p)
{
    __touch_screen_in();

    __touch *__p;

    map_get(touches, key_obj(index), &p->iobj);
    if (!id_validate(p->iobj)) {
        touch_new(p);
        map_set(touches, key_obj(index), p->iobj);
        release(p->iobj);

        touch_fetch(*p, &__p);
        __p->index = index;
    }
}

/*
 * handler
 */

static void springboard_handle_touch_screen_send(const float x, const float y, const uint32_t index, uint32_t parent_flags, uint32_t child_flags, int in_range, int in_touch)
{
    IOHIDEventRef parent = IOHIDEventCreateDigitizerEvent(kCFAllocatorDefault, mach_absolute_time(), kIOHIDDigitizerTransducerTypeHand, 1 << 22, 1, parent_flags, 0, x, y, 0, 0, 0, 0, 0, 0);
    IOHIDEventSetIntegerValue(parent, kIOHIDEventFieldIsBuiltIn, true);
    IOHIDEventSetIntegerValue(parent, kIOHIDEventFieldDigitizerIsDisplayIntegrated, true);

    wiiauto_device_iohid_set_sender_id(parent, 0x8000000817319375);
    IOHIDEventRef child = IOHIDEventCreateDigitizerFingerEvent(kCFAllocatorDefault, mach_absolute_time(), index + 5, index + 5, child_flags, x, y, 0, 0, 0, in_range, in_touch, 0);
    IOHIDEventAppendEvent(parent, child);
    CFRelease(child);

    wiiauto_device_iohid_send(parent);
}

CFDataRef springboard_handle_touch_screen(const __wiiauto_event_touch_screen *input)
{
    float width, height, x, y;
    touch t;
    __touch *__t;

    wiiauto_device_get_screen_size(&width, &height);

    x = input->x;
    y = input->y;

    if (x < 0) {
        x = 0;
    } else if (x >= width) {
        x = width - 1;
    }

    if (y < 0) {
        y = 0;
    } else if (y >= height) {
        y = height - 1;
    }

    __get_touch(input->index, &t);
    touch_fetch(t, &__t);

    switch(input->type) {
        case WIIAUTO_TOUCH_UPDATE:
            goto update;
        case WIIAUTO_TOUCH_EXPIRE:
            goto expire;
        default:
            return NULL;
    }

update:
    switch(__t->type) {
        case TOUCH_NONE:
        case TOUCH_UP:
        case TOUCH_CANCEL:
            __t->type = TOUCH_DOWN;
            __t->x = x;
            __t->y = y;
            springboard_handle_touch_screen_send(
                x / width, y / height,
                __t->index,
                kIOHIDDigitizerEventRange | kIOHIDDigitizerEventTouch | kIOHIDDigitizerEventIdentity,
                kIOHIDDigitizerEventRange | kIOHIDDigitizerEventTouch,
                1,
                1
                );
            break;
        case TOUCH_DOWN:
        case TOUCH_MOVE:
            __t->type = TOUCH_MOVE;   
            __t->x = x;
            __t->y = y;
            springboard_handle_touch_screen_send(
                x / width, y / height,
                __t->index,
                kIOHIDDigitizerEventPosition,
                kIOHIDDigitizerEventPosition,
                1,
                1
                );
            break;
    }
    goto finish;

expire:
    switch(__t->type) {
        case TOUCH_DOWN:
        case TOUCH_MOVE:
            __t->type = TOUCH_UP;
            __t->x = x;
            __t->y = y;
            springboard_handle_touch_screen_send(
                x / width, y / height,
                __t->index,
                kIOHIDDigitizerEventRange | kIOHIDDigitizerEventTouch | kIOHIDDigitizerEventIdentity | kIOHIDDigitizerEventPosition,
                kIOHIDDigitizerEventRange | kIOHIDDigitizerEventTouch,
                0,
                0
                );
            break;
        default:
            break;
    }
    
    // release(t.iobj);
    __t->type = TOUCH_NONE;
    __t->x = 0;
    __t->y = 0;

    goto finish;


finish:
    return NULL;
}
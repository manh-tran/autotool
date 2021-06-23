#include "event.h"
#include "cherry/core/buffer.h"
#include "cherry/core/map.h"
#include "wiiauto/intercom/intercom.h"

local_type(event_delegate);

typedef struct
{
    wiiauto_event_delegate func;
    u32 size;
}
__event_delegate;

make_local_type(event_delegate, __event_delegate);

static void __event_delegate_init(__event_delegate *__p)
{
    __p->func = NULL;
    __p->size = 0;
}

static void __event_delegate_clear(__event_delegate *__p)
{

}

void __wiiauto_add_event_delegate(const map p, const char *type, const u32 size, const wiiauto_event_delegate func)
{
    event_delegate ed;
    __event_delegate *__ed;

    event_delegate_new(&ed);
    event_delegate_fetch(ed, &__ed);
    __ed->func = func;
    __ed->size = size;
    map_set(p, key_str(type), ed.iobj);
    release(ed.iobj);
}

void __wiiauto_get_event_delegate(const map p, const char *type, const u32 in_size, wiiauto_event_delegate *func)
{
    event_delegate ed;
    __event_delegate *__ed;
    
    map_get(p, key_str(type), &ed.iobj);
    if (id_validate(ed.iobj)) {
        event_delegate_fetch(ed, &__ed);
        if (in_size >= __ed->size) {
            *func = __ed->func;
        } else {
            *func = NULL;
        }
    } else {
        *func = NULL;
    }
}

void __wiiauto_event_init(__wiiauto_event *__p, const char *name)
{
    strcpy(__p->name, name);
}

void wiiauto_send_event(const int msgid, const void *ptr, const u32 len, const char *mach_port, CFDataRef *ret)
{
    const __wiiauto_event_null *wen = NULL;

    *ret = wiiauto_intercom_send_unix(mach_port, ptr, len);

    __wiiauto_event_null_fetch(*ret, &wen);
    if (wen) {
        CFRelease(*ret);
        *ret = NULL;
    }
}

void wiiauto_send_event_uncheck_return(const int msgid, const void *ptr, const u32 len, const char *mach_port)
{
    CFDataRef ret = wiiauto_intercom_send_unix(mach_port, ptr, len);
    if (ret) {
        CFRelease(ret);
    }
}


void wiiauto_send_event_local_port(const int msgid, const void *ptr, const u32 len, const int num, const u16 *port, CFDataRef *ret)
{
    const __wiiauto_event_null *wen = NULL;

    *ret = wiiauto_intercom_send_local_port(num, port, ptr, len);

    __wiiauto_event_null_fetch(*ret, &wen);
    if (wen) {
        CFRelease(*ret);
        *ret = NULL;
    }
}

void wiiauto_send_event_local_port_uncheck_return(const int msgid, const void *ptr, const u32 len, const int num, const u16 *port)
{
    CFDataRef ret = wiiauto_intercom_send_local_port(num, port, ptr, len);
    if (ret) {
        CFRelease(ret);
    }
}

make_wiiauto_event(__wiiauto_event_null);

static void __wiiauto_event_null_init_content(__wiiauto_event_null *__p)
{
}
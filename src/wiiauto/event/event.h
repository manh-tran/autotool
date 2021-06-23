#ifndef __wiiauto_event_touch_h
#define __wiiauto_event_touch_h

#if defined __cplusplus
extern "C" {
#endif

#include "cherry/core/map.h"

typedef CFDataRef(*wiiauto_event_delegate)(const void *input);

typedef struct
{
    char name[64];
}
__wiiauto_event;

void __wiiauto_event_init(__wiiauto_event *__p, const char *name);

#define EVENT_CONTENT(...) __VA_ARGS__

#define add_wiiauto_event(name, content) \
    typedef struct {\
        __wiiauto_event head;\
        content\
    }\
    name;\
    void name##_init(name *__p);\
    void name##_get_type(const char **ptr);\
    void name##_fetch(const CFDataRef ref, const name **__p);

#define make_wiiauto_event(we) \
    static void we##_init_content(we *__p);\
    void we##_init(we *__p)\
    {\
        __wiiauto_event_init(&__p->head, #we);\
        we##_init_content(__p);\
    }\
    void we##_get_type(const char **ptr)\
    {\
        *ptr = #we;\
    }\
    void we##_fetch(const CFDataRef ref, const we **__p)\
    {\
        if (!ref) {\
            *__p = NULL;\
            return;\
        }\
        const we *tmp = (const we *) CFDataGetBytePtr(ref);\
        int len = CFDataGetLength(ref);\
        if (len == sizeof(we)) {\
            if (strcmp(tmp->head.name, #we) == 0) {\
                *__p = tmp;\
            } else {\
                *__p = NULL;\
            }\
        } else {\
            *__p = NULL;\
        }\
    }

void __wiiauto_add_event_delegate(const map p, const char *type, const u32 size, const wiiauto_event_delegate func);
void __wiiauto_get_event_delegate(const map p, const char *type, const u32 in_size, wiiauto_event_delegate *func);

#define wiiauto_add_event_delegate(p, name, func) \
    do {\
        const char *type;\
        name##_get_type(&type);\
        __wiiauto_add_event_delegate(p, type, sizeof(name), (wiiauto_event_delegate)func);\
    } while (0);

#define wiiauto_get_event_delegate(p, type, in_size, func) \
    do {\
        __wiiauto_get_event_delegate(p, type, in_size, (wiiauto_event_delegate *)func);\
    } while (0);


void wiiauto_send_event(const int msgid, const void *ptr, const u32 len, const char *mach_port, CFDataRef *ret);
void wiiauto_send_event_uncheck_return(const int msgid, const void *ptr, const u32 len, const char *mach_port);

void wiiauto_send_event_local_port(const int msgid, const void *ptr, const u32 len, const int num, const u16 *port, CFDataRef *ret);
void wiiauto_send_event_local_port_uncheck_return(const int msgid, const void *ptr, const u32 len, const int num, const u16 *port);

add_wiiauto_event(__wiiauto_event_null, EVENT_CONTENT(
    
));

#if defined __cplusplus
}
#endif

#endif
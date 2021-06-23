#include "event_toast.h"

make_wiiauto_event(__wiiauto_event_toast);

static void __wiiauto_event_toast_init_content(__wiiauto_event_toast *__p)
{
    __p->text[0] = '\0';
    __p->complete = 1;
    __p->delay = 2;
}  
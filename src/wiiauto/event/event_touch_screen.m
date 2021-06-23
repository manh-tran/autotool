#include "event_touch_screen.h"

make_wiiauto_event(__wiiauto_event_touch_screen);

static void __wiiauto_event_touch_screen_init_content(__wiiauto_event_touch_screen *__p)
{
    __p->type = WIIAUTO_TOUCH_UPDATE;
    __p->index = 0;
    __p->x = 0;
    __p->y = 0;
}  
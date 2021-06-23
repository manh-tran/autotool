#include "event_timer.h"

make_wiiauto_event(__wiiauto_event_set_timer);

static void __wiiauto_event_set_timer_init_content(__wiiauto_event_set_timer *__p)
{
    __p->url[0] = '\0';
    __p->fire_time = 0;
    __p->repeat =  0;
    __p->interval = 0;
}  

make_wiiauto_event(__wiiauto_event_remove_timer);

static void __wiiauto_event_remove_timer_init_content(__wiiauto_event_remove_timer *__p)
{
    __p->url[0] = '\0';
}  
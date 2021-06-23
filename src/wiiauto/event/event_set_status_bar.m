#include "event_set_status_bar.h"

make_wiiauto_event(__wiiauto_event_set_status_bar);

static void __wiiauto_event_set_status_bar_init_content(__wiiauto_event_set_status_bar *__p)
{
    __p->text[0] = '\0';
    __p->complete = 1;
}  

make_wiiauto_event(__wiiauto_event_set_status_bar_state);

static void __wiiauto_event_set_status_bar_state_init_content(__wiiauto_event_set_status_bar_state *__p)
{
    __p->visible = 1;
}  
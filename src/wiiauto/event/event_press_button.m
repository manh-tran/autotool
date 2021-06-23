#include "event_press_button.h"

make_wiiauto_event(__wiiauto_event_press_button);

static void __wiiauto_event_press_button_init_content(__wiiauto_event_press_button *__p)
{
    __p->down = 1;
    __p->type = 0;
}  
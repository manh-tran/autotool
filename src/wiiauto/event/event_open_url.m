#include "event_open_url.h"

make_wiiauto_event(__wiiauto_event_open_url);

static void __wiiauto_event_open_url_init_content(__wiiauto_event_open_url *__p)
{
    __p->text[0] = '\0';
    __p->complete = 1;
}  
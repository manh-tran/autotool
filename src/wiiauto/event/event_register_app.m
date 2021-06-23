#include "event_register_app.h"

make_wiiauto_event(__wiiauto_event_register_app);

static void __wiiauto_event_register_app_init_content(__wiiauto_event_register_app *__p)
{
    __p->bundle[0] = '\0';
}  
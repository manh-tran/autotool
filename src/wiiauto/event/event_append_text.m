#include "event_append_text.h"

make_wiiauto_event(__wiiauto_event_append_text);

static void __wiiauto_event_append_text_init_content(__wiiauto_event_append_text *__p)
{
    __p->text[0] = '\0';
    __p->complete = 1;
}  
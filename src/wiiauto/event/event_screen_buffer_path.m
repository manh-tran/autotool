#include "event_screen_buffer_path.h"

/*
 * request
 */
make_wiiauto_event(__wiiauto_event_request_screen_buffer_path);

static void __wiiauto_event_request_screen_buffer_path_init_content(__wiiauto_event_request_screen_buffer_path *__p)
{
}  

/*
 * result
 */
make_wiiauto_event(__wiiauto_event_result_screen_buffer_path);

static void __wiiauto_event_result_screen_buffer_path_init_content(__wiiauto_event_result_screen_buffer_path *__p)
{
    __p->path[0] = '\0';
    __p->timestamp = 0;
}
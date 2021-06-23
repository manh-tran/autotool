#include "event_save_photo.h"

/*
 * request
 */
make_wiiauto_event(__wiiauto_event_request_save_photo);

static void __wiiauto_event_request_save_photo_init_content(__wiiauto_event_request_save_photo *__p)
{
    __p->full_path[0] = '\0';
}  

/*
 * result
 */
make_wiiauto_event(__wiiauto_event_result_save_photo);

static void __wiiauto_event_result_save_photo_init_content(__wiiauto_event_result_save_photo *__p)
{
    __p->result = 0;
}
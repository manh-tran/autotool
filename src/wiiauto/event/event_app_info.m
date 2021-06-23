#include "event_app_info.h"

/*
 * request
 */
make_wiiauto_event(__wiiauto_event_request_app_info);

static void __wiiauto_event_request_app_info_init_content(__wiiauto_event_request_app_info *__p)
{
    __p->bundle[0] = '\0';
}  

/*
 * result
 */
make_wiiauto_event(__wiiauto_event_result_app_info);

static void __wiiauto_event_result_app_info_init_content(__wiiauto_event_result_app_info *__p)
{
    __p->data_container_path[0] = '\0';
    __p->display_name[0] = '\0';
    __p->bundle_container_path[0] = '\0';
    __p->executable_path[0] = '\0';
}
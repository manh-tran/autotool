#include "event_front_most_app_bundle.h"

/*
 * request
 */
make_wiiauto_event(__wiiauto_event_request_front_most_app_bundle);

static void __wiiauto_event_request_front_most_app_bundle_init_content(__wiiauto_event_request_front_most_app_bundle *__p)
{
}  

/*
 * result
 */
make_wiiauto_event(__wiiauto_event_result_front_most_app_bundle);

static void __wiiauto_event_result_front_most_app_bundle_init_content(__wiiauto_event_result_front_most_app_bundle *__p)
{
    __p->bundle[0] = '\0';
}
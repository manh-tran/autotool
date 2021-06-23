#include "event_front_most_app_orientation.h"
#include "wiiauto/device/device.h"

/*
 * request
 */
make_wiiauto_event(__wiiauto_event_request_front_most_app_orientation);

static void __wiiauto_event_request_front_most_app_orientation_init_content(__wiiauto_event_request_front_most_app_orientation *__p)
{
}  

/*
 * result
 */
make_wiiauto_event(__wiiauto_event_result_front_most_app_orientation);

static void __wiiauto_event_result_front_most_app_orientation_init_content(__wiiauto_event_result_front_most_app_orientation *__p)
{
    __p->orientation = WIIAUTO_DEVICE_ORIENTATION_UNKNOWN;
}
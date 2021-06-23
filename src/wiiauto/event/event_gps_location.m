#include "event_gps_location.h"

make_wiiauto_event(__wiiauto_event_set_gps_location);

static void __wiiauto_event_set_gps_location_init_content(__wiiauto_event_set_gps_location *__p)
{
    __p->latitude = 0;
    __p->longitude = 0;
    __p->altitude = 0;
}  

make_wiiauto_event(__wiiauto_event_request_gps_location);

static void __wiiauto_event_request_gps_location_init_content(__wiiauto_event_request_gps_location *__p)
{
}  

make_wiiauto_event(__wiiauto_event_result_gps_location);

static void __wiiauto_event_result_gps_location_init_content(__wiiauto_event_result_gps_location *__p)
{
    __p->latitude = 0;
    __p->longitude = 0;
    __p->altitude = 0;
    __p->replace = 0;
    __p->enable = 1;
}  

make_wiiauto_event(__wiiauto_event_override_gps_location);

static void __wiiauto_event_override_gps_location_init_content(__wiiauto_event_override_gps_location *__p)
{
    __p->enable = 1;
}  
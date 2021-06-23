#include "gps_location.h"

static double __latitude__ = 0;
static double __longitude__ = 0;
static double __altitude__ = 0;
static char __set__ = 0;
static char __override__ = 1;

CFDataRef springboard_handle_set_gps_location(const __wiiauto_event_set_gps_location *input)
{
    __latitude__ = input->latitude;
    __longitude__ = input->longitude;
    __altitude__ = input->altitude;
    __set__ = 1;
    return NULL;
}

CFDataRef springboard_handle_request_gps_location(const __wiiauto_event_request_gps_location *input)
{
    __wiiauto_event_result_gps_location rt;

    __wiiauto_event_result_gps_location_init(&rt);
    rt.latitude = __latitude__;
    rt.longitude = __longitude__;
    rt.altitude = __altitude__;
    rt.replace = __set__;
    rt.enable = __override__;

    return CFDataCreate(NULL, (const UInt8 *)&rt, sizeof(rt));
}

CFDataRef springboard_handle_override_gps_location(const __wiiauto_event_override_gps_location *input)
{
    __override__ = input->enable;
    return NULL;
}
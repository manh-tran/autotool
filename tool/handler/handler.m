#include "handler.h"
#include "wiiauto/file/file.h"
#include "wiiauto/device/device.h"

void wiiauto_tool_register()
{
    file_register_global_url_parser(wiiauto_parse_url);
    wiiauto_device_init();
    wiiauto_device_register_app_orientation_notification();
}
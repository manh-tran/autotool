#ifndef __wiiauto_event_execute_lua_script_h
#define __wiiauto_event_execute_lua_script_h

#include "event.h"

#if defined __cplusplus
extern "C" {
#endif

add_wiiauto_event(__wiiauto_event_execute_lua_script, EVENT_CONTENT(

    char url[256];

));

#if defined __cplusplus
}
#endif

#endif
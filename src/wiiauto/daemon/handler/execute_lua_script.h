#ifndef __wiiauto_daemon_handler_execute_lua_script_h
#define __wiiauto_daemon_handler_execute_lua_script_h

#if defined __cplusplus
extern "C" {
#endif

#include "wiiauto/event/event_execute_lua_script.h"

CFDataRef daemon_handle_execute_lua_script(const __wiiauto_event_execute_lua_script *input);

#if defined __cplusplus
}
#endif

#endif
#include "execute_lua_script.h"
#include "log/remote_log.h"
#include "wiiauto/lua/lua.h"

CFDataRef daemon_handle_execute_lua_script(const __wiiauto_event_execute_lua_script *input)
{
    if (input->url[0] == '/') {
        wiiauto_lua_execute_file(input->url, 0, NULL, NULL, NULL);
    }
    return NULL;
}
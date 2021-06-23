#include "cherry/core/map.h"
#include "cherry/core/buffer.h"
#include "handler/set_timer.h"
#include "handler/execute_lua_script.h"
#include "handler/request_daemon_state.h"

static map delegates = {id_null};

static void __daemon_in()
{
    if (id_validate(delegates.iobj)) return;

    map_new(&delegates);

    wiiauto_add_event_delegate(delegates, __wiiauto_event_execute_lua_script, daemon_handle_execute_lua_script);
    wiiauto_add_event_delegate(delegates, __wiiauto_event_set_timer, daemon_handle_set_timer);
    wiiauto_add_event_delegate(delegates, __wiiauto_event_remove_timer, daemon_handle_remove_timer);
    wiiauto_add_event_delegate(delegates, __wiiauto_event_request_daemon_state, daemon_handle_request_daemon_state);
}

static void __attribute__((destructor)) __daemon_out()
{
    // release(delegates.iobj);
}

void daemon_get_handler(const __wiiauto_event *data, const u32 in_size, wiiauto_event_delegate *del)
{
     __daemon_in();
    wiiauto_get_event_delegate(delegates, data->name, in_size, del);
}
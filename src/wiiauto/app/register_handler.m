// #include "cherry/core/map.h"
// #include "cherry/core/buffer.h"
// #include "handler/request_front_most_app_orientation.h"
// #include "handler/request_app_state.h"

// static map delegates = {id_null};

// static void __app_in()
// {
//     if (id_validate(delegates.iobj)) return;

//     map_new(&delegates);

//     wiiauto_add_event_delegate(delegates, __wiiauto_event_request_front_most_app_orientation, app_handle_request_front_most_app_orientation);
//     wiiauto_add_event_delegate(delegates, __wiiauto_event_request_app_state, app_handle_request_app_state);
// }

// static void __attribute__((destructor)) __app_out()
// {
//     // release(delegates.iobj);
// }

// void app_get_handler(const __wiiauto_event *data, wiiauto_event_delegate *del)
// {
//     __app_in();
    
//     wiiauto_get_event_delegate(delegates, data->name, del);
// }
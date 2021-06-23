// #include "cherry/core/map.h"
// #include "cherry/core/buffer.h"
// #include "handler/request_front_most_app_port.h"
// #include "handler/append_text.h"

// static map delegates = {id_null};

// static void __backboardd_in()
// {
//     if (id_validate(delegates.iobj)) return;
    
//     map_new(&delegates);

//     wiiauto_add_event_delegate(delegates, __wiiauto_event_request_front_most_app_port, backboardd_handle_request_front_most_app_port);
//     // wiiauto_add_event_delegate(delegates, __wiiauto_event_append_text, backboardd_handle_append_text);
// }

// static void __attribute__((destructor)) __backboardd_out()
// {
//     // release(delegates.iobj);
// }

// void backboardd_get_handler(const __wiiauto_event *data, wiiauto_event_delegate *del)
// {
//     __backboardd_in();

//     wiiauto_get_event_delegate(delegates, data->name, del);
// }
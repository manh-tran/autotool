#include "api.h"
#include "wiiauto/device/device.h"
#include "wiiauto/event/event_alert.h"
#include "wiiauto/springboard/springboard.h"
#include "wiiauto/daemon/daemon.h"
#include "cherry/json/json.h"

#include <sys/time.h>

static u64 __current_timestamp() 
{
    struct timeval te; 
    gettimeofday(&te, NULL);
    u64 milliseconds = te.tv_sec*1000LL + te.tv_usec/1000;
    return milliseconds;
}

// int wiiauto_lua_has_alert(lua_State *ls)
// {
//     json_element e, e_time, e_labels, e_title, e_buttons, e_label, e_x, e_y;
//     f64 t, x, y, top;
//     u64 cm;
//     const char *ptr;
//     i32 index;

//     cm = __current_timestamp();

//     json_element_new(&e);
//     json_element_load_file(e, DAEMON_FILE_ALERT_SPRINGBOARD);

//     json_object_require_number(e, "time", &e_time);
//     json_number_get(e_time, &t);

//     if (cm - (u64)t >= 1000) {
//         release(e.iobj);

//         json_element_new(&e);
//         json_element_load_file(e, DAEMON_FILE_ALERT_APP);

//         json_object_require_number(e, "time", &e_time);
//         json_number_get(e_time, &t);

//         if (cm - (u64)t >= 1000) {
//             release(e.iobj);
//             lua_pushnil(ls);
//             goto finish;
//         }
//     }

//     lua_newtable(ls);

//     json_object_require_string(e, "title", &e_title);
// 	json_object_require_array(e, "labels", &e_labels);
// 	json_object_require_array(e, "buttons", &e_buttons);

//     json_string_get_ptr(e_title, &ptr);
//     if (ptr && strlen(ptr) > 0) {
//         lua_pushstring(ls, ptr);
//         lua_setfield(ls, -2, "title");
//     } else {
//         top = 99999;

//         index = 0;        
//         json_array_get(e_labels, index, &e_label);
//         ptr = NULL;
//         while (id_validate(e_label.iobj)) {

//             json_object_require_string(e_label, "title", &e_title);
//             json_object_require_number(e_label, "x", &e_x);
//             json_object_require_number(e_label, "y", &e_y);

//             json_number_get(e_y, &y);
//             if (y <= top) {
//                 top = y;
//                 json_string_get_ptr(e_title, &ptr);
//             }

//             index++;
//             json_array_get(e_labels, index, &e_label);
//         }

//         if (ptr) {
//             lua_pushstring(ls, ptr);
//             lua_setfield(ls, -2, "title");
//         } else {
//             lua_pushstring(ls, "");
//             lua_setfield(ls, -2, "title");
//         }
//     }

//     {
//         lua_newtable(ls);

//         index = 0;        
//         json_array_get(e_labels, index, &e_label);
//         ptr = NULL;
//         while (id_validate(e_label.iobj)) {

//             json_object_require_string(e_label, "title", &e_title);
//             json_object_require_number(e_label, "x", &e_x);
//             json_object_require_number(e_label, "y", &e_y);

//             json_string_get_ptr(e_title, &ptr);
//             json_number_get(e_x, &x);
//             json_number_get(e_y, &y);

//             lua_newtable(ls);

//             lua_pushstring(ls, ptr);
//             lua_setfield(ls, -2, "title");

//             lua_pushnumber(ls, x);
//             lua_setfield(ls, -2, "x");

//             lua_pushnumber(ls, y);
//             lua_setfield(ls, -2, "y");

//             lua_rawseti(ls, -2, index + 1);

//             index++;
//             json_array_get(e_labels, index, &e_label);
//         }

//         lua_setfield(ls, -2, "labels");   
//     }

//     {
//         lua_newtable(ls);

//         index = 0;        
//         json_array_get(e_buttons, index, &e_label);
//         ptr = NULL;
//         while (id_validate(e_label.iobj)) {

//             json_object_require_string(e_label, "title", &e_title);
//             json_object_require_number(e_label, "x", &e_x);
//             json_object_require_number(e_label, "y", &e_y);

//             json_string_get_ptr(e_title, &ptr);
//             json_number_get(e_x, &x);
//             json_number_get(e_y, &y);

//             lua_newtable(ls);

//             lua_pushstring(ls, ptr);
//             lua_setfield(ls, -2, "title");

//             lua_pushnumber(ls, x);
//             lua_setfield(ls, -2, "x");

//             lua_pushnumber(ls, y);
//             lua_setfield(ls, -2, "y");

//             lua_rawseti(ls, -2, index + 1);

//             index++;
//             json_array_get(e_buttons, index, &e_label);
//         }

//         lua_setfield(ls, -2, "buttons");   
//     }

// finish:
//     release(e.iobj);

//     return 1;
// }

int wiiauto_lua_has_alert(lua_State *ls)
{
    i32 i;
    int priority = -1;

    {
        __wiiauto_event_alert_request_has_alert evt;
        __wiiauto_event_alert_request_has_alert_init(&evt);

        CFDataRef ref;
        const __wiiauto_event_alert_result_has_alert *rt;

        wiiauto_send_event(1, &evt, sizeof(evt), SPRINGBOARD_MACH_PORT_NAME, &ref);
        __wiiauto_event_alert_result_has_alert_fetch(ref, &rt);

        if (rt) {
            priority = rt->priority;
        }

        if (ref) {
            CFRelease(ref);
        }
    }

    if (priority >= 0) {
        
        lua_newtable(ls);
        {
            __wiiauto_event_alert_request_title evt;
            __wiiauto_event_alert_request_title_init(&evt);
            evt.priority = priority;

            CFDataRef ref;
            const __wiiauto_event_alert_result_title *rt;

            wiiauto_send_event(1, &evt, sizeof(evt), SPRINGBOARD_MACH_PORT_NAME, &ref);
            __wiiauto_event_alert_result_title_fetch(ref, &rt);

            if (rt) {
                lua_pushstring(ls, rt->title);
                lua_setfield(ls, -2, "title");
            }

            if (ref) {
                CFRelease(ref);
            }
        }

        {
            __wiiauto_event_alert_request_action rq;
            __wiiauto_event_alert_request_action_init(&rq);
            rq.priority = priority;
            
            lua_newtable(ls);

            CFDataRef ref;
            const __wiiauto_event_alert_result_action *rt;

            for (i = 0; ;++i) {
                rq.index = i;

                ref = NULL;
                wiiauto_send_event(1, &rq, sizeof(rq), SPRINGBOARD_MACH_PORT_NAME, &ref);

                __wiiauto_event_alert_result_action_fetch(ref, &rt);

                if (rt && rt->success) {

                    lua_newtable(ls);

                    lua_pushstring(ls, rt->title);
                    lua_setfield(ls, -2, "title");

                    lua_pushnumber(ls, rt->x);
                    lua_setfield(ls, -2, "x");

                    lua_pushnumber(ls, rt->y);
                    lua_setfield(ls, -2, "y");

                    lua_rawseti(ls, -2, i + 1);
                }
            
                if (!rt || !rt->success) {
                    if (ref) {
                        CFRelease(ref);
                    }
                    break;
                }
                if (ref) {
                    CFRelease(ref);
                }
            }

            lua_setfield(ls, -2, "buttons");   
        }

        {
            __wiiauto_event_alert_request_label rq;
            __wiiauto_event_alert_request_label_init(&rq);
            rq.priority = priority;
            
            lua_newtable(ls);

            CFDataRef ref;
            const __wiiauto_event_alert_result_label *rt;

            for (i = 0; ;++i) {
                rq.index = i;

                ref = NULL;
                wiiauto_send_event(1, &rq, sizeof(rq), SPRINGBOARD_MACH_PORT_NAME, &ref);

                __wiiauto_event_alert_result_label_fetch(ref, &rt);

                if (rt && rt->success) {

                    lua_newtable(ls);

                    lua_pushstring(ls, rt->title);
                    lua_setfield(ls, -2, "text");

                    lua_pushnumber(ls, rt->x);
                    lua_setfield(ls, -2, "x");

                    lua_pushnumber(ls, rt->y);
                    lua_setfield(ls, -2, "y");

                    lua_rawseti(ls, -2, i + 1);
                }                

                if (!rt || !rt->success) {
                    if (ref) {
                        CFRelease(ref);
                    }
                    break;
                }
                if (ref) {
                    CFRelease(ref);
                }
            }

            lua_setfield(ls, -2, "labels");   
        }

    } else {
        lua_pushnil(ls);
    }

    return 1;
}
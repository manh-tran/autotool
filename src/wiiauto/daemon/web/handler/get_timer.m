#include "handler.h"
#include "wiiauto/common/common.h"
#include "wiiauto/lua/lua.h"
#include "wiiauto/daemon/preference/preference.h"
#include "cherry/json/json.h"

static const char *ok_200 = "HTTP/1.1 200 OK\r\n\r\n";

void wiiauto_daemon_web_service_handle_get_timer(const wiiauto_daemon_web_service service, const net_socket server, const net_socket sock, const wiiauto_daemon_web_url url, const buffer current_read)
{
    const char *ptr;
    buffer b, str;
    i32 ret;

    buffer_new(&b);
    buffer_new(&str);

    buffer_append(str, ok_200, strlen(ok_200));

    {
        wiiauto_preference pref;
        i32 i;
        const char *url;
        time_t fire_time;
        u8 repeat;
        i32 interval;
        u8 enable;
        buffer buf;
        json_element obj_root;
        json_element obj_timer;
        json_element obj_elem;
        json_element obj_tmp;

        json_element_new(&obj_root);
        json_element_make_object(obj_root);

        json_object_require_object(obj_root, "timer", &obj_timer);

        wiiauto_daemon_preference_get("/timer.db", &pref);

        i = 0;
        wiiauto_preference_iterate_timer(pref, i, &url, &fire_time, &repeat, &interval, &enable);
        while (url) {

            json_object_require_object(obj_timer, url, &obj_elem);

            json_object_require_number(obj_elem, "fire_time", &obj_tmp);
            json_number_set(obj_tmp, fire_time);

            json_object_require_boolean(obj_elem, "repeat", &obj_tmp);
            json_boolean_set(obj_tmp, repeat);

            json_object_require_number(obj_elem, "interval", &obj_tmp);
            json_number_set(obj_tmp, interval);

            json_object_require_boolean(obj_elem, "enable", &obj_tmp);
            json_boolean_set(obj_tmp, enable);
            
            free(url);
            i++;
            wiiauto_preference_iterate_timer(pref, i, &url, &fire_time, &repeat, &interval, &enable);
        }

        buffer_new(&buf);
        json_element_to_string(obj_root, buf);
        buffer_get_ptr(buf, &ptr);

        buffer_append(str, ptr, strlen(ptr));

        release(obj_root.iobj);
        release(buf.iobj);
    }

    // common_get_internal_url("/timer.db", b);
    // buffer_get_ptr(b, &ptr);

    // buffer_append_file(str, ptr);

    buffer_get_ptr(str, &ptr);
    net_socket_send(server, sock, ptr, strlen(ptr), &ret);    
    net_socket_close(server, sock);

    release(str.iobj);
    release(b.iobj);
}
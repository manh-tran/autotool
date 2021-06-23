#include "handler.h"
#include "wiiauto/common/common.h"
#include "wiiauto/lua/lua.h"
#include "wiiauto/daemon/daemon.h"
#include "cherry/json/json.h"

static const char *ok_200 = "HTTP/1.1 200 OK\r\n\r\n";

void wiiauto_daemon_web_service_handle_auto_awake(const wiiauto_daemon_web_service service, const net_socket server, const net_socket sock, const wiiauto_daemon_web_url url, const buffer current_read)
{
    buffer str, b;
    const char *ptr;
    i32 ret;
    u8 fullpath = 0;

    buffer_new(&b);
    buffer_new(&str);
    buffer_append(str, ok_200, strlen(ok_200));

    wiiauto_daemon_web_url_get_param(url, "enable", &ptr);
    if (ptr) {
        if (strcmp(ptr, "true") == 0) {
            buffer_append(str, "enable auto_awake", strlen("enable auto_awake"));
            __daemon_auto_awake__ = 1;
        } else {
            buffer_append(str, "disable auto_awake", strlen("disable auto_awake"));
            __daemon_auto_awake__ = 0;
        }

        {
            json_element e, e_awake;
            json_element_new(&e);
            json_element_load_file(e, DAEMON_FILE_CONFIG);
            json_object_require_boolean_default(e, "awake", &e_awake, 1);
            json_boolean_set(e_awake, __daemon_auto_awake__);
            json_element_save_file(e, DAEMON_FILE_CONFIG);

            release(e.iobj);
        }
    }

    buffer_append(str, "\r\n\r\n", sizeof("\r\n\r\n") - 1);    

    buffer_get_ptr(str, &ptr);
    net_socket_send(server, sock, ptr, strlen(ptr), &ret);
    release(str.iobj);
    net_socket_close(server, sock);
    release(b.iobj);
}
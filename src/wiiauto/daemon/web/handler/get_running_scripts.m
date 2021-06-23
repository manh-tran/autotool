#include "handler.h"
#include "wiiauto/lua/lua.h"

static const char *ok_200 = "HTTP/1.1 200 OK\r\n\r\n";
static const char *test_content = "[\"/a/b/c/d/e.lua\",\"/A/B/C/D/E.lua\"]";

void wiiauto_daemon_web_service_handle_get_running_scripts(const wiiauto_daemon_web_service service, const net_socket server, const net_socket sock, const wiiauto_daemon_web_url url, const buffer current_read)
{
    buffer str, b;
    const char *ptr;
    i32 ret;
    u8 fullpath = 0;
    u8 test = 0;

    buffer_new(&b);
    buffer_new(&str);
    buffer_append(str, ok_200, strlen(ok_200));

    wiiauto_daemon_web_url_get_param(url, "fullpath", &ptr);
    if (ptr) {
        if (strcmp(ptr, "true") == 0) {
            fullpath = 1;
        }
    }

    wiiauto_daemon_web_url_get_param(url, "test", &ptr);
    if (ptr) {
        if (strcmp(ptr, "true") == 0) {
            test = 1;
        }
    }

    if (!test) {
        wiiauto_lua_get_json_string_running_scripts(b, fullpath);
        buffer_get_ptr(b, &ptr);
        buffer_append(str, ptr, strlen(ptr));
    } else {
        buffer_append(str, test_content, strlen(test_content));
    }

    buffer_append(str, "\r\n\r\n", sizeof("\r\n\r\n") - 1);    

    buffer_get_ptr(str, &ptr);
    net_socket_send(server, sock, ptr, strlen(ptr), &ret);
    release(str.iobj);
    net_socket_close(server, sock);
    release(b.iobj);
}
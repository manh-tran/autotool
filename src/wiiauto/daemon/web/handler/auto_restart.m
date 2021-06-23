#include "handler.h"
#include "wiiauto/common/common.h"
#include "wiiauto/lua/lua.h"
#include "wiiauto/daemon/daemon.h"

void wiiauto_daemon_set_timer_enable(const char *__url, const u8 enable);

static const char *ok_200 = "HTTP/1.1 200 OK\r\n\r\n";

void wiiauto_daemon_web_service_handle_auto_restart(const wiiauto_daemon_web_service service, const net_socket server, const net_socket sock, const wiiauto_daemon_web_url url, const buffer current_read)
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
            buffer_append(str, "enable auto_restart", strlen("enable auto_restart"));
            __daemon_auto_restart__ = 1;
        } else {
            buffer_append(str, "disable auto_restart", strlen("disable auto_restart"));
            __daemon_auto_restart__ = 0;
        }
    }

    buffer_append(str, "\r\n\r\n", sizeof("\r\n\r\n") - 1);    

    buffer_get_ptr(str, &ptr);
    net_socket_send(server, sock, ptr, strlen(ptr), &ret);
    release(str.iobj);
    net_socket_close(server, sock);
    release(b.iobj);
}
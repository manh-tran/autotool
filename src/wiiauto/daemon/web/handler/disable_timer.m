#include "handler.h"
#include "wiiauto/common/common.h"
#include "wiiauto/lua/lua.h"

void wiiauto_daemon_set_timer_enable(const char *__url, const u8 enable);

static const char *ok_200 = "HTTP/1.1 200 OK\r\n\r\n";

void wiiauto_daemon_web_service_handle_disable_timer(const wiiauto_daemon_web_service service, const net_socket server, const net_socket sock, const wiiauto_daemon_web_url url, const buffer current_read)
{
    buffer str;
    const char *ptr;
    i32 ret;
    buffer scr;
    char buf[1024];

    buffer_new(&scr);
    buffer_new(&str);
    buffer_append(str, ok_200, strlen(ok_200));

    wiiauto_daemon_web_url_get_param(url, "path", &ptr);
    if (ptr) {
        common_get_script_url(ptr, scr);
        buffer_get_ptr(scr, &ptr);   

        wiiauto_daemon_set_timer_enable(ptr, 0);

        sprintf(buf, "enable timer : path=%s", ptr);
        buffer_append(str, buf, strlen(buf));
    } else {
        buffer_append(str, "wrong input", strlen("wrong input"));   
    }

    buffer_append(str, "\r\n\r\n", sizeof("\r\n\r\n") - 1);    

    buffer_get_ptr(str, &ptr);
    net_socket_send(server, sock, ptr, strlen(ptr), &ret);
    release(str.iobj);
    net_socket_close(server, sock);
    release(scr.iobj);
}
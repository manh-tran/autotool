#include "handler.h"
#include "wiiauto/device/device.h"

static const char *ok_200 = "HTTP/1.1 200 OK\r\n\r\n";

void wiiauto_daemon_web_service_handle_config(const wiiauto_daemon_web_service service, const net_socket server, const net_socket sock, const wiiauto_daemon_web_url url, const buffer current_read)
{
    buffer str;
    const char *ptr;
    i32 ret;
    char buf[1024];

    buffer_new(&str);
    buffer_append(str, ok_200, strlen(ok_200));

    wiiauto_daemon_web_url_get_param(url, "toast", &ptr);
    if (ptr) {
        if (strcmp(ptr, "true") == 0) {
            wiiauto_device_set_toast(1);
            sprintf(buf, "enable_toast\n");
        } else {
            wiiauto_device_set_toast(0);
            sprintf(buf, "disable_toast\n");
        }
        buffer_append(str, buf, strlen(buf));
    }

    wiiauto_daemon_web_url_get_param(url, "log", &ptr);
    if (ptr) {
        if (strcmp(ptr, "true") == 0) {
            wiiauto_device_set_log(1);
            sprintf(buf, "enable_log\n");
        } else {
            wiiauto_device_set_log(0);
            sprintf(buf, "disable_log\n");
        }
        buffer_append(str, buf, strlen(buf));
    }

    sprintf(buf, "done.\n");
    buffer_append(str, buf, strlen(buf));

    buffer_append(str, "\r\n\r\n", sizeof("\r\n\r\n") - 1);    

    buffer_get_ptr(str, &ptr);
    net_socket_send(server, sock, ptr, strlen(ptr), &ret);
    release(str.iobj);
    net_socket_close(server, sock);
}
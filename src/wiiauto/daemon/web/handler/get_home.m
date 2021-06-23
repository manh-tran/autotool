#include "handler.h"
#include "wiiauto/file/file.h"

static const char *ok_200 = "HTTP/1.1 200 OK\r\n\r\n";

#define HTML_INDEX "http/client/home/index.html"

void wiiauto_daemon_web_service_handle_get_home(const wiiauto_daemon_web_service service, const net_socket server, const net_socket sock, const wiiauto_daemon_web_url url, const buffer current_read)
{
    buffer b, str;
    const char *ptr;
    i32 ret;

    buffer_new(&b);
    buffer_append(b, WIIAUTO_RESOURCE_URL, sizeof(WIIAUTO_RESOURCE_URL) - 1);
    buffer_append(b, HTML_INDEX, sizeof(HTML_INDEX) - 1);
    buffer_get_ptr(b, &ptr);

    buffer_new(&str);
    buffer_append(str, ok_200, strlen(ok_200));
    buffer_append_file(str, ptr);
    buffer_append(str, "\r\n\r\n", sizeof("\r\n\r\n") - 1);    

    buffer_get_ptr(str, &ptr);

    net_socket_send(server, sock, ptr, strlen(ptr), &ret);

    release(b.iobj);
    release(str.iobj);

    net_socket_close(server, sock);
}
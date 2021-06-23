#include "handler.h"
#include "wiiauto/common/common.h"
#include "wiiauto/lua/lua.h"
#include <sys/time.h>

static const char *ok_200 = "HTTP/1.1 200 OK\r\n\r\n";

static u64 current_timestamp() 
{
    struct timeval te; 
    gettimeofday(&te, NULL);
    u64 milliseconds = te.tv_sec*1000LL + te.tv_usec/1000;
    return milliseconds;
}

void wiiauto_daemon_web_service_handle_request_hotspot_delay(const wiiauto_daemon_web_service service, const net_socket server, const net_socket sock, const wiiauto_daemon_web_url url, const buffer current_read)
{
    static spin_lock __barrier__ = SPIN_LOCK_INIT;
    static u64 __last_time__ = 0;

    buffer str;
    const char *ptr;
    i32 ret;
    buffer scr;
    char buf[1024];

    buffer_new(&scr);
    buffer_new(&str);
    buffer_append(str, ok_200, strlen(ok_200));

    lock(&__barrier__);
    u64 cm = current_timestamp();
    if (cm - __last_time__ >= 20000) {
        __last_time__ = cm;
        buffer_append(str, "true", strlen("true"));
    } else {
        buffer_append(str, "false", strlen("false"));
    }

    unlock(&__barrier__);

    buffer_append(str, "\r\n\r\n", sizeof("\r\n\r\n") - 1);    

    buffer_get_ptr(str, &ptr);
    net_socket_send(server, sock, ptr, strlen(ptr), &ret);
    release(str.iobj);
    net_socket_close(server, sock);
    release(scr.iobj);
}
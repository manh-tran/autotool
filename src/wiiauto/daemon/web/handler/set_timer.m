#include "handler.h"
#include "wiiauto/common/common.h"
#include "wiiauto/lua/lua.h"
#include "cherry/util/util.h"
#include "wiiauto/event/event_timer.h"

static const char *ok_200 = "HTTP/1.1 200 OK\r\n\r\n";

void wiiauto_daemon_add_timer_internal(const char *url, const time_t fire_time, const u8 repeat, const i32 interval);

void wiiauto_daemon_web_service_handle_set_timer(const wiiauto_daemon_web_service service, const net_socket server, const net_socket sock, const wiiauto_daemon_web_url url, const buffer current_read)
{
    buffer str, scr;
    const char *ptr, *optr;
    i32 ret;
    time_t t_now, t_i;
    i32 t_off;
    char buf[1024];

    time_t fire_time;
    u8 repeat;
    i32 interval;

    buffer_new(&scr);
    buffer_new(&str);
    buffer_append(str, ok_200, strlen(ok_200));

    util_time(&t_now);
    wiiauto_daemon_web_url_get_param(url, "fire_time", &ptr);
    if (ptr) {
        util_strtovl(1, ptr, &t_off);
    } else {
        t_off = 0;
    }
    t_i = t_now + t_off;
    fire_time = t_i;

    wiiauto_daemon_web_url_get_param(url, "repeat", &ptr);
    if (ptr && strcmp(ptr, "true") == 0) {
        repeat = 1;
    } else {
        repeat = 0;
    }

    wiiauto_daemon_web_url_get_param(url, "interval", &ptr);
    if (ptr) {
        util_strtovl(1, ptr, &t_off);
        if (t_off < 0) {
            t_off = 0;
        }
        interval = t_off;
    } else {
        interval = 0;
    }

    wiiauto_daemon_web_url_get_param(url, "path", &ptr);
    if (ptr) {
        optr = ptr;
        common_get_script_url(ptr, scr);
        buffer_get_ptr(scr, &ptr);   
        
        wiiauto_daemon_add_timer_internal(ptr, fire_time, repeat, interval);
        sprintf(buf, "add new timer: path=%s | fire_time=%lu | repeat=%s | interval=%d", optr, fire_time, repeat ? "true" : "false", interval);
        buffer_append(str, buf, strlen(buf));
    } else {
        sprintf(buf, "%s", "failed to add timer!");
        buffer_append(str, buf, strlen(buf));
    }

    buffer_append(str, "\r\n\r\n", sizeof("\r\n\r\n") - 1);    

    buffer_get_ptr(str, &ptr);
    net_socket_send(server, sock, ptr, strlen(ptr), &ret);
    release(str.iobj);
    net_socket_close(server, sock);
    release(scr.iobj);
}
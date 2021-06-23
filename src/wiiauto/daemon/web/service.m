#include "service.h"
#include "cherry/core/map.h"
#include "cherry/core/buffer.h"

static const char *error_500 = "HTTP/1.1 500 Internal Server Error\r\n\r\n";

typedef struct
{
    map methods;
    spin_lock barrier;
}
__wiiauto_daemon_web_service;

make_type(wiiauto_daemon_web_service, __wiiauto_daemon_web_service);

static void __wiiauto_daemon_web_service_init(__wiiauto_daemon_web_service *__p)
{
    map_new(&__p->methods);
    __p->barrier = SPIN_LOCK_INIT;
}

static void __wiiauto_daemon_web_service_clear(__wiiauto_daemon_web_service *__p)
{
    release(__p->methods.iobj);
}

static void __add(const __wiiauto_daemon_web_service *__p, const char *method, const char *path, const wiiauto_daemon_web_service_handler h)
{
    lock((volatile spin_lock *)&__p->barrier);
    map m;
    buffer b;

    map_get(__p->methods, key_str(method), &m.iobj);
    if (!id_validate(m.iobj)) {
        map_new(&m);
        map_set(__p->methods, key_str(method), m.iobj);
        release(m.iobj);
    }

    buffer_new(&b);
    buffer_append(b, &h, sizeof(h));
    map_set(m, key_str(path), b.iobj);
    release(b.iobj);
    unlock((volatile spin_lock *)&__p->barrier);
}

static void __get(const __wiiauto_daemon_web_service *__p, const char *method, const char *path, wiiauto_daemon_web_service_handler *h)
{
    lock((volatile spin_lock *)&__p->barrier);
    map m;
    buffer b;

    *h = NULL;

    map_get(__p->methods, key_str(method), &m.iobj);
    if (!id_validate(m.iobj)) {
        goto finish;
    }

    map_get(m, key_str(path), &b.iobj);
    if (id_validate(b.iobj)) {
        buffer_get(b, sizeof(wiiauto_daemon_web_service_handler), 0, h);
    }

finish:
    unlock((volatile spin_lock *)&__p->barrier);
}

void wiiauto_daemon_web_service_register_handler(const wiiauto_daemon_web_service p, const char **methods, const char *path, const wiiauto_daemon_web_service_handler h)
{
    __wiiauto_daemon_web_service *__p;
    const char *method;
    i32 i;

    wiiauto_daemon_web_service_fetch(p, &__p);
    assert(__p != NULL);

    for (i = 0; ;i++) {
        method = methods[i];
        if (!method) break;

        __add(__p, method, path, h);
    }
}

void wiiauto_daemon_web_service_process(const wiiauto_daemon_web_service p, const net_socket server, const net_socket sock, const buffer b)
{
    __wiiauto_daemon_web_service *__p;
    wiiauto_daemon_web_url url;
    const char *ptr = NULL, *str = NULL, *path = NULL;
    i32 content_length;
    i32 len;
    i32 r;
    i32 temp;
    wiiauto_daemon_web_service_handler h = NULL;

    wiiauto_daemon_web_service_fetch(p, &__p);
    assert(__p != NULL);

    wiiauto_daemon_web_url_new(&url);

    temp = 0;
    goto check;

try_read:
    buffer_erase(b);
    net_socket_read(sock, b);

check:
    buffer_get_ptr(b, &ptr);
    buffer_length(b, 1, &len);

    if (!ptr || ptr[0] == '\0') {
        // temp++;
        // if (temp < 10) {
        //     usleep(16000);
        //     goto try_read;
        // }

        net_socket_send(server, sock, error_500, strlen(error_500), &r);
        net_socket_close(server, sock);
        goto finish;
    }

    if (strncmp(ptr,  "GET", 3) == 0) {
        wiiauto_daemon_web_url_parse(url, ptr + 3);
        wiiauto_daemon_web_url_get_path(url, &path);
        __get(__p, "GET", path, &h);
    } else if (strncmp(ptr, "POST", 4) == 0) {
        wiiauto_daemon_web_url_parse(url, ptr + 4);
        wiiauto_daemon_web_url_get_path(url, &path);
        __get(__p, "POST", path, &h);
    }

    if (h) {
        h(p, server, sock, url, b);
    } else {
        net_socket_send(server, sock, error_500, strlen(error_500), &r);
        net_socket_close(server, sock);
    }

finish:
    release(url.iobj);
}
#include "intercom.h"
#include "wiiauto/thread/thread.h"
#include "cherry/core/buffer.h"
#include "cherry/net/socket.h"
#include "cherry/core/map.h"
#include "log/remote_log.h"

/*
 * server
 */

static void add_connection(const net_socket server,  const buffer b_callback, const net_socket sock)
{
}

static void read_data(const net_socket server, const buffer b_callback, const net_socket sock)
{
    const char *str, *ptr;
    u32 len, blen;
    buffer buf, content;
    wiiauto_intercom_callback callback;
    __block CFDataRef ref;
    i32 r;
    int length = 0;
    char txt[64];
    char *end;

    buffer_get(b_callback, sizeof(callback), 0, &callback);

    buffer_new(&buf);
    buffer_new(&content);

try_read:
    net_socket_read(sock, buf);
    buffer_length(buf, sizeof(u8), &len);

    if (len > 0) {
        buffer_append_buffer(content, buf);
        buffer_length(content, 1, &blen);

        if (length == 0 && blen >= 5) {
            buffer_get_ptr(content, &ptr);
            length = strtol(ptr, &end, 10);  
        }
        if (length > 0) {
            if (blen - 5 < length) {
                goto try_read;
            }
        } else {
            goto try_read;
        }
    }

    buffer_get_ptr(content, &str);
    buffer_length(content, sizeof(u8), &len);

    if (len <= 5) {
        net_socket_close(server, sock);
        goto finish;
    }

    ref = NULL;

    str += 5;
    len -= 5;

    dispatch_sync(dispatch_get_main_queue() , ^{
		
        CFDataRef data = CFDataCreate(kCFAllocatorDefault, str, len + 1);
        ref = callback(NULL, 1, data, NULL);
        CFRelease(data);

    });

    str = CFDataGetBytePtr(ref);
    len = CFDataGetLength(ref);

    sprintf(txt, "%04d ", len);
    net_socket_send(server, sock, txt, strlen(txt), &r);
    net_socket_send(server, sock, str, len, &r);    

    if (ref) {
        CFRelease(ref);
    }

finish:
    release(buf.iobj);
    release(content.iobj);
}

static void remove_connection(const net_socket server,  const buffer b_callback, const net_socket sock)
{
}

static void __callback(const buffer b_name, const buffer b_callback, const thread_pool pool)
{
    const char *name;
    net_socket server;

roll_back:
    buffer_get_ptr(b_name, &name);

    net_socket_new(&server);
    net_socket_bind_unix(server, name);
    net_socket_run(server, b_callback.iobj, (__net_socket_callback){
        .add_connection = add_connection,
        .read_data = (void(*)(const net_socket, const iobj, const net_socket))read_data,
        .remove_connection = remove_connection
    });
    release(server.iobj);
    usleep(1000000);
    goto roll_back;

    wiiauto_recycle_thread_pool(pool);
}

void wiiauto_intercom_register_unix(const char *name, const wiiauto_intercom_callback callback)
{
    thread_job job;
    thread_pool pool;
    buffer b_name, b_callback;

    buffer_new(&b_name);
    buffer_new(&b_callback);

    buffer_append(b_name, name, strlen(name));
    buffer_append(b_callback, &callback, sizeof(callback));

    wiiauto_get_thread_pool(&pool);

    thread_job_new(&job);
    thread_job_set_callback(job, (thread_job_callback)__callback);
    thread_job_add_arguments(job, b_name.iobj);
    thread_job_add_arguments(job, b_callback.iobj);
    thread_job_add_arguments(job, pool.iobj);
    thread_pool_add_job(pool, job);

    release(job.iobj);
    release(b_name.iobj);
    release(b_callback.iobj);
}

/*
 * client
 */

local_type(client);

typedef struct
{
    net_socket sock;
    spin_lock lock;
}
__client;

make_local_type(client, __client);

static void __client_init(__client *__p)
{
    __p->sock.iobj = id_null;
    __p->lock = SPIN_LOCK_INIT;
}

static void __client_clear(__client *__p)
{
    release(__p->sock.iobj);
}

static map __clients__ = {id_null};
static spin_lock __barrier__ = SPIN_LOCK_INIT;

CFDataRef wiiauto_intercom_send_unix(const char *name, const void *data, const u32 len)
{
    void net_socket_get_descriptor(const net_socket p, int *d);

    client cl;
    __client *__cl;
    int r;
    CFDataRef ret = NULL;
    buffer buf, content;
    u32 blen;
    const void *ptr;
    // int flag;
    int length = 0;
    char txt[64];
    char *end;

    lock(&__barrier__);
    if (!id_validate(__clients__.iobj)) {
        map_new(&__clients__);
    }
    map_get(__clients__, key_str(name), &cl.iobj);
    if (!id_validate(cl.iobj)) {
        client_new(&cl);
        map_set(__clients__, key_str(name), cl.iobj);
        release(cl.iobj);
    }
    unlock(&__barrier__);

    client_fetch(cl, &__cl);

    lock(&__cl->lock);
    if (!id_validate(__cl->sock.iobj)) {
        net_socket_new(&__cl->sock);
        net_socket_connect_unix(__cl->sock, name);
    }

    net_socket_get_descriptor(__cl->sock, &r);
    if (r >= 0) {
        sprintf(txt, "%04d ", len);
        net_socket_send(__cl->sock, __cl->sock, txt, strlen(txt), &r);
        net_socket_send(__cl->sock, __cl->sock, data, len, &r);

        buffer_new(&buf);
        buffer_new(&content);

    try_read:
        net_socket_read(__cl->sock, buf);
        buffer_length(buf, 1 , &blen);

        if (blen > 0) {
            buffer_append_buffer(content, buf);
            buffer_length(content, 1, &blen);
            if (length == 0 && blen >= 5) {
                buffer_get_ptr(content, &ptr);
                length = strtol(ptr, &end, 10);  
            }
            if (length > 0) {
                if (blen - 5 != length) {
                    goto try_read;
                }
            } else {
                goto try_read;
            }
        }

        buffer_length(content, 1 , &blen);
        buffer_get_ptr(content, &ptr);
        if (blen > 5) {
            ptr += 5;
            blen -= 5;
            ret = CFDataCreate(kCFAllocatorDefault, ptr, blen);
        } else {
            release(__cl->sock.iobj);
        }

        release(buf.iobj);
        release(content.iobj);
    } else {
        release(__cl->sock.iobj);
    }
    unlock(&__cl->lock);

    return ret;
}
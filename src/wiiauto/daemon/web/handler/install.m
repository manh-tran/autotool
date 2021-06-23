#include "handler.h"
#include "wiiauto/common/common.h"
#include "wiiauto/lua/lua.h"
#include "cherry/thread/thread.h"
#include "cherry/core/map.h"
#include "wiiauto/thread/thread.h"

static const char *ok_200 = "HTTP/1.1 200 OK\r\n\r\n";

static void __callback(const buffer scr, const thread_pool pool)
{
    const char *ptr;

    buffer_get_ptr(scr, &ptr);   
    wiiauto_lua_execute_file(ptr, 0, NULL, NULL, NULL);

    wiiauto_recycle_thread_pool(pool);
}

void wiiauto_daemon_web_service_handle_install(const wiiauto_daemon_web_service service, const net_socket server, const net_socket sock, const wiiauto_daemon_web_url url, const buffer current_read)
{
    buffer str;
    const char *ptr;
    i32 ret;
    buffer scr;
    thread_pool pool;
    thread_job job;
    char buf[1024];

    buffer_new(&scr);

    buffer_new(&str);
    buffer_append(str, ok_200, strlen(ok_200));

    common_get_script_url("Install.lua", scr);
    wiiauto_get_thread_pool(&pool);
    thread_job_new(&job);
    thread_job_set_callback(job, (thread_job_callback)__callback);
    thread_job_add_arguments(job, scr.iobj);
    thread_job_add_arguments(job, pool.iobj);
    thread_pool_add_job(pool, job);
    release(job.iobj);  

    sprintf(buf, "running script: Install.lua");
    buffer_append(str, buf, strlen(buf));
    buffer_append(str, "\r\n\r\n", sizeof("\r\n\r\n") - 1);    

    buffer_get_ptr(str, &ptr);
    net_socket_send(server, sock, ptr, strlen(ptr), &ret);
    release(str.iobj);
    net_socket_close(server, sock);
    release(scr.iobj);
}
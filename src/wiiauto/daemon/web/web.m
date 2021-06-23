#include "web.h"
#include "cherry/net/socket.h"
#include "cherry/core/buffer.h"
#include "wiiauto/thread/thread.h"
#include "wiiauto/device/device.h"
#include "cherry/core/map.h"
#include "url.h"
#include "service.h"
#include "handler/handler.h"
#include "wiiauto/version.h"
#include "wiiauto/lua/lua.h"
#include "wiiauto/daemon/daemon.h"
#include "wiiauto/daemon/preference/preference.h"

static map __sock_using__ = {id_null};
static spin_lock __sock_barrier__ = SPIN_LOCK_INIT;

static void add_connection(const net_socket server,  const iobj user, const net_socket sock)
{
}

static void __callback_read(const net_socket server,  const wiiauto_daemon_web_service service, const net_socket sock, const buffer first, const thread_pool pool)
{
    wiiauto_daemon_web_service_process(service, server, sock, first);

    wiiauto_recycle_thread_pool(pool);
    
    lock(&__sock_barrier__);
    map_remove(__sock_using__, key_obj(sock));
    unlock(&__sock_barrier__);
}

static void read_data(const net_socket server,  const wiiauto_daemon_web_service service, const net_socket sock)
{
    thread_pool pool;
    thread_job job;
    iobj obj;
    buffer first;
    buffer second;
    int i;
    const char *ptr;

    buffer_new(&first);
    buffer_new(&second);
    
    for (i = 0; i < 10; ++i) {
        buffer_erase(first);
        net_socket_read(sock, first);
        buffer_get_ptr(first, &ptr);
        if (ptr && ptr[0] != '\0') {
            if (strstr(ptr, "POST")) {
                net_socket_set_read_timeout(sock, 1000);
                net_socket_read(sock, second);
                buffer_append_buffer(first, second);
            }            
            break;
        }
    }

    lock(&__sock_barrier__);
    map_get(__sock_using__, key_obj(sock), &obj);
    if (!id_validate(obj)) {
        map_set(__sock_using__, key_obj(sock), server.iobj);

        wiiauto_get_thread_pool(&pool);
        thread_job_new(&job);
        thread_job_set_callback(job, (thread_job_callback)__callback_read);
        thread_job_add_arguments(job, server.iobj);
        thread_job_add_arguments(job, service.iobj);
        thread_job_add_arguments(job, sock.iobj);
        thread_job_add_arguments(job, first.iobj);
        thread_job_add_arguments(job, pool.iobj);
        thread_pool_add_job(pool, job);
        release(job.iobj);    
    }
    unlock(&__sock_barrier__);

    release(first.iobj);
    release(second.iobj);
}

static void remove_connection(const net_socket server,  const iobj user, const net_socket sock)
{
    
}

static thread_pool __thread__ = {id_null};

static void  __attribute__((destructor)) __out()
{
    // if (id_validate(__thread__.iobj)) {
    //     release(__thread__.iobj);
    // }
    // release(__sock_using__.iobj);
}

static void __callback_install(const thread_pool pool)
{
     {
        wiiauto_preference pref;
        i32 i;
        const char *url;
        time_t fire_time;
        u8 repeat;
        i32 interval;
        u8 enable;
        wiiauto_daemon_preference_get("/timer.db", &pref);

        i = 0;
        wiiauto_preference_iterate_timer(pref, i, &url, &fire_time, &repeat, &interval, &enable);
        while (url) {
            
            free(url);
            i++;
            wiiauto_preference_iterate_timer(pref, i, &url, &fire_time, &repeat, &interval, &enable);
        }

        if (i == 0) {
            wiiauto_lua_execute_file("/private/var/mobile/Library/WiiAuto/Scripts/Install.lua", 0, NULL, NULL, NULL);
        }
    }    

    wiiauto_recycle_thread_pool(pool);
}

void net_socket_get_descriptor(const net_socket p, int *d);

static void __callback()
{
    net_socket server;
    int fd = -1;
    wiiauto_daemon_web_service service;

roll_back:
    wiiauto_daemon_web_service_new(&service);
    wiiauto_daemon_web_service_register_handler(service, (const char *[]){"GET", NULL}, "/", wiiauto_daemon_web_service_handle_get_home);
    wiiauto_daemon_web_service_register_handler(service, (const char *[]){"GET", NULL}, "/home", wiiauto_daemon_web_service_handle_get_home);
    wiiauto_daemon_web_service_register_handler(service, (const char *[]){"GET", NULL}, "/control/start_playing", wiiauto_daemon_web_service_handle_start_playing);
    wiiauto_daemon_web_service_register_handler(service, (const char *[]){"GET", NULL}, "/control/stop_playing", wiiauto_daemon_web_service_handle_stop_playing);
    wiiauto_daemon_web_service_register_handler(service, (const char *[]){"GET", NULL}, "/runningScripts", wiiauto_daemon_web_service_handle_get_running_scripts);
    wiiauto_daemon_web_service_register_handler(service, (const char *[]){"GET", NULL}, "/control/set_timer", wiiauto_daemon_web_service_handle_set_timer);
    wiiauto_daemon_web_service_register_handler(service, (const char *[]){"GET", NULL}, "/control/get_timer", wiiauto_daemon_web_service_handle_get_timer);
    wiiauto_daemon_web_service_register_handler(service, (const char *[]){"GET", NULL}, "/control/enable_timer", wiiauto_daemon_web_service_handle_enable_timer);
    wiiauto_daemon_web_service_register_handler(service, (const char *[]){"GET", NULL}, "/control/disable_timer", wiiauto_daemon_web_service_handle_disable_timer);
    wiiauto_daemon_web_service_register_handler(service, (const char *[]){"GET", NULL}, "/control/remove_timer", wiiauto_daemon_web_service_handle_remove_timer);
    wiiauto_daemon_web_service_register_handler(service, (const char *[]){"GET", NULL}, "/config", wiiauto_daemon_web_service_handle_config);
    wiiauto_daemon_web_service_register_handler(service, (const char *[]){"GET", NULL}, "/install", wiiauto_daemon_web_service_handle_install);
    wiiauto_daemon_web_service_register_handler(service, (const char *[]){"GET", NULL}, "/auto_restart", wiiauto_daemon_web_service_handle_auto_restart);
    wiiauto_daemon_web_service_register_handler(service, (const char *[]){"GET", NULL}, "/auto_awake", wiiauto_daemon_web_service_handle_auto_awake);
    wiiauto_daemon_web_service_register_handler(service, (const char *[]){"GET", NULL}, "/request_hotspot_delay", wiiauto_daemon_web_service_handle_request_hotspot_delay);
    wiiauto_daemon_web_service_register_handler(service, (const char *[]){"GET", NULL}, "/register_gate", wiiauto_daemon_web_service_handle_register_gate);
    wiiauto_daemon_web_service_register_handler(service, (const char *[]){"GET", NULL}, "/remove_gate", wiiauto_daemon_web_service_handle_remove_gate);
    wiiauto_daemon_web_service_register_handler(service, (const char *[]){"POST", NULL}, "/goto", wiiauto_daemon_web_service_handle_process_gate);
    
    fd = -1;
    net_socket_new(&server);
    net_socket_bind(server, 8080);

    net_socket_get_descriptor(server, &fd);
    if (fd >= 0) {
        __daemon_web_success__ = 1;
    }

    if (strcmp(__wiiauto_version__, "0.0.43") == 0) {

        thread_pool pool;
        thread_job job;
        wiiauto_get_thread_pool(&pool);
        thread_job_new(&job);
        thread_job_set_callback(job, (thread_job_callback)__callback_install);
        thread_job_add_arguments(job, pool.iobj);
        thread_pool_add_job(pool, job);
        release(job.iobj);            
    }


    net_socket_run(server, service.iobj, (__net_socket_callback){
        .add_connection = add_connection,
        .read_data = (void(*)(const net_socket, const iobj, const net_socket))read_data,
        .remove_connection = remove_connection
    });
    release(server.iobj);
    release(service.iobj);

    kill(getpid(), SIGKILL);

    usleep(1000000);
    goto roll_back;
}

void wiiauto_daemon_web_init()
{
    thread_job job;

    if (!id_validate(__sock_using__.iobj)) {
        map_new(&__sock_using__);
        map_set_weak(__sock_using__, 1);
    }
    
    if (!id_validate(__thread__.iobj)) {
        thread_pool_new(&__thread__);

        thread_job_new(&job);
        thread_job_set_callback(job, (thread_job_callback)__callback);
        thread_pool_add_job(__thread__, job);
        release(job.iobj);
    }
}
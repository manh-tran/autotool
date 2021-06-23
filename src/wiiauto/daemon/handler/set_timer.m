#include "set_timer.h"
#include "../preference/preference.h"
#include "cherry/core/map.h"
#include "cherry/core/array.h"
#include "cherry/core/buffer.h"
#include "wiiauto/lua/lua.h"
#include "cherry/thread/thread.h"
#include "wiiauto/file/file.h"
#include "wiiauto/common/common.h"
#include "wiiauto/thread/thread.h"
#include "cherry/util/util.h"

static dispatch_queue_t timer_queue;

spin_lock __timer_barrier__ = 0;

local_type(timer);

typedef struct
{
    u8 repeat;
    i32 interval;
    buffer url;
    u8 enable;
    spin_lock barrier;
}
__timer;

make_local_type(timer, __timer);

static void __timer_init(__timer *__p)
{
    __p->repeat = 0;
    __p->interval = 0;
    __p->enable = 1;
    __p->barrier = SPIN_LOCK_INIT;
    buffer_new(&__p->url);
}

static void __timer_clear(__timer *__p)
{
    release(__p->url.iobj);
}

static map __runnings__ = {id_null};
static spin_lock __runnings_barrier__ = SPIN_LOCK_INIT;

static void __execute(const buffer url, const thread_pool pool)
{
    const char *curl;
    buffer_get_ptr(url, &curl);

    wiiauto_lua_execute_file(curl, 0, NULL, NULL, NULL);    
    wiiauto_recycle_thread_pool(pool);
}

static void __schedule(const time_t after, const timer tm)
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, after * NSEC_PER_SEC), timer_queue, ^{
        
        lock(&__runnings_barrier__);
        retain(tm.iobj);
        if (id_validate(tm.iobj)) {

            __timer *__t;
            thread_pool pool;
            thread_job job;
            const char *url;
            i32 interval;
            timer_fetch(tm, &__t);
            time_t t_now;
    
            util_time(&t_now);

            interval = __t->interval;
            if (__t->enable) {
                wiiauto_get_thread_pool(&pool);
                thread_job_new(&job);
                thread_job_set_callback(job, (thread_job_callback)__execute);
                thread_job_add_arguments(job, __t->url.iobj);
                thread_job_add_arguments(job, pool.iobj);
                thread_pool_add_job(pool, job);
                release(job.iobj);  

                buffer_get_ptr(__t->url, &url);

                {
                    wiiauto_preference pref;
                    wiiauto_daemon_preference_get("/timer.db", &pref);

                    wiiauto_preference_set_firetime(pref, url, t_now + interval);

                    lock(&__timer_barrier__);
                    wiiauto_preference_save(pref);
                    unlock(&__timer_barrier__);
                }
            }

            release(tm.iobj);
            unlock(&__runnings_barrier__);
            __schedule(interval,  tm);
        } else {
            unlock(&__runnings_barrier__);
        }        
    });
}

static void __run(const char *url, const time_t fire_time, const u8 repeat, const i32 interval, const u8 enable)
{
    time_t t_now, after;
    
    util_time(&t_now);
    after = fire_time - t_now;
    if (after < 0) {
        after = 0;
    }

    timer t;
    __timer *__t;
    timer_new(&t);
    timer_fetch(t, &__t);
    __t->enable = enable;
    __t->repeat = repeat;
    __t->interval = interval;
    buffer_append(__t->url, url, strlen(url));

    lock(&__runnings_barrier__);
    map_set(__runnings__, key_str(url), t.iobj);
    release(t.iobj);
    unlock(&__runnings_barrier__);

    __schedule(after, t);

    {
        wiiauto_preference pref;
        wiiauto_daemon_preference_get("/timer.db", &pref);

        wiiauto_preference_set_firetime(pref, url, t_now + interval);

        lock(&__timer_barrier__);
        wiiauto_preference_save(pref);
        unlock(&__timer_barrier__);
    }
}

void wiiauto_daemon_remove_timer_internal(const char *__url)
{
    static spin_lock __local_barrier__ = SPIN_LOCK_INIT;

    buffer b;
    const char *url = NULL;
    wiiauto_preference pref;    

    buffer_new(&b);
    wiiauto_convert_url(__url, b);
    buffer_get_ptr(b, &url);

    lock(&__local_barrier__);    

    wiiauto_lua_stop_file(url);
    wiiauto_daemon_preference_get("/timer.db", &pref);
    lock(&__runnings_barrier__);
    map_remove(__runnings__, key_str(url));
    wiiauto_preference_clear_timer(pref, url);
    
    lock(&__timer_barrier__);
    wiiauto_preference_save(pref);
    unlock(&__timer_barrier__);

    unlock(&__runnings_barrier__);

    unlock(&__local_barrier__);
    release(b.iobj);
}

void wiiauto_daemon_add_timer_internal(const char *__url, const time_t fire_time, const u8 repeat, const i32 interval)
{
    static spin_lock __local_barrier__ = SPIN_LOCK_INIT;
    buffer b;
    const char *url;

    buffer_new(&b);
    wiiauto_convert_url(__url, b);
    buffer_get_ptr(b, &url);

    lock(&__local_barrier__);
    wiiauto_daemon_remove_timer_internal(url);

    wiiauto_preference pref;
    wiiauto_daemon_preference_get("/timer.db", &pref);

    wiiauto_preference_set_timer(pref, url, fire_time, repeat, interval);

    lock(&__timer_barrier__);
    wiiauto_preference_save(pref);
    unlock(&__timer_barrier__);

    __run(url, fire_time, repeat, interval, 1);

    unlock(&__local_barrier__);

    release(b.iobj);
}

void wiiauto_daemon_set_timer_enable(const char *__url, const u8 enable)
{
    buffer b;
    const char *url;
    timer t;
    __timer *__t;

    buffer_new(&b);
    wiiauto_convert_url(__url, b);
    buffer_get_ptr(b, &url);

    lock(&__runnings_barrier__);
    map_get(__runnings__, key_str(url), &t.iobj);
    retain(t.iobj);
    if (id_validate(t.iobj)) {
        timer_fetch(t, &__t);
        __t->enable = enable;
    }
    release(t.iobj);

    wiiauto_preference pref;
    wiiauto_daemon_preference_get("/timer.db", &pref);
    wiiauto_preference_enable_timer(pref, url, enable);

    lock(&__timer_barrier__);
    wiiauto_preference_save(pref);
    unlock(&__timer_barrier__);

    unlock(&__runnings_barrier__);

    release(b.iobj);
}

CFDataRef daemon_handle_set_timer(const __wiiauto_event_set_timer *input)
{
    wiiauto_daemon_add_timer_internal(input->url, input->fire_time, input->repeat, input->interval);

    return NULL;
}

CFDataRef daemon_handle_remove_timer(const __wiiauto_event_remove_timer *input)
{
    wiiauto_daemon_remove_timer_internal(input->url);

    return NULL;
}

void wiiauto_daemon_timer_init()
{
    map_new(&__runnings__);
    timer_queue = dispatch_queue_create("com.wiimob.wiiauto.daemon_timer", NULL);

    wiiauto_preference pref;
    i32 i;
    const char *url;
    time_t fire_time;
    u8 repeat;
    i32 interval;
    u8 enable;

    wiiauto_daemon_preference_get("/timer.db", &pref);

    // i = 0;
    // wiiauto_preference_iterate_timer(pref, i, &url, &fire_time, &repeat, &interval, &enable);
    // while (url) {

    //     if (enable) {
    //         buffer b;
    //         const char *__url;

    //         buffer_new(&b);
    //         wiiauto_convert_url(url, b);
    //         buffer_get_ptr(b, &__url);

    //         if (strncmp(url, "/var", 4) == 0) {
    //             wiiauto_preference_clear_timer(pref, url);
    //             wiiauto_preference_set_timer(pref, __url, fire_time, repeat, interval);
    //             wiiauto_preference_enable_timer(pref, __url, enable);

    //             lock(&__timer_barrier__);
    //             wiiauto_preference_save(pref);
    //             unlock(&__timer_barrier__);

    //             i = -1;
    //         }
                
    //         release(b.iobj);
    //     }

    //     free(url);

    //     i++;
    //     wiiauto_preference_iterate_timer(pref, i, &url, &fire_time, &repeat, &interval, &enable);
    // }


    i = 0;
    wiiauto_preference_iterate_timer(pref, i, &url, &fire_time, &repeat, &interval, &enable);
    while (url) {

        buffer b;
        const char *__url;

        buffer_new(&b);
        wiiauto_convert_url(url, b);
        buffer_get_ptr(b, &__url);

        __run(__url, fire_time, repeat, interval, enable);
        release(b.iobj);

        free(url);

        i++;
        wiiauto_preference_iterate_timer(pref, i, &url, &fire_time, &repeat, &interval, &enable);
    }
}
#include "api.h"
#include "wiiauto/common/common.h"
#include "wiiauto/lua/lua.h"
#include "wiiauto/thread/thread.h"
#include "cherry/core/map.h"

static void __callback(const buffer scr, const thread_pool pool)
{
    const char *ptr;

    buffer_get_ptr(scr, &ptr);   
    wiiauto_lua_execute_file(ptr, 0, NULL, NULL, NULL);

    wiiauto_recycle_thread_pool(pool);
}

int wiiauto_lua_run_script(lua_State *ls)
{
    const char *ptr;
    buffer scr;
    thread_pool pool;
    thread_job job;

    buffer_new(&scr);

    ptr = luaL_optstring(ls, 1, NULL);
    if (ptr) {
        common_get_script_url(ptr, scr);

        wiiauto_get_thread_pool(&pool);
        thread_job_new(&job);
        thread_job_set_callback(job, (thread_job_callback)__callback);
        thread_job_add_arguments(job, scr.iobj);
        thread_job_add_arguments(job, pool.iobj);
        thread_pool_add_job(pool, job);
        release(job.iobj);  
    } 

    release(scr.iobj);
    return 0;
}

int wiiauto_lua_stop_script(lua_State *ls)
{
    const char *ptr;
    buffer scr;

    ptr = luaL_optstring(ls, 1, NULL);
    buffer_new(&scr);
    if (ptr) {
        common_get_script_url(ptr, scr);
        buffer_get_ptr(scr, &ptr);        
        wiiauto_lua_stop_file(ptr);
    }

    release(scr.iobj);
    return 0;
}
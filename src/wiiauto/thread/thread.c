#include "thread.h"
#include "cherry/thread/thread.h"
#include "cherry/core/map.h"

static map __pools_using__ = {id_null};
static map __pools__ = {id_null};
static spin_lock __pools_barrier__ = SPIN_LOCK_INIT;

void wiiauto_get_thread_pool(thread_pool *p)
{   
    lock(&__pools_barrier__);
    if (!id_validate(__pools__.iobj)) {
        map_new(&__pools__);
        map_new(&__pools_using__);
    }
    unlock(&__pools_barrier__);

    u32 len;
    
    lock(&__pools_barrier__);
    map_get_size(__pools__, &len);
    if (len > 0) {
        map_iterate(__pools__, 0, NULL, &p->iobj);
        map_set(__pools_using__, key_obj(p->iobj), p->iobj);
        map_remove(__pools__, key_obj(p->iobj));
    } else {
        thread_pool_new(p);
        map_set(__pools_using__, key_obj(p->iobj), p->iobj);
        release(p->iobj);
    }
    unlock(&__pools_barrier__);
}

void wiiauto_recycle_thread_pool(const thread_pool p)
{
    lock(&__pools_barrier__);
    if (!id_validate(__pools__.iobj)) {
        map_new(&__pools__);
        map_new(&__pools_using__);
    }
    unlock(&__pools_barrier__);

    lock(&__pools_barrier__);
    map_set(__pools__, key_obj(p.iobj), p.iobj);
    map_remove(__pools_using__, key_obj(p.iobj));
    unlock(&__pools_barrier__);
}
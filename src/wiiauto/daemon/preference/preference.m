#include "preference.h"
#include "cherry/core/map.h"

static map prefs = {id_null};

static void __in()
{
    if (id_validate(prefs.iobj)) return;

    map_new(&prefs);
}

static void __attribute__((destructor)) __out()
{
    // release(prefs.iobj);
}

void wiiauto_daemon_preference_get(const char *path, wiiauto_preference *pref)
{
    __in();

    static spin_lock __barrier__ = SPIN_LOCK_INIT;

    lock(&__barrier__);

    map_get(prefs, key_str(path), &pref->iobj);
    if (!id_validate(pref->iobj)) {
        wiiauto_preference_create(path, pref);
        map_set(prefs, key_str(path), pref->iobj);
        release(pref->iobj);
    }

    unlock(&__barrier__);
}
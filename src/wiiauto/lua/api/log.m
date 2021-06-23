#include "api.h"
#include "wiiauto/device/device.h"
#include "cherry/core/file.h"
#include <sys/stat.h>

int wiiauto_lua_log(lua_State *ls)
{
    static spin_lock __local__ = SPIN_LOCK_INIT;

    lock(&__local__);

    const char *content;
    file f;
    u8 r;

    wiiauto_device_is_log_enable(&r);
    content = luaL_optstring(ls, 1, NULL);

    if (content && r) {

        struct stat st;
        stat(WIIAUTO_ROOT_LOG_FILE_PATH, &st);
        u32 fsize = st.st_size;
        
        file_new(&f);
        if (fsize >= 1024 * 1024) {
            file_open_write(f, WIIAUTO_ROOT_LOG_FILE_PATH);
        } else {
            file_open_append(f, WIIAUTO_ROOT_LOG_FILE_PATH);
        }        
        file_write(f, content, strlen(content));
        file_write(f, "\n", 1);
        release(f.iobj);

    }

    unlock(&__local__);

    return 0;
}
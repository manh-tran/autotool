#include "lua.h"
#include "api/api.h"
#include "cherry/core/map.h"
#include "cherry/math/cmath.h"
#include <pthread.h>
#include "openssl/md5.h"
#include "wiiauto/device/device.h"
#include "wiiauto/file/file.h"
#include <sys/time.h>
#include "wiiauto/daemon/daemon.h"

static u64 current_timestamp() 
{
    struct timeval te; 
    gettimeofday(&te, NULL);
    u64 milliseconds = te.tv_sec*1000LL + te.tv_usec/1000;
    return milliseconds;
}


static void __append_path(lua_State *ls, const char *path)
{
    buffer b;
    const char *s;
    u32 len;

    len = strlen(path);

    lua_getglobal(ls, "package");
    lua_getfield(ls, -1, "path");

    s = lua_tostring(ls, -1);
    buffer_new(&b);
    buffer_append(b, path, strlen(path));
    if (path[len - 1] != '/') {
        buffer_append(b, "/", 1);
    }
    buffer_append(b, "?.lua", 5);
    buffer_append(b, ";", 1);
    buffer_append(b, s, strlen(s));

    buffer_get_ptr(b, &s);

    lua_pop(ls, 1);
    lua_pushstring(ls, s);
    lua_setfield(ls, -2, "path");
    lua_pop(ls, 1);
    lua_settop(ls, 0); 

    release(b.iobj);
}

/*
 * ls
 */
local_type(internal_state);

typedef struct
{
    lua_State *ls;
    buffer url;
    buffer fullpath;
    u8 stopped;
}
__internal_state;

make_local_type(internal_state, __internal_state);

static void __internal_state_init(__internal_state *__p)
{
    __p->ls = NULL;
    buffer_new(&__p->url);
    buffer_new(&__p->fullpath);
    __p->stopped = 0;
}

static void __internal_state_clear(__internal_state *__p)
{
    release(__p->url.iobj);
    release(__p->fullpath.iobj);
}

static void internal_state_set(const internal_state p, lua_State *ls, const char *url, const char *fullpath)
{
    __internal_state *__p;
    
    internal_state_fetch(p, &__p);
    assert(__p != NULL);

    __p->ls = ls;

    buffer_erase(__p->url);
    buffer_append(__p->url, url, strlen(url));

    buffer_erase(__p->fullpath);
    buffer_append(__p->fullpath, fullpath, strlen(fullpath));
}

static void internal_state_get_url(const internal_state p, const char **url)
{
    __internal_state *__p;
    
    internal_state_fetch(p, &__p);
    assert(__p != NULL);

    buffer_get_ptr(__p->url, url);
}

static void internal_state_get_fullpath(const internal_state p, const char **fullpath)
{
    __internal_state *__p;
    
    internal_state_fetch(p, &__p);
    assert(__p != NULL);

    buffer_get_ptr(__p->fullpath, fullpath);
}

static void internal_state_get(const internal_state p, lua_State **ls)
{
    __internal_state *__p;
    
    internal_state_fetch(p, &__p);
    assert(__p != NULL);

    *ls = __p->ls;
}

static void internal_state_get_stopped(const internal_state p, u8 *stopped)
{
    __internal_state *__p;
    
    internal_state_fetch(p, &__p);
    assert(__p != NULL);

    *stopped = __p->stopped;
}

static void internal_state_set_stopped(const internal_state p)
{
    __internal_state *__p;
    
    internal_state_fetch(p, &__p);
    assert(__p != NULL);

    __p->stopped = 1;
}


/*
 */
static map paths = {id_null};
static spin_lock barrier = SPIN_LOCK_INIT;

static struct
{
    map paths;
    spin_lock barrier;
}
runnings = {.paths = (map){id_null}, .barrier = SPIN_LOCK_INIT};

// static void __attribute__((constructor)) __in()
static void __in()
{
    if (!id_validate(paths.iobj)) {
        map_new(&paths);
    }    
    if (!id_validate(runnings.paths.iobj)) {
        map_new(&runnings.paths);
    }
}

static void __attribute__((destructor)) __out()
{
    // release(paths.iobj);
    // release(runnings.paths.iobj);
}

void wiiauto_lua_get_current_executing_path(lua_State *ls, const char **path)
{
    __in();

    lock(&barrier);

    buffer b;

    map_get(paths, key_obj(ls), &b.iobj);
    if (id_validate(b.iobj)) {
        buffer_get_ptr(b, path);
    } else {
        *path = NULL;
    }
    unlock(&barrier);
}

void wiiauto_lua_get_current_running_scripts_count(u32 *count)
{
    __in();

    lock(&runnings.barrier);
    map_get_size(runnings.paths, count);
    unlock(&runnings.barrier);
}

void wiiauto_lua_get_json_string_running_scripts(const buffer b, const u8 fullpath)
{
    __in();

    buffer_erase(b);
    i32 i;
    internal_state is;
    const char *url, *str;

    lock(&runnings.barrier);

    buffer_append(b, "[", 1);
    i = 0;
    map_iterate(runnings.paths, i, NULL, &is.iobj);
    while (id_validate(is.iobj)) {

        if (i > 0) {
            buffer_append(b, ",", 1);
        }
        buffer_append(b, "\"", 1);

        if (fullpath) {
            internal_state_get_fullpath(is, &url);
            buffer_append(b, url, strlen(url));
        } else {
            internal_state_get_url(is, &url);
            if (strncmp(url, WIIAUTO_SCRIPT_URL, strlen(WIIAUTO_SCRIPT_URL)) == 0) {
                str = url + sizeof(WIIAUTO_SCRIPT_URL) - 1;
                if (str[0] != '/') {
                    buffer_append(b, "/", 1);
                }
                buffer_append(b, str, strlen(str));
            } else {
                buffer_append(b, url, strlen(url));
            }
        }

        buffer_append(b, "\"", 1);
        i++;
        map_iterate(runnings.paths, i, NULL, &is.iobj);
    }
    buffer_append(b, "]", 1);

    unlock(&runnings.barrier);
}

static void hook(lua_State* ls, lua_Debug *ar)
{
    // lua_sethook(ls, hook, LUA_MASKLINE, 0); 
    luaL_error(ls, "stop by user!");
}

void wiiauto_lua_stop_file(const char *__url)
{
    __in();

    const char *url;
    buffer burl;
    u32 blen;
    buffer b;
    const char *ptr = NULL;
    internal_state is;
    lua_State *ls;

    buffer_new(&b);
    buffer_new(&burl);

    blen = strlen(__url);
    if (blen > 3 && __url[blen - 1] == 't' && __url[blen - 2] == 'a' && __url[blen - 3] == '.') {
        buffer_append(burl, __url, blen);
        buffer_append(burl, "/main.lua", strlen("/main.lua"));
        buffer_get_ptr(burl, &url);
    } else {
        url = __url;
    }

    wiiauto_convert_url(url, b);
    buffer_get_ptr(b, &ptr);

    lock(&runnings.barrier);
    map_get(runnings.paths, key_str(ptr), &is.iobj);
    if (id_validate(is.iobj)) {
        internal_state_get(is, &ls);
        if (ls) {
            internal_state_set_stopped(is);
            lua_sethook(ls, hook, LUA_MASKLINE, 0);
        }        

        // map_remove(runnings.paths, key_str(ptr));
    }
    unlock(&runnings.barrier);

    // lock(&runnings.barrier);
    // map_remove(runnings.paths, key_str(ptr));
    // unlock(&runnings.barrier);

    release(b.iobj);
    release(burl.iobj);
}

// static void hook_yield(lua_State* ls, lua_Debug *ar)
// {
//     static u64 __current_time__ = 0;

//     u64 cm = current_timestamp();
//     if (cm - __current_time__ >= 50) {
//         __current_time__ = cm;
//         __yield();
//     }
// }

int wiiauto_lua_execute_file(const char *__url, const u8 force, const char *func, const char *json_arguments, char **result)
{
    __in();
    static spin_lock __local_barrier__ = SPIN_LOCK_INIT;

    int executed = 0;

    if (!__daemon_avaliable__) return executed;

    const char *url;
    buffer burl;
    u32 blen;
    lua_State *ls;
    int err;
    internal_state is, is2;
    buffer b, path_folder;
    const char *ptr = NULL, *end = NULL;
    int inode;
    u8 stopped = 0;

    buffer_new(&b);
    buffer_new(&burl);
    buffer_new(&path_folder);

    blen = strlen(__url);
    if (blen > 3 && __url[blen - 1] == 't' && __url[blen - 2] == 'a' && __url[blen - 3] == '.') {
        buffer_append(burl, __url, blen);
        buffer_append(burl, "/main.lua", strlen("/main.lua"));
        buffer_get_ptr(burl, &url);
    } else {
        url = __url;
    }

    lock(&__local_barrier__);

    if (!force) {

        wiiauto_convert_url(url, b);
        buffer_get_ptr(b, &ptr);

        lock(&runnings.barrier);
        map_get(runnings.paths, key_str(ptr), &is.iobj);        

        if (id_validate(is.iobj)) {
            internal_state_get_stopped(is, &stopped);
            unlock(&runnings.barrier);
            
            if (!stopped) {
                unlock(&__local_barrier__);
                goto finish;
            }            
        } else {
            unlock(&runnings.barrier);
        }

        buffer_erase(b);
    }    

    wiiauto_lua_stop_file(url);

    ls = luaL_newstate();
    
    wiiauto_convert_url(url, b);
    buffer_get_ptr(b, &ptr);

    end = ptr + strlen(ptr) - 1;
    while (end && *end) {
        if (*end == '/') {
            buffer_append(path_folder, ptr, end - ptr + 1);
            break;
        } else {
            end--;
        }
    }

    lock(&runnings.barrier);
    internal_state_new(&is);
    map_set(runnings.paths, key_str(ptr), is.iobj);
    release(is.iobj);
    unlock(&runnings.barrier);

    unlock(&__local_barrier__);

    luaL_openlibs(ls);
    wiiauto_lua_register_state(ls);
    buffer_get_ptr(path_folder, &end);
    __append_path(ls, end);

    lock(&barrier);
    map_set(paths, key_obj(ls), path_folder.iobj);
    unlock(&barrier);

    internal_state_set(is, ls, url, ptr);
    lua_settop(ls, 0);
    err = luaL_loadfile(ls, ptr);

    // lua_sethook(ls, hook_yield, LUA_MASKLINE, 0);

    if (err == 0) {
        err = lua_pcall(ls, 0, 0, 0);
        if (err != 0) {
            wiiauto_device_sys_log("ERROR: %s\n", lua_tostring(ls,-1));
        } else {
            wiiauto_device_sys_log("finish_run: %s\n", ptr);

            if (func) {
                lua_getglobal(ls, func);
                if (json_arguments) {
                    lua_pushstring(ls, json_arguments);
                    err = lua_pcall(ls, 1, 1, 0);
                } else {
                    err = lua_pcall(ls, 0, 1, 0);
                }
            }

            if (err == 0) {
                if (result) {
                    if (lua_isstring(ls, -1)) {
                        const char *ls_result = lua_tostring(ls, -1);
                        int ls_result_len = strlen(ls_result);
                        if (ls_result_len > 0) {
                            *result = malloc(ls_result_len + 1);
                            strcpy(*result, ls_result);   
                        } else {
                            *result = NULL;
                        }     
                        lua_pop(ls, 1);                
                    }
                }
            } else {
                wiiauto_device_sys_log("ERROR: %s\n", lua_tostring(ls,-1));
            }
        }
    } else {
        wiiauto_device_sys_log("ERROR: %s\n", lua_tostring(ls,-1));
    }    

    lock(&barrier);
    map_remove(paths, key_obj(ls));
    unlock(&barrier);

    lua_close(ls);

    lock(&runnings.barrier);
    map_get(runnings.paths, key_str(ptr), &is2.iobj);
    if (id_validate(is2.iobj) && id_equal(is.iobj, is2.iobj)) {
        map_remove(runnings.paths, key_str(ptr));
    }    
    unlock(&runnings.barrier);

    executed = 1;

finish:
    release(path_folder.iobj);
    release(burl.iobj);
    release(b.iobj);

    return executed;
}

void wiiauto_lua_execute_buffer(const char *mem, const unsigned int len)
{
    __in();

    pthread_t pid =  pthread_self();

    buffer path;
    file f;
    unsigned char hash[MD5_DIGEST_LENGTH];
    char md5string[33];
    const char *ptr;

    MD5((const unsigned char *)mem, len, hash);
    buffer_new(&path);
    buffer_append(path, WIIAUTO_ROOT_TMP_SCRIPTS_PATH, strlen(WIIAUTO_ROOT_TMP_SCRIPTS_PATH));

    for(int i = 0; i < 16; ++i) {
        sprintf(&md5string[i*2], "%02x", (unsigned int)hash[i]);
    }
    buffer_append(path, md5string, 32);

    buffer_get_ptr(path, &ptr);

    lock(&barrier);
    map_set(paths, key_obj(pid), path.iobj);
    unlock(&barrier);

    file_new(&f);
    file_open_write(f, ptr);
    file_write(f, mem, len);
    
    release(f.iobj);
    release(path.iobj);


    lua_State *ls;
    int err;

    ls = luaL_newstate();
    luaL_openlibs(ls);
    wiiauto_lua_register_state(ls);

    lua_settop(ls, 0);

    err = luaL_loadbuffer(ls, mem, len, "script");
    if (err == 0) {
        err = lua_pcall(ls, 0, 0, 0);
        if (err != 0) {
            printf("ERROR: %s\n", lua_tostring(ls,-1));
        }
    }
    
    lua_close(ls);
}

void wiiauto_lua_process_input_path(lua_State *ls, const char *path, const buffer b)
{
    __in();

    buffer_erase(b);
    const char *cr = NULL;
    u32 len;

    if (strncmp(path, "/private", strlen("/private")) == 0
        || strncmp(path, "/var", strlen("/var")) == 0
        || strncmp(path, "/System", strlen("/System")) == 0
        || strncmp(path, WIIAUTO_SCRIPT_URL, sizeof(WIIAUTO_SCRIPT_URL) - 1) == 0
        || strncmp(path, IOS_FILE_URL, sizeof(IOS_FILE_URL) - 1) == 0
        || strncmp(path, WIIAUTO_INTERNAL_URL, sizeof(WIIAUTO_INTERNAL_URL) - 1) == 0
        || strncmp(path, WIIAUTO_RESOURCE_URL, sizeof(WIIAUTO_RESOURCE_URL) - 1) == 0) {
        buffer_append(b, path, strlen(path));
    } else {
        wiiauto_lua_get_current_executing_path(ls, &cr);
        if (cr) {
            len = strlen(cr);
            buffer_append(b, cr, strlen(cr));
            if (cr[len - 1] != '/') {
                buffer_append(b, "/", 1);
            }
        } else {
            buffer_append(b, WIIAUTO_SCRIPT_URL, strlen(WIIAUTO_SCRIPT_URL));
        }        
        if (path[0] == '/') {
            buffer_append(b, path + 1, strlen(path) - 1);
        } else {
            buffer_append(b, path, strlen(path));
        }        
    }
}
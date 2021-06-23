#include "url.h"
#include "cherry/core/buffer.h"
#include "cherry/core/map.h"

/*
 * url
 */
typedef struct
{
    buffer path;
    map params;
}
__wiiauto_daemon_web_url;

make_type(wiiauto_daemon_web_url, __wiiauto_daemon_web_url);

static void __wiiauto_daemon_web_url_init(__wiiauto_daemon_web_url *__p)
{
    buffer_new(&__p->path);
    map_new(&__p->params);
}

static void __wiiauto_daemon_web_url_clear(__wiiauto_daemon_web_url *__p)
{
    release(__p->path.iobj);
    release(__p->params.iobj);
}

void wiiauto_daemon_web_url_get_param(const wiiauto_daemon_web_url p, const char *k, const char **value)
{
    __wiiauto_daemon_web_url *__p;
    buffer b;

    wiiauto_daemon_web_url_fetch(p, &__p);
    assert(__p != NULL);

    map_get(__p->params, key_str(k), &b.iobj);
    if (id_validate(b.iobj)) {
        buffer_get_ptr(b, value);
    } else {
        *value = NULL;
    }
}

void wiiauto_daemon_web_url_parse(const wiiauto_daemon_web_url p, const char *ptr)
{
    __wiiauto_daemon_web_url *__p;
    const char *str, *begin = NULL, *v = NULL;
    buffer name, value;
    u8 flag;
    u32 l1, l2;

    wiiauto_daemon_web_url_fetch(p, &__p);
    assert(__p !=  NULL);

    buffer_erase(__p->path);
    map_remove_all(__p->params);

    buffer_new(&name);
    buffer_new(&value);
    flag = 0;

    str = ptr;

    while (str && *str) {
        if (!begin) {
            if (!isspace(*str)) {
                begin = str;
            }
        } else {
            if (isspace(*str) || (*str == '?')) {
                buffer_append(__p->path, begin, str - begin);
                break;
            }
        }
        str++;
    }

    if (str && *str == '?') {
        str++;
        while (str && *str) {
            if (!isspace(*str)) {
                switch(*str) {
                    case '=':
                        flag = 1;
                        break;
                    case '&':
                        buffer_length(name, 1, &l1);
                        buffer_length(value, 1, &l2);
                        if (l1 > 0 && l2 > 0) {
                            buffer_get_ptr(name, &v);
                            map_set(__p->params, key_str(v), value.iobj);
                            release(value.iobj);
                            buffer_new(&value);
                        }

                        flag = 0;
                        buffer_erase(name);
                        buffer_erase(value);
                        break;
                    default:
                        if (flag) {
                            buffer_append(value, str, 1);
                        } else {
                            buffer_append(name, str, 1);
                        }
                        break;
                }
            } else {
                if (flag) {
                    buffer_length(name, 1, &l1);
                    buffer_length(value, 1, &l2);
                    if (l1 > 0 && l2 > 0) {
                        buffer_get_ptr(name, &v);
                        map_set(__p->params, key_str(v), value.iobj);
                        release(value.iobj);
                        buffer_new(&value);
                    }
                }
                break;
            }

            str++;
        }
    }

    release(name.iobj);
    release(value.iobj);
}

void wiiauto_daemon_web_url_get_path(const wiiauto_daemon_web_url p, const char **path)
{
    __wiiauto_daemon_web_url *__p;

    wiiauto_daemon_web_url_fetch(p, &__p);
    assert(__p !=  NULL);

    buffer_get_ptr(__p->path, path);
}
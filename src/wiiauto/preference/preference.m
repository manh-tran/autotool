// #include "preference.h"
// #include "cherry/json/json.h"
// #include "cherry/core/buffer.h"
// #include "wiiauto/common/common.h"

// static void __object_require_object(const json_element p, const char *key, json_element *e)
// {
//     json_element o;

//     json_element_make_object(p);

//     json_object_get(p, key, &o);
//     if (!id_validate(o.iobj)) {
//         json_element_new(&o);
//         json_object_add(p, key, o);
//         release(o.iobj);
//     }
//     json_element_make_object(o);

//     if (e) {
//         *e = o;
//     }
// }

// static void __object_require_string(const json_element p, const char *key, json_element *e)
// {
//     json_element o;

//     json_element_make_object(p);

//     json_object_get(p, key, &o);
//     if (!id_validate(o.iobj)) {
//         json_element_new(&o);
//         json_object_add(p, key, o);
//         release(o.iobj);
//     }
//     json_element_make_string(o);

//     if (e) {
//         *e = o;
//     }
// }

// static void __object_require_number(const json_element p, const char *key, json_element *e)
// {
//     json_element o;

//     json_element_make_object(p);

//     json_object_get(p, key, &o);
//     if (!id_validate(o.iobj)) {
//         json_element_new(&o);
//         json_object_add(p, key, o);
//         release(o.iobj);
//     }
//     json_element_make_number(o);

//     if (e) {
//         *e = o;
//     }
// }

// static void __object_require_boolean(const json_element p, const char *key, json_element *e)
// {
//     json_element o;

//     json_element_make_object(p);

//     json_object_get(p, key, &o);
//     if (!id_validate(o.iobj)) {
//         json_element_new(&o);
//         json_object_add(p, key, o);
//         release(o.iobj);
//     }
//     json_element_make_boolean(o);

//     if (e) {
//         *e = o;
//     }
// }


// typedef struct
// {
//     json_element root;
//     json_element single;
//     json_element timer;
//     buffer url;
//     u8 update;
//     spin_lock barrier;
// }
// __wiiauto_preference;

// make_type(wiiauto_preference, __wiiauto_preference);

// static void __wiiauto_preference_init(__wiiauto_preference *__p)
// {
//     __p->root.iobj = id_null;
//     __p->url.iobj = id_null;
//     __p->single.iobj = id_null;
//     __p->timer.iobj = id_null;
//     __p->update = 0;
//     __p->barrier = SPIN_LOCK_INIT;
// }

// static void __wiiauto_preference_clear(__wiiauto_preference *__p)
// {
//     const char *ptr;

//     if (id_validate(__p->root.iobj) && id_validate(__p->url.iobj) && __p->update) {
//         buffer_get_ptr(__p->url, &ptr);
//         json_element_save_file(__p->root, ptr);
//         __p->update = 0;
//     }

//     release(__p->root.iobj);
//     release(__p->url.iobj);
// }

// void wiiauto_preference_save(const wiiauto_preference p)
// {
//     __wiiauto_preference *__p;
//     const char *ptr;

//     wiiauto_preference_fetch(p, &__p);
//     assert(__p != NULL);

//     lock(&__p->barrier);

//     if (id_validate(__p->root.iobj) && id_validate(__p->url.iobj) && __p->update) {
//         buffer_get_ptr(__p->url, &ptr);
//         json_element_save_file(__p->root, ptr);
//         __p->update = 0;
//     }

//     unlock(&__p->barrier);
// }

// void wiiauto_preference_create(const char *name, wiiauto_preference *p)
// {
//     wiiauto_preference_new(p);
//     __wiiauto_preference *__p;
//     const char *ptr;

//     wiiauto_preference_fetch(*p, &__p);

//     buffer_new(&__p->url);
//     common_get_internal_url(name, __p->url);
//     buffer_get_ptr(__p->url, &ptr);

//     json_element_new(&__p->root);
//     json_element_load_file(__p->root, ptr);
//     json_element_make_object(__p->root);

//     __object_require_object(__p->root, "single", &__p->single);
//     __object_require_object(__p->root, "timer", &__p->timer);
// }

// void wiiauto_preference_set_string(const wiiauto_preference p, const char *key, const char *value)
// {
//     __wiiauto_preference *__p;
//     json_element e;

//     wiiauto_preference_fetch(p, &__p);
//     assert(__p != NULL);

//     lock(&__p->barrier);

//     __object_require_string(__p->single, key, &e);
//     json_string_set(e, value);

//     __p->update = 1;

//     unlock(&__p->barrier);
// }

// void wiiauto_preference_set_integer(const wiiauto_preference p, const char *key, const i64 number)
// {
//     __wiiauto_preference *__p;
//     json_element e;

//     wiiauto_preference_fetch(p, &__p);
//     assert(__p != NULL);

//     lock(&__p->barrier);

//     __object_require_number(__p->single, key, &e);
//     json_number_set(e, number);

//     __p->update = 1;

//     unlock(&__p->barrier);
// }

// void wiiauto_prefernece_get_string(const wiiauto_preference p, const char *key, const char **ptr)
// {
//     __wiiauto_preference *__p;
//     json_element e;
//     u8 r;

//     wiiauto_preference_fetch(p, &__p);
//     assert(__p != NULL);

//     lock(&__p->barrier);

//     json_object_get(__p->single, key, &e);
//     if (id_validate(e.iobj)) {
//         json_element_is_string(e, &r);
//         if (r) {
//             json_string_get_ptr(e, ptr);
//         } else {
//             *ptr = NULL;
//         }
//     } else {
//         *ptr = NULL;
//     }

//     unlock(&__p->barrier);
// }

// void wiiauto_preference_get_integer(const wiiauto_preference p, const char *key, i64 *number)
// {
//     __wiiauto_preference *__p;
//     json_element e;
//     u8 r;
//     f64 n;

//     wiiauto_preference_fetch(p, &__p);
//     assert(__p != NULL);

//     lock(&__p->barrier);

//     json_object_get(__p->single, key, &e);
//     if (id_validate(e.iobj)) {
//         json_element_is_number(e, &r);
//         if (r) {
//             json_number_get(e, &n);
//             *number = n;
//         } else {
//             *number = 0;
//         }
//     } else {
//         *number = 0;
//     }

//     unlock(&__p->barrier);
// }

// void wiiauto_preference_set_firetime(const wiiauto_preference p, const char *url, const time_t fire_time)
// {
//     __wiiauto_preference *__p;
//     json_element o;
//     json_element e;

//     wiiauto_preference_fetch(p, &__p);
//     assert(__p != NULL);

//     lock(&__p->barrier);

//     __object_require_object(__p->timer, url, &o);

//     __object_require_number(o, "fire_time", &e);
//     json_number_set(e, fire_time);

//     __p->update = 1;

//     unlock(&__p->barrier);
// }

// void wiiauto_preference_set_timer(const wiiauto_preference p, const char *url, const time_t fire_time, const u8 repeat, const i32 interval)
// {
//     __wiiauto_preference *__p;
//     json_element o;
//     json_element e;

//     wiiauto_preference_fetch(p, &__p);
//     assert(__p != NULL);

//     lock(&__p->barrier);

//     __object_require_object(__p->timer, url, &o);

//     __object_require_number(o, "fire_time", &e);
//     json_number_set(e, fire_time);

//     __object_require_boolean(o, "repeat", &e);
//     json_boolean_set(e, repeat);

//     __object_require_number(o, "interval", &e);
//     json_number_set(e, interval);

//     __p->update = 1;

//     unlock(&__p->barrier);
// }

// void wiiauto_preference_clear_timer(const wiiauto_preference p, const char *url)
// {
//     __wiiauto_preference *__p;

//     wiiauto_preference_fetch(p, &__p);
//     assert(__p != NULL);

//     lock(&__p->barrier);

//     json_object_remove(__p->timer, url);

//     __p->update = 1;

//     unlock(&__p->barrier);
// }

// void wiiauto_preference_enable_timer(const wiiauto_preference p, const char *url, const u8 enable)
// {
//     __wiiauto_preference *__p;
//     json_element e, e_enable;

//     wiiauto_preference_fetch(p, &__p);
//     assert(__p != NULL);

//     lock(&__p->barrier);

//     json_object_get(__p->timer, url, &e);
//     if (id_validate(e.iobj)) {
//         json_object_require_boolean_default(e, "enable", &e_enable, 1);
//         json_boolean_set(e_enable, enable);
//     }

//     unlock(&__p->barrier);
// }

// void wiiauto_preference_iterate_timer(const wiiauto_preference p, const u32 index, const char **url, time_t *fire_time, u8 *repeat, i32 *interval, u8 *enable)
// {
//     __wiiauto_preference *__p;
//     json_element o;
//     json_element e;
//     f64 v;
//     u8 b;

//     wiiauto_preference_fetch(p, &__p);
//     assert(__p != NULL);

//     lock(&__p->barrier);

//     json_object_iterate(__p->timer, index, url, &o);
//     if (id_validate(o.iobj)) {
        
//         __object_require_number(o, "fire_time", &e);
//         json_number_get(e , &v);
//         *fire_time = v;

//         __object_require_boolean(o, "repeat", &e);
//         json_boolean_get(e, &b);
//         *repeat = b;

//         __object_require_number(o, "interval", &e);
//         json_number_get(e , &v);
//         *interval = v;

//         json_object_require_boolean_default(o, "enable", &e, 1);
//         json_boolean_get(e, &b);
//         *enable = b;

//     } else {
//         *url = NULL;
//         *fire_time = 0;
//         *repeat = 0;
//         *interval = 0;
//         *enable = 0;
//     }

//     unlock(&__p->barrier);
// }
#include "alert.h"
#include "wiiauto/common/common.h"
#include "cherry/core/buffer.h"
#include "cherry/core/array.h"
#include <sys/time.h>

static u64 current_timestamp() 
{
    struct timeval te; 
    gettimeofday(&te, NULL);
    u64 milliseconds = te.tv_sec*1000LL + te.tv_usec/1000;
    return milliseconds;
}

/*
 * alert label info
 */
local_type(label_info);

typedef struct
{
    buffer title;
    float x;
    float y;
}
__label_info;

make_local_type(label_info, __label_info);

static void __label_info_init(__label_info *__p)
{
    buffer_new(&__p->title);
}

static void __label_info_clear(__label_info *__p)
{
    release(__p->title.iobj);
}

/*
 * alert action info
 */
local_type(action_info);

typedef struct
{
    buffer title;
    float x;
    float y;
}
__action_info;

make_local_type(action_info, __action_info);

static void __action_info_init(__action_info *__p)
{
    buffer_new(&__p->title);
}

static void __action_info_clear(__action_info *__p)
{
    release(__p->title.iobj);
}

/*
 * alert info
 */
local_type(alert_info);

typedef struct
{
    buffer title;
    array actions;
    array labels;
    u64 last_time;
}
__alert_info;

make_local_type(alert_info, __alert_info);

static void __alert_info_init(__alert_info *__p)
{
    buffer_new(&__p->title);
    array_new(&__p->actions);
    array_new(&__p->labels);
    __p->last_time = 0;
}

static void __alert_info_clear(__alert_info *__p)
{
    release(__p->title.iobj);
    release(__p->actions.iobj);
    release(__p->labels.iobj);
    __p->last_time = 0;
}

static buffer buf = {id_null};

#define MAX_ALERT 2

static alert_info infos[MAX_ALERT] = {(alert_info){id_null}, (alert_info){id_null}};
static alert_info infos_temp[MAX_ALERT] = {(alert_info){id_null}, (alert_info){id_null}};

static void __attribute__((constructor)) __in()
{
    buffer_new(&buf);
    int i;
    for (i = 0; i < sizeof(infos) / sizeof(infos[0]); ++i) {
        alert_info_new(&infos[i]);
        alert_info_new(&infos_temp[i]);
    }
}

static void __attribute__((destructor)) __out()
{
    // release(buf.iobj);

    // int i;
    // for (i = 0; i < sizeof(infos) / sizeof(infos[0]); ++i) {
    //     release(infos[i].iobj);
    //     release(infos_temp[i].iobj);
    // }
}

CFDataRef springboard_handle_alert(const __wiiauto_event_alert *input)
{

    const char *ptr = NULL;
    u32 len;
    
    len = strlen(input->text);
    if (len > sizeof(input->text)) {
        len = sizeof(input->text);
    }
    buffer_append(buf, input->text, len);

    if (input->complete) {

        buffer_get_ptr(buf, &ptr);

        @try {
            UIAlertController *alertController = [UIAlertController
                                alertControllerWithTitle:@"Title"
                                message:[NSString stringWithUTF8String: ptr]
                                preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction 
                actionWithTitle:@"OK"
                        style:UIAlertActionStyleDefault
                        handler:^(UIAlertAction *action)
                        {
                        }];
            [alertController addAction:okAction];
            [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertController animated:YES completion:nil];

        } @catch (NSException *e) {

        }
        buffer_erase(buf);
    }

    return NULL;
}

CFDataRef springboard_handle_alert_on_add_title(const __wiiauto_event_alert_on_add_title *input)
{
    int priority = input->priority;
    priority = priority >= MAX_ALERT ? (MAX_ALERT - 1) : priority;

    __alert_info *__info;

    alert_info_fetch(infos_temp[priority], &__info);

    buffer_erase(__info->title);
    buffer_append(__info->title, input->title, strlen(input->title));

    return NULL;
}

CFDataRef springboard_handle_alert_on_add_action(const __wiiauto_event_alert_on_add_action *input)
{
    int priority = input->priority;
    priority = priority >= MAX_ALERT ? (MAX_ALERT - 1) : priority;

    __alert_info *__info;
    action_info ai;
    __action_info *__ai;

    alert_info_fetch(infos_temp[priority], &__info);

    action_info_new(&ai);
    action_info_fetch(ai, &__ai);
    buffer_append(__ai->title, input->title, strlen(input->title));
    __ai->x = input->x;
    __ai->y = input->y;

    array_push(__info->actions, ai.iobj);
    release(ai.iobj);

    return NULL;
}

CFDataRef springboard_handle_alert_on_add_label(const __wiiauto_event_alert_on_add_label *input)
{
    int priority = input->priority;
    priority = priority >= MAX_ALERT ? (MAX_ALERT - 1) : priority;

    __alert_info *__info;
    label_info ai;
    __label_info *__ai;

    alert_info_fetch(infos_temp[priority], &__info);

    label_info_new(&ai);
    label_info_fetch(ai, &__ai);
    buffer_append(__ai->title, input->title, strlen(input->title));
    __ai->x = input->x;
    __ai->y = input->y;

    array_push(__info->labels, ai.iobj);
    release(ai.iobj);

    return NULL;
}

CFDataRef springboard_handle_alert_begin_commit(const __wiiauto_event_alert_begin_commit *input)
{
    int priority = input->priority;
    priority = priority >= MAX_ALERT ? (MAX_ALERT - 1) : priority;

    __alert_info *__info;

    alert_info_fetch(infos_temp[priority], &__info);
    buffer_erase(__info->title);
    array_remove_all(__info->actions);
    array_remove_all(__info->labels);

    return NULL;
}

CFDataRef springboard_handle_alert_end_commit(const __wiiauto_event_alert_end_commit *input)
{
    int priority = input->priority;
    priority = priority >= MAX_ALERT ? (MAX_ALERT - 1) : priority;

    __alert_info *__info;

    alert_info_fetch(infos_temp[priority], &__info);
    __info->last_time = current_timestamp();

    release(infos[priority].iobj);
    infos[priority] = infos_temp[priority];

    alert_info_new(&infos_temp[priority]);

    return NULL;
}

// CFDataRef springboard_handle_alert_off(const __wiiauto_event_alert_off *input)
// {
//     __alert_info *__info;

//     alert_info_fetch(info, &__info);
//     buffer_erase(__info->title);
//     array_remove_all(__info->actions);
//     array_remove_all(__info->labels);

//     return NULL;
// }

CFDataRef springboard_handle_alert_request_has_alert(const __wiiauto_event_alert_request_has_alert *input)
{
    u64 tm = current_timestamp();
    int i, priority;
    __alert_info *__info;
    __wiiauto_event_alert_result_has_alert rt;
    __wiiauto_event_alert_result_has_alert_init(&rt);

    priority = -1;
    for (i = 0; i < MAX_ALERT; ++i) {

        alert_info_fetch(infos[i], &__info);
        if (tm - __info->last_time <= 1000) {
            priority = i;
            break;
        }
    }

    rt.priority = priority;
    return CFDataCreate(NULL, (const UInt8 *)&rt, sizeof(rt));
}

CFDataRef springboard_handle_alert_request_title(const __wiiauto_event_alert_request_title *input)
{
    int priority = input->priority;
    priority = priority >= MAX_ALERT ? (MAX_ALERT - 1) : priority;

    __alert_info *__info;
    __wiiauto_event_alert_result_title rt;
    const char *ptr = NULL;
    i32 i;
    label_info li;
    __label_info *__li;
    f32 y_top = 100000;
    __wiiauto_event_alert_result_title_init(&rt);

    alert_info_fetch(infos[priority], &__info);
    buffer_get_ptr(__info->title, &ptr);

    if (!ptr || ptr[0] == '\0') {

        i = 0;
        array_get(__info->labels, i, &li.iobj);
        while (id_validate(li.iobj)) {

            label_info_fetch(li, &__li);

            if (__li->y <= y_top) {
                buffer_get_ptr(__li->title, &ptr);
                y_top = __li->y;
            }

            i++;
            array_get(__info->labels, i, &li.iobj);
        }
    }

    strcpy(rt.title, ptr);

    return CFDataCreate(NULL, (const UInt8 *)&rt, sizeof(rt));
}

CFDataRef springboard_handle_alert_request_action(const __wiiauto_event_alert_request_action *input)
{
    int priority = input->priority;
    priority = priority >= MAX_ALERT ? (MAX_ALERT - 1) : priority;

    __alert_info *__info;
    action_info ai;
    __action_info *__ai;
    __wiiauto_event_alert_result_action rt;
    u32 len;
    const char *ptr;

    __wiiauto_event_alert_result_action_init(&rt);

    alert_info_fetch(infos[priority], &__info);
    array_get_size(__info->actions, &len);
    if (len <= input->index) {
        goto finish;
    }

    array_get(__info->actions, input->index, &ai.iobj);
    action_info_fetch(ai, &__ai);
    buffer_get_ptr(__ai->title, &ptr);
    strcpy(rt.title, ptr);
    rt.x = __ai->x;
    rt.y = __ai->y;
    rt.success = 1;

finish:
    return CFDataCreate(NULL, (const UInt8 *)&rt, sizeof(rt));
}

CFDataRef springboard_handle_alert_request_label(const __wiiauto_event_alert_request_label *input)
{
    int priority = input->priority;
    priority = priority >= MAX_ALERT ? (MAX_ALERT - 1) : priority;

    __alert_info *__info;
    label_info ai;
    __label_info *__ai;
    __wiiauto_event_alert_result_label rt;
    u32 len;
    const char *ptr;

    __wiiauto_event_alert_result_label_init(&rt);

    alert_info_fetch(infos[priority], &__info);
    array_get_size(__info->labels, &len);
    if (len <= input->index) {
        goto finish;
    }

    array_get(__info->labels, input->index, &ai.iobj);
    label_info_fetch(ai, &__ai);
    buffer_get_ptr(__ai->title, &ptr);
    strcpy(rt.title, ptr);
    rt.x = __ai->x;
    rt.y = __ai->y;
    rt.success = 1;

finish:
    return CFDataCreate(NULL, (const UInt8 *)&rt, sizeof(rt));
}
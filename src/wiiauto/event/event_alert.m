#include "event_alert.h"

/*
 * alert
 */
make_wiiauto_event(__wiiauto_event_alert);

static void __wiiauto_event_alert_init_content(__wiiauto_event_alert *__p)
{
    __p->text[0] = '\0';
    __p->complete = 1;
}  

/*
 * alert on add title
 */
make_wiiauto_event(__wiiauto_event_alert_on_add_title);

static void __wiiauto_event_alert_on_add_title_init_content(__wiiauto_event_alert_on_add_title *__p)
{
    __p->title[0] = '\0';
    __p->priority = 0;
}  

/*
 * alert on add action
 */
make_wiiauto_event(__wiiauto_event_alert_on_add_action);

static void __wiiauto_event_alert_on_add_action_init_content(__wiiauto_event_alert_on_add_action *__p)
{
    __p->title[0] = '\0';
    __p->x = 0;
    __p->y = 0;
    __p->priority = 0;
}  

/*
 * alert on add label
 */
make_wiiauto_event(__wiiauto_event_alert_on_add_label);

static void __wiiauto_event_alert_on_add_label_init_content(__wiiauto_event_alert_on_add_label *__p)
{
    __p->title[0] = '\0';
    __p->x = 0;
    __p->y = 0;
    __p->priority = 0;
}  

/*
 * alert
 */
make_wiiauto_event(__wiiauto_event_alert_begin_commit);

static void __wiiauto_event_alert_begin_commit_init_content(__wiiauto_event_alert_begin_commit *__p)
{
    __p->priority = 0;
}  

make_wiiauto_event(__wiiauto_event_alert_end_commit);

static void __wiiauto_event_alert_end_commit_init_content(__wiiauto_event_alert_end_commit *__p)
{
    __p->priority = 0;
}  

/* request result */
make_wiiauto_event(__wiiauto_event_alert_request_has_alert);

static void __wiiauto_event_alert_request_has_alert_init_content(__wiiauto_event_alert_request_has_alert *__p)
{
    
}

make_wiiauto_event(__wiiauto_event_alert_result_has_alert);

static void __wiiauto_event_alert_result_has_alert_init_content(__wiiauto_event_alert_result_has_alert *__p)
{
    __p->priority = -1;
}


make_wiiauto_event(__wiiauto_event_alert_request_title);

static void __wiiauto_event_alert_request_title_init_content(__wiiauto_event_alert_request_title *__p)
{
    __p->priority = 0;
}

make_wiiauto_event(__wiiauto_event_alert_result_title);

static void __wiiauto_event_alert_result_title_init_content(__wiiauto_event_alert_result_title *__p)
{
    __p->title[0] = '\0';
}

make_wiiauto_event(__wiiauto_event_alert_request_action);

static void __wiiauto_event_alert_request_action_init_content(__wiiauto_event_alert_request_action *__p)
{
    __p->index = 0;
    __p->priority = 0;
}

make_wiiauto_event(__wiiauto_event_alert_result_action);

static void __wiiauto_event_alert_result_action_init_content(__wiiauto_event_alert_result_action *__p)
{
    __p->success = 0;
    __p->title[0] = '\0';
    __p->x = 0;
    __p->y = 0;
}


make_wiiauto_event(__wiiauto_event_alert_request_label);

static void __wiiauto_event_alert_request_label_init_content(__wiiauto_event_alert_request_label *__p)
{
    __p->index = 0;
    __p->priority = 0;
}

make_wiiauto_event(__wiiauto_event_alert_result_label);

static void __wiiauto_event_alert_result_label_init_content(__wiiauto_event_alert_result_label *__p)
{
    __p->success = 0;
    __p->title[0] = '\0';
    __p->x = 0;
    __p->y = 0;
}
#include "set_status_bar.h"
#include "wiiauto/common/common.h"
#include "cherry/core/buffer.h"
#include "log/remote_log.h"
#include "../springboard.h"

static buffer buf = {id_null};

// static void __attribute__((constructor)) __in()
// {
//     buffer_new(&buf);
// }

static void __attribute__((destructor)) __out()
{
    // release(buf.iobj);
}

static springboard_set_status_bar_delegate __delegate__ = NULL;
static springboard_set_status_bar_state_delegate __delegate_state__ = NULL;

CFDataRef springboard_handle_set_status_bar(const __wiiauto_event_set_status_bar *input)
{
    const char *ptr = NULL;
    u32 len;

    if (!id_validate(buf.iobj)) {
        buffer_new(&buf);
    }
    
    len = strlen(input->text);
    if (len > sizeof(input->text)) {
        len = sizeof(input->text);
    }
    buffer_append(buf, input->text, len);

    if (input->complete) {

        buffer_get_ptr(buf, &ptr);

        if (__delegate__) {
            __delegate__(ptr);
        }

        buffer_erase(buf);
    }

    return NULL;
}

CFDataRef springboard_handle_set_status_bar_state(const __wiiauto_event_set_status_bar_state *input)
{
    if (__delegate_state__) {
        __delegate_state__(input->visible);
    }

    return NULL;
}

void springboard_init_status_bar_delegate(
    const springboard_set_status_bar_delegate delegate,
    const springboard_set_status_bar_state_delegate delegate_state)
{
    __delegate__ = delegate;
    __delegate_state__ = delegate_state;
}
#include "screen_buffer_path.h"
#include <sys/time.h>

static char __path__[1024];
static int __init__ = 0;
static u64 __timestamp__ = 0;

static u64 current_timestamp() 
{
    struct timeval te; 
    gettimeofday(&te, NULL);
    u64 milliseconds = te.tv_sec*1000LL + te.tv_usec/1000;
    return milliseconds;
}

const char *springboard_get_screen_buffer_path()
{
    if (!__init__) {
        __init__ = 1;
        __timestamp__ = current_timestamp();

        // sprintf(__path__, "/shared_%llu", current_timestamp());
        sprintf(__path__, "/shared_screenbuffer");
    }

    return __path__;
}

CFDataRef springboard_handle_request_screen_buffer_path(const __wiiauto_event_request_screen_buffer_path *input)
{
    __wiiauto_event_result_screen_buffer_path evt;
    __wiiauto_event_result_screen_buffer_path_init(&evt);

    const char *path = springboard_get_screen_buffer_path();

    strcpy(evt.path, path);
    evt.timestamp = __timestamp__;

    return CFDataCreate(NULL, (const UInt8 *)&evt, sizeof(evt));
}
#include "append_text.h"
// #include "wiiauto/device/device.h"
// #include "wiiauto/common/common.h"
// #include "cherry/core/buffer.h"
// #include "log/remote_log.h"
// #include "wiiauto/device/device_gs.h"
// #include "wiiauto/springboard/springboard.h"
// #include "wiiauto/event/event_register_app.h"

// static buffer buf = {id_null};

static void __in()
{
    // if (!id_validate(buf.iobj)) {
    //     buffer_new(&buf);
    // }
}

static void __attribute__((destructor)) __out()
{
    // release(buf.iobj);
}

CFDataRef backboardd_handle_append_text(const __wiiauto_event_append_text *input)
{
//     __in();
    
//     int port;
//     const char *ptr;
//     u32 len;

//     common_get_front_most_app_port(&port);
//     if (!port) goto finish;
    
//     len = strlen(input->text);
//     if (len > sizeof(input->text)) {
//         len = sizeof(input->text);
//     }
//     buffer_append(buf, input->text, len);

//     if (input->complete) {

//         buffer_get_ptr(buf, &ptr);

//         __wiiauto_event_register_app ra;

//         __wiiauto_event_register_app_init(&ra);
//         strcpy(ra.bundle, "test");
//         wiiauto_send_event_uncheck_return(1, &ra, sizeof(ra), SPRINGBOARD_MACH_PORT_NAME);

//         wiiauto_device_gs_post_character(1, 'a', port);
//         wiiauto_device_gs_post_character(0, 'a', port);

//         buffer_erase(buf);
//     }

// finish:
    return NULL;
}
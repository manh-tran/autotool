#include "open_url.h"
#include "wiiauto/common/common.h"
#include "cherry/core/buffer.h"

static buffer buf = {id_null};

// static void __attribute__((constructor)) __in()
// {
//     buffer_new(&buf);
// }

static void __attribute__((destructor)) __out()
{
    // release(buf.iobj);
}

CFDataRef springboard_handle_open_url(const __wiiauto_event_open_url *input)
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

        @try {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithUTF8String:ptr]]];
        } @catch (NSException *e) {
            
        }
        
        buffer_erase(buf);
    }

    return NULL;
}
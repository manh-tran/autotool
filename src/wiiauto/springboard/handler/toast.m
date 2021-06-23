#include "toast.h"
#include "wiiauto/common/common.h"
#include "cherry/core/buffer.h"
#import "vendor/MBProgressHUD.h"
#include "log/remote_log.h"

static buffer buf = {id_null};

// static void __attribute__((constructor)) __in()
// {
//     buffer_new(&buf);
// }

static void __attribute__((destructor)) __out()
{
    // release(buf.iobj);
}

CFDataRef springboard_handle_toast(const __wiiauto_event_toast *input)
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

        NSString *text = [NSString stringWithUTF8String:ptr];
        float delay = input->delay;

        @try {
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[[[UIApplication sharedApplication] keyWindow] rootViewController].view animated:YES];
            hud.mode = MBProgressHUDModeText;
            hud.label.text = text;
            hud.margin = 10.f;
            hud.removeFromSuperViewOnHide = YES;
            hud.userInteractionEnabled = false;
            hud.offset = CGPointMake(0, 250);
            [hud hideAnimated:YES afterDelay:delay];
            hud = nil;
        } @catch(NSException *e) {

        }

        
        
        buffer_erase(buf);
    }

    return NULL;
}
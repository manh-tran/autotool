#include "app.h"
// #include "rocketbootstrap/rocketbootstrap.h"
#include "wiiauto/event/event.h"
#include "wiiauto/device/device.h"

// void app_get_handler(const __wiiauto_event *data, wiiauto_event_delegate *del);

// static CFDataRef callback(CFMessagePortRef local, SInt32 msgid, CFDataRef cfData, void *info) 
// {
//     wiiauto_event_delegate del;

//     const __wiiauto_event *data = (const __wiiauto_event *) CFDataGetBytePtr(cfData);
//     app_get_handler(data, &del);

//     if (del) {
//         return del(data);
//     } else {
//         return NULL;
//     }

//     return NULL;
// }

// static void setup_match_port(const char *name)
// {
//     CFStringRef ssr = CFStringCreateWithCString(NULL, name, kCFStringEncodingUTF8);
//     CFMessagePortRef local = CFMessagePortCreateLocal(NULL, ssr, callback, NULL, NULL);

//     if (!local) goto finish;

//     CFRunLoopSourceRef source = CFMessagePortCreateRunLoopSource(NULL, local, 0);
//     if (!source) goto finish;

//     CFRunLoopAddSource(CFRunLoopGetCurrent(), source, kCFRunLoopCommonModes);
//     rocketbootstrap_cfmessageportexposelocal(local);

// finish:
//     CFRelease(ssr);
// }

void app_init()
{
    // buffer b;
    // const char *bundle, *msp;
    // NSString *idr = nil;

    // @try {
    //     idr = [[NSBundle mainBundle] bundleIdentifier];
    // } @catch (NSException *e) {
    //     idr = nil;
    // }

    // if (!idr) return;

    // bundle = [idr UTF8String];
    // if (strlen(bundle) == 0) return;

    // buffer_new(&b);
    // app_fill_message_port_name(bundle, b);
    // buffer_get_ptr(b, &msp);
    // setup_match_port(msp);
    // release(b.iobj);
}

void app_fill_message_port_name(const char *bundle, const buffer b)
{
    buffer_erase(b);
    buffer_append(b, bundle, strlen(bundle));
    buffer_append(b, ".wiiautohelper", strlen(".wiiautohelper"));
}
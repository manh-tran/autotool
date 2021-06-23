#include "backboardd.h"
// #include "rocketbootstrap/rocketbootstrap.h"
#include "wiiauto/event/event.h"
#include "wiiauto/device/device.h"

// static spin_lock __barrier__ = 0;

// void backboardd_get_handler(const __wiiauto_event *data, wiiauto_event_delegate *del);

// static CFDataRef callback(CFMessagePortRef local, SInt32 msgid, CFDataRef cfData, void *info) 
// {
//     lock(&__barrier__);

//     wiiauto_event_delegate del;
//     CFDataRef ref = NULL;

//     const __wiiauto_event *data = (const __wiiauto_event *) CFDataGetBytePtr(cfData);
//     backboardd_get_handler(data, &del);

//     if (del) {
//         ref = del(data);
//     }

//     if (!ref) {
//         __wiiauto_event_null evt;
//         __wiiauto_event_null_init(&evt);
//         ref = CFDataCreate(NULL, (const UInt8 *)&evt, sizeof(evt));
//     }

//     unlock(&__barrier__);
//     return ref;
// }

// static void setup_match_port()
// {
//     CFMessagePortRef local = CFMessagePortCreateLocal(NULL, CFSTR(BACKBOARDD_MACH_PORT_NAME), callback, NULL, NULL);
//     if (!local) return;

//     CFRunLoopSourceRef source = CFMessagePortCreateRunLoopSource(NULL, local, 0);
//     if (!source) return;
    
//     CFRunLoopAddSource(CFRunLoopGetCurrent(), source, kCFRunLoopCommonModes);
//     rocketbootstrap_cfmessageportexposelocal(local);
// }

void backboardd_init()
{
    // setup_match_port();
}
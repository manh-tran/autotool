#include "handler.h"

extern CFTypeRef MGCopyAnswer(CFStringRef);

void wiiauto_tool_run_get_mgcopyanswer(const int argc, const char **argv)
{
    if (argc < 3) return;

    CFTypeRef t = MGCopyAnswer((__bridge CFStringRef)[NSString stringWithUTF8String:argv[2]]);
    if (t) {
        NSLog(@"mg: %@", (__bridge NSString *)t);
        CFRelease(t);
    }
}
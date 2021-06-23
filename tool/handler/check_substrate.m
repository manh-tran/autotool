#include "handler.h"
#include <stdio.h>
#import "wiiauto/watcher.h"

void wiiauto_tool_run_check_substrate(const int argc, const char **argv)
{
    WiiAutoWatcher *obj = [[WiiAutoWatcher alloc] init];

    BOOL jb = [obj is_jailbreaking];

    if (!jb) {
        printf("false\n");
    } else {
        printf("true\n");
    }

    obj = nil;
}
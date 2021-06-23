#include "handler.h"

void wiiauto_tool_run_get_app_group(const int argc, const char **argv)
{
    if (argc >= 3) {
        @try
        {
            NSURL *fileManagerURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:[NSString stringWithUTF8String:argv[2]]];
            if (fileManagerURL) {
                NSString *tmpPath = [NSString stringWithFormat:@"%@", fileManagerURL.path];
                if (tmpPath) {
                    printf("%s", [tmpPath UTF8String]);
                }
            } else {
            }
        } @catch (NSException *e) {

        }
    }
}
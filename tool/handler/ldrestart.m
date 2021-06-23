#include "handler.h"

void wiiauto_tool_run_ldrestart(const int argc, const char **argv)
{
    signal(SIGINT, SIG_IGN);
    signal(SIGTERM, SIG_IGN);
    signal(SIGKILL, SIG_IGN);

    // system("/bin/launchctl unload /System/Library/LaunchDaemons/com.apple.backboardd.plist && ldrestart && /bin/launchctl load /System/Library/LaunchDaemons/com.apple.backboardd.plist &");
    system("ldrestart &");
}
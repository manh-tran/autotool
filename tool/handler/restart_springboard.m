#include "handler.h"

void wiiauto_tool_run_restart_springboard(const int argc, const char **argv)
{
    signal(SIGINT, SIG_IGN);
    signal(SIGTERM, SIG_IGN);
    signal(SIGKILL, SIG_IGN);

    // system("/bin/launchctl unload /System/Library/LaunchDaemons/com.apple.backboardd.plist && ldrestart && /bin/launchctl load /System/Library/LaunchDaemons/com.apple.backboardd.plist &");
    system("killall -9 SpringBoard &");
}
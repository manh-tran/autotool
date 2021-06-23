#include "handler.h"

void wiiauto_tool_run_update_package(const int argc, const char **argv)
{
    signal(SIGINT, SIG_IGN);
    signal(SIGTERM, SIG_IGN);
    signal(SIGKILL, SIG_IGN);

    if (argc >= 3) {
        char buf[2048];

        sprintf(buf, "/bin/launchctl unload /Library/LaunchDaemons/com.wiimob.wiiauto.plist && dpkg -i %s && killall -9 SpringBoard &", argv[2]);
        system(buf);
        
    } else {
        system("/bin/launchctl unload /Library/LaunchDaemons/com.wiimob.wiiauto.plist && dpkg -i /private/var/mobile/Downloads/temp.deb && killall -9 SpringBoard &");
    }    
}
#include "handler.h"
#include <sys/sysctl.h>

void wiiauto_tool_run_check_uptime(const int argc, const char **argv)
{
    struct timeval boottime;
    int mib[2] = {CTL_KERN, KERN_BOOTTIME};
    size_t size = sizeof(boottime);
    time_t now;
    time_t uptime = -1;

    (void)time(&now);

    if (sysctl(mib, 2, &boottime, &size, NULL, 0) != -1 && boottime.tv_sec != 0) {
        uptime = now - boottime.tv_sec;
    }

    printf("%lu\n", uptime);
}
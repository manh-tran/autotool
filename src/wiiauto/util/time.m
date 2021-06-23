#include "util.h"
#include <sys/sysctl.h>

time_t wiiauto_util_get_uptime()
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

    return uptime;
}

time_t wiiauto_util_get_boottime()
{
    struct timeval boottime;
    int mib[2] = {CTL_KERN, KERN_BOOTTIME};
    size_t size = sizeof(boottime);

    sysctl(mib, 2, &boottime, &size, NULL, 0);

    return boottime.tv_sec;
}
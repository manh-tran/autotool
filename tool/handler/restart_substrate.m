#include "handler.h"
#include "cherry/def.h"
#include "cherry/util/util.h"

static void __kill_execute()
{
    i32 num[2];
    char buf[1024];
    i32 exec_pid = -1;

    FILE *fp = popen("ps -u root | grep /usr/bin/wiiauto_run", "r");
    if (fp) {
        while (fgets(buf, 1024, fp) != NULL) {
            if (!strstr(buf, "grep") && !strstr(buf, "refresh") && !strstr(buf, "update_package")) {
                if (strstr(buf, "daemon_execute")) {
                    util_strtovl(2, buf, num);
                    exec_pid = num[1];
                }                
            }
        }
        pclose(fp);
    }

    if (exec_pid >= 0) {
        sprintf(buf, "kill -9 %d", exec_pid);
        system(buf);    
    }
}

void wiiauto_tool_run_restart_substrate(const int argc, const char **argv)
{
    signal(SIGINT, SIG_IGN);
    signal(SIGTERM, SIG_IGN);
    signal(SIGKILL, SIG_IGN);

    __kill_execute();

    system("/etc/rc.d/substrate && killall -9 SpringBoard &");
}
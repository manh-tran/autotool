#include "handler.h"
#include "cherry/core/buffer.h"
#include "cherry/util/util.h"

void wiiauto_tool_run_refresh(const int argc, const char **argv)
{
    i32 num[2], pid;
    char buf[1024];
    buffer pb;
    u32 pb_len;
    i32 exec_pid = -1;
    int i;

    buffer_new(&pb);

    FILE *fp = popen("ps -u root | grep /usr/bin/wiiauto_run", "r");
    if (fp) {
        while (fgets(buf, 1024, fp) != NULL) {
            if (!strstr(buf, "grep") && !strstr(buf, "refresh") && !strstr(buf, "update_package")) {
                if (strstr(buf, "daemon_execute")) {
                    util_strtovl(2, buf, num);
                    exec_pid = num[1];
                } else {
                    util_strtovl(2, buf, num);
                    buffer_append(pb, &num[1], sizeof(i32));
                }                   
            }
        }
        pclose(fp);
    }

    if (exec_pid >= 0) {
        sprintf(buf, "kill -9 %d", exec_pid);
        system(buf);    
    }

    buffer_length(pb, sizeof(i32), &pb_len);
    for (i = 0; i < pb_len; ++i) {
        buffer_get(pb, sizeof(i32), i, &pid);
        sprintf(buf, "kill -9 %d", pid);
        system(buf);    
    }

    release(pb.iobj);
}
#include "handler.h"
#include "log/remote_log.h"
#include "wiiauto/common/common.h"
#include "wiiauto/daemon/daemon.h"
#include "cherry/util/util.h"
#import "wiiauto/watcher.h"

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

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
        sprintf(buf, "kill -9 %d  ", exec_pid);
        system(buf);    
    }
}

// void wiiauto_clear_account();

void wiiauto_tool_run_daemon_execute(const int argc, const char **argv)
{    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"11.0")) {
        __kill_execute();
        system("chmod 777 /var/mobile/Library/WiiAuto");
        system("chmod 777 /var/mobile/Library/WiiAuto/Scripts");
        system("chmod 777 /var/mobile/Library/WiiAuto/Databases");
        system("uicache --path /Applications/WiiAuto.app &");

        [[NSUserDefaults standardUserDefaults] setObject:[NSArray arrayWithObjects:@"en", nil] 
            forKey:@"AppleLanguages"]; 
        [[NSUserDefaults standardUserDefaults] synchronize]; 

        wiiauto_tool_register();
        daemon_init_first();

        int memorystatus_control(uint32_t command, int32_t pid, uint32_t flags, void *buffer, size_t buffersize);
        memorystatus_control(5, getpid(), 512, 0, 0);

        remote_log_set_enable(1);
        remote_log_set_process("daemon");

        int turn = 0;
        int round = 0;
        u8 r = 0;
        int32_t spid;
    check_springboard_running:
        common_is_springboard_running(&r, &spid);
        if (!r) {
            turn++;
            if (turn >= 300) {
                round++;
                if (round >= 2) {
                    kill(getpid(), SIGKILL);
                    // system("/usr/libexec/substrate && killall -9 SpringBoard");
                } else {
                    WiiAutoWatcher *obj = [[WiiAutoWatcher alloc] init];
                    BOOL jb = [obj is_jailbreaking];
                    if (!jb) {
                        system("/usr/libexec/substrate");
                        usleep(3 * 1000000);
                    }
                    system("killall -9 SpringBoard");
                    obj = nil;
                }
                
                turn = 0;
            }
            usleep(1 * 1000 * 1000);
            goto check_springboard_running;
        }

        memorystatus_control(5, spid, 1024, 0, 0);
        
        daemon_init();
    }
    CFRunLoopRun();
}
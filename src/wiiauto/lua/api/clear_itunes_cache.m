#include "api.h"
#include "cherry/util/util.h"
#include "wiiauto/daemon/daemon.h"
#include "wiiauto/daemon/handler/set_timer.h"

static void __kill_atc()
{
    i32 num[2];
    char buf[1024];
    i32 exec_pid = -1;

    FILE *fp = popen("ps -u mobile | grep /usr/libexec/atc", "r");
    if (fp) {
        while (fgets(buf, 1024, fp) != NULL) {
            if (!strstr(buf, "grep")) {
                util_strtovl(2, buf, num);
                exec_pid = num[1];  
                break;           
            }
        }
        pclose(fp);
    }

    if (exec_pid >= 0) {
        sprintf(buf, "kill -9 %d  ", exec_pid);
        system(buf);    
    }
}

static void __kill_mediaserverd()
{
    i32 num[2];
    char buf[1024];
    i32 exec_pid = -1;

    FILE *fp = popen("ps -u mobile | grep mediaserverd", "r");
    if (fp) {
        while (fgets(buf, 1024, fp) != NULL) {
            if (!strstr(buf, "grep")) {
                util_strtovl(2, buf, num);
                exec_pid = num[1];  
                break;           
            }
        }
        pclose(fp);
    }

    if (exec_pid >= 0) {
        sprintf(buf, "kill -9 %d  ", exec_pid);
        system(buf);    
    }
}


static void __kill_fairplayd()
{
    i32 num[2];
    char buf[1024];
    i32 exec_pid = -1;

    FILE *fp = popen("ps -u mobile | grep fairplayd", "r");
    if (fp) {
        while (fgets(buf, 1024, fp) != NULL) {
            if (!strstr(buf, "grep")) {
                util_strtovl(2, buf, num);
                exec_pid = num[1];  
                break;           
            }
        }
        pclose(fp);
    }

    if (exec_pid >= 0) {
        sprintf(buf, "kill -9 %d  ", exec_pid);
        system(buf);    
    }
}

static void __kill_storekituiservice()
{
    i32 num[2];
    char buf[1024];
    i32 exec_pid = -1;

    FILE *fp = popen("ps -u mobile | grep StoreKitUIService", "r");
    if (fp) {
        while (fgets(buf, 1024, fp) != NULL) {
            if (!strstr(buf, "grep")) {
                util_strtovl(2, buf, num);
                exec_pid = num[1];  
                break;           
            }
        }
        pclose(fp);
    }

    if (exec_pid >= 0) {
        sprintf(buf, "kill -9 %d  ", exec_pid);
        system(buf);    
    }
}

static void __kill_nsurlsessiond()
{
    i32 num[2];
    char buf[1024];
    i32 exec_pid = -1;

    FILE *fp = popen("ps -u mobile | grep nsurlsessiond", "r");
    if (fp) {
        while (fgets(buf, 1024, fp) != NULL) {
            if (!strstr(buf, "grep")) {
                util_strtovl(2, buf, num);
                exec_pid = num[1];  
                break;           
            }
        }
        pclose(fp);
    }

    if (exec_pid >= 0) {
        sprintf(buf, "kill -9 %d  ", exec_pid);
        system(buf);    
    }
}

int wiiauto_lua_clear_itunes_cache(lua_State *ls)
{
    int r;

    r = luaL_optinteger(ls, 1, 0);

    system("rm -rf /private/var/mobile/Library/Caches/com.apple.iTunesCloud/URLBags  "); 
    system("launchctl unload /System/Library/LaunchDaemons/com.apple.itunescloudd.plist  ");
    system("launchctl load /System/Library/LaunchDaemons/com.apple.itunescloudd.plist  ");
    __kill_atc();
    __kill_mediaserverd();
    __kill_fairplayd();
    __kill_nsurlsessiond();
    
    system("killall -9 SpringBoard  ");

    if (r && !__download_package__) {
        usleep(1000000);

        lock(&__timer_barrier__);
        kill(getpid(), SIGKILL);
        unlock(&__timer_barrier__);
    }    

finish:
    return 0;
}
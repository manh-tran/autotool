#include "handler.h"
#include "wiiauto/common/common.h"
#include "cherry/json/json.h"
#include "wiiauto/daemon/daemon.h"
#include "log/remote_log.h"
#include "cherry/util/util.h"

static dispatch_queue_t alive_queue;
static dispatch_queue_t checksubstrate_queue;
static u8 check_execute = 1;
static int substrate_cd = 0;

// #include <CoreFoundation/CoreFoundation.h>
// #include <IOKit/IOKit.h>

// static void disable_watchdog() 
// {
// 	CFMutableDictionaryRef matching;
// 	io_service_t service = 0;
// 	uint32_t zero = 0;
// 	CFNumberRef n;

// 	matching = IOServiceMatching("IOWatchDogTimer");
// 	service = IOServiceGetMatchingService(kIOMasterPortDefault, matching);
// 	n = CFNumberCreate(kCFAllocatorDefault, kCFNumberIntType, &zero);
	
//     IORegistryEntrySetCFProperties(service, n);

// 	IOObjectRelease(service);
// }

static void __do_check()
{
    u8 r;

    if (!check_execute) return;

    common_is_daemon_running(&r);
    if (r == 0) { 
        system("/usr/bin/wiiauto_run daemon_execute &");       
    }
}

static void __check()
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 10 * NSEC_PER_SEC), alive_queue, ^{
        
        __do_check();
        __check();     
    });
}

static void __first_check()
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC), alive_queue, ^{
        
        __do_check();   
    });
}

static void __check_substrate()
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), checksubstrate_queue, ^{        
        
        char buf[257];
        int r = 0;

        FILE *fp = popen("/usr/bin/wiiauto_run check_substrate;", "r");
        if (fp) {
            while (fgets(buf, 256, fp) != NULL) {
                buf[256] = '\0';
                
                if (strstr(buf, "true")) {
                    r = 0;
                    break;
                } else if (strstr(buf, "false")) {
                    r = 1;
                    wiiauto_device_sys_log("reload substrate\n");                    
                }
                __yield();
            }
            pclose(fp);
        }

        if (r) {
            substrate_cd++;
            if (substrate_cd == 10) {
                check_execute = 0;
                system("/usr/bin/wiiauto_run restart_substrate &"); 
                usleep(3000000);
                kill(getpid(), SIGKILL);
            } else {
                __check_substrate();    
            }           
        } else {
            substrate_cd = 0;
            __check_substrate();
        }        
    });
}

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
        sprintf(buf, "kill -9 %d", exec_pid);
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
        sprintf(buf, "kill -9 %d", exec_pid);
        system(buf);    
    }
}


void wiiauto_tool_run_daemon(const int argc, const char **argv)
{
    int memorystatus_control(uint32_t command, int32_t pid, uint32_t flags, void *buffer, size_t buffersize);
    memorystatus_control(5, getpid(), 512, 0, 0);

    alive_queue = dispatch_queue_create("com.wiimob.wiiauto.daemon_alive", NULL);
    checksubstrate_queue = dispatch_queue_create("com.wiimob.wiiauto.daemon_check_substrate", NULL);

    system("chmod 777 /var/mobile/Library/WiiAuto");
    system("chmod 777 /var/mobile/Library/WiiAuto/Scripts");
    system("uicache &");

    json_element e, e_restart;
    const char *str;
    json_element_new(&e);
    json_element_load_file(e, DAEMON_FILE_CACHE);

    json_object_require_string_default(e, "restart", &e_restart, "0");
    json_string_get_ptr(e_restart, &str);
    if (!str || strcmp(str, "3") != 0) {
        json_string_set(e_restart, "3");
        json_element_save_file(e, DAEMON_FILE_CACHE);
        
        system("rm -rf /private/var/mobile/Library/Caches/com.apple.iTunesCloud/URLBags"); 
        system("launchctl unload /System/Library/LaunchDaemons/com.apple.itunescloudd.plist");
        system("launchctl load /System/Library/LaunchDaemons/com.apple.itunescloudd.plist");
        __kill_atc();
        system("/usr/bin/wiiauto_run restart_springboard &"); 
    }
    release(e.iobj);

    __first_check();
    __check();
    // __check_substrate();
    CFRunLoopRun();
}
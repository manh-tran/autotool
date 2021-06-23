#include "daemon.h"
// #include "rocketbootstrap/rocketbootstrap.h"
#include "wiiauto/event/event.h"
#include "web/web.h"
#include "screenbuffer/screenbuffer.h"
#include "cherry/core/file.h"
#include "cherry/net/socket.h"
#include "wiiauto/device/device.h"
#include "wiiauto/common/common.h"
#include "log/remote_log.h"
#include <sys/mman.h>
#include "wiiauto/event/event_screen_buffer_path.h"
#include "wiiauto/springboard/springboard.h"
#include <sys/time.h>
#include "cherry/net/http_client.h"
#include "wiiauto/version.h"
#include "openssl/md5.h"
#include "wiiauto/intercom/intercom.h"
#include "wiiauto/watcher.h"
#include "wiiauto/lua/lua.h"
#include "cherry/util/util.h"
#include "cherry/json/json.h"
#include "wiiauto/util/util.h"
#include "wiiauto/daemon/handler/set_timer.h"
#include "wiiauto/device/device_db.h"

int __daemon_web_success__ = 0;
int __daemon_avaliable__ = 1;
int __daemon_auto_restart__ = 1;
int __daemon_auto_awake__ = 1;
int __download_package__ = 0;

static u64 current_timestamp() 
{
    struct timeval te; 
    gettimeofday(&te, NULL);
    u64 milliseconds = te.tv_sec*1000LL + te.tv_usec/1000;
    return milliseconds;
}

void daemon_get_handler(const __wiiauto_event *data, const u32 in_size, wiiauto_event_delegate *del);
void wiiauto_daemon_timer_init();

static dispatch_queue_t checkupdate_queue;
static dispatch_queue_t awake_queue;
static dispatch_queue_t restart_queue;
static dispatch_queue_t runtime_springboard_queue;
static http_client __http_client__ = {id_null};
static u8 __check_package__ = 0;
static u64 __restart_timestamp__ = 0;

static CFDataRef callback(CFMessagePortRef local, SInt32 msgid, CFDataRef cfData, void *info) 
{
    CFDataRef ref = NULL;
    u32 len;

    wiiauto_event_delegate del = NULL;

    len = CFDataGetLength(cfData);

    const __wiiauto_event *data = (const __wiiauto_event *) CFDataGetBytePtr(cfData);
    daemon_get_handler(data, len, &del);

    if (del) {
        ref = del(data);
    }

    if (!ref) {
        __wiiauto_event_null evt;
        __wiiauto_event_null_init(&evt);
        ref = CFDataCreate(NULL, (const UInt8 *)&evt, sizeof(evt));
    }

    return ref;
}

// static void setup_match_port()
// {
//     CFMessagePortRef local = CFMessagePortCreateLocal(NULL, CFSTR(DAEMON_MACH_PORT_NAME), callback, NULL, NULL);
//     if (!local) {
//         goto finish;
//     }

//     CFRunLoopSourceRef source = CFMessagePortCreateRunLoopSource(NULL, local, 0);
//     if (!source) {
//         goto finish;
//     }
    
//     CFRunLoopAddSource(CFRunLoopGetCurrent(), source, kCFRunLoopCommonModes);
//     rocketbootstrap_cfmessageportexposelocal(local);
//     ;
// finish:
//     ;
// }

static void __version_dump(const char *v, int num[10])
{
    char buf[128];
    const char *ptr;
    int i, j;

    for (i = 0; i < 10; ++i) {
        num[i] = 0;
    }

    ptr = v;
    i = 0;
    j = 0;
    while (*ptr) {
        if (isdigit(*ptr)) {
            buf[i] = *ptr;
            i++;
        } else {
            buf[i] = '\0';
            num[j] = atoi(buf);
            j++;
            i = 0;
            if (j == 10) break;
        }
        ptr++;
    }
    if (i > 0 && j < 10) {
        buf[i] = '\0';
        num[j] = atoi(buf);
    }
}

static void __parse_line(const char *line, const map package, u8 *valid)
{
    const char *str, *ptr, *etr;
    u32 len;

    buffer name, content;

    buffer_new(&name);
    buffer_new(&content);

    str = strstr(line, ":");
    if (str) {
        ptr = str - 1;
        while (ptr > str && isspace(*ptr)) {
            ptr--;
        }
        buffer_append(name, line, ptr - line + 1);

        ptr = str + 1;
        while (isspace(*ptr)) {
            ptr++;
        }
        len = strlen(line);
        etr = line + len - 1;
        while (etr > ptr && isspace(*etr)) {
            etr--;
        }
        buffer_append(content, ptr, etr - ptr + 1);

        buffer_get_ptr(name, &ptr);
        map_set(package, key_str(ptr), content.iobj);

        *valid = 1;
    } else {
        *valid = 0;
    }

    release(name.iobj);
    release(content.iobj);
}


static void __download_response(const map pkg, const buffer buf)
{
    u32 len, content_len;
    const char *ptr, *str, *ck_md5;
    unsigned char hash[MD5_DIGEST_LENGTH];
    char md5string[33];
    buffer b;
    file f;

    buffer_length(buf, 1, &len);
    buffer_get_ptr(buf, &ptr);

    str = strstr(ptr, "Content-Length:");
    if(str){
        sscanf(str,"%*s %d", &content_len);
    }

    if (content_len == 0 || len < content_len) {
        
        __download_package__ = 0;

        return;
    }

    str = ptr + len - 1 - content_len + 1;

    MD5((const unsigned char *)str, content_len, hash);
    memset(md5string, 0, 33);
    for(int i = 0; i < 16; ++i) {
        sprintf(&md5string[i*2], "%02x", (unsigned int)hash[i]);
    }

    map_get(pkg, key_str("MD5sum"), &b.iobj);
    if (id_validate(b.iobj)) {
        buffer_get_ptr(b, &ck_md5);
        if (strcmp(ck_md5, md5string) == 0) {

            file_new(&f);
            file_open_write(f, "/private/var/mobile/Downloads/temp.deb");
            file_write(f, str, content_len);
            release(f.iobj);

            usleep(1000000);

            system("/usr/bin/wiiauto_run update_package &");
        } else {
            __download_package__ = 0;
        }
    } else {
        __download_package__ = 0;
    }
}

static void __download_error(const iobj user)
{
    __download_package__ = 0;
}

static void __check_update_response(const iobj user, const buffer buf)
{
    const char *ptr, *str;
    const char *token;
    u8 state = 0;
    int pk1[10], pk2[10];
    int i;
    int update = 0;
    u8 valid;
    buffer package, version, md5sum, filename;
    map pkg;
    char link[1024];

    map_new(&pkg);

    buffer_get_ptr(buf, &ptr);

    while ((token = strsep(&ptr, "\n")) != NULL) {
        __parse_line(token, pkg, &valid);

        if (valid) {
            map_get(pkg, key_str("Package"), &package.iobj);
            map_get(pkg, key_str("Version"), &version.iobj);
            map_get(pkg, key_str("Filename"), &filename.iobj);
            map_get(pkg, key_str("MD5sum"), &md5sum.iobj);
            if (id_validate(package.iobj) && id_validate(version.iobj) && id_validate(filename.iobj) && id_validate(md5sum.iobj)) {     

                buffer_get_ptr(package, &str);
                if (strcmp(str, "com.wiimob.wiiauto") == 0) {
                    
                    buffer_get_ptr(version, &str);

                    __version_dump(str, pk1);
                    __version_dump(__wiiauto_version__, pk2);
                    
                    for (i = 0; i < 10; ++i) {
                        if (pk1[i] > pk2[i]) {
                            update = 1;
                            break;
                        }
                    }

                    goto check_update;
                }

            }
        } else {
            map_remove_all(pkg);
        }
    }

check_update:
    if (!update) goto finish;

    buffer_get_ptr(filename, &str);

    strcpy(link, "https://saruno.github.io/tweaks");
    if (str[0] != '/') {
        strcat(link, "/");
    }
    strcat(link, str);

    if (!__download_package__) {
        __download_package__ = 1;

        http_client_get(__http_client__, link, pkg.iobj, (__http_client_callback){
            .response = __download_response,
            .error = __download_error
        });
    }


finish:
    buffer_erase(buf);    
    release(pkg.iobj);
    __check_package__ = 0;
}

static void __check_update_error(const iobj user)
{
    __check_package__ = 0;
}

static void __check_update()
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC), checkupdate_queue, ^{
        
        if (!id_validate(__http_client__.iobj)) {
            http_client_new(&__http_client__);
        }
        if (!__check_package__) {
            __check_package__ = 1;

            http_client_get(__http_client__, "https://saruno.github.io/tweaks/Packages", __http_client__.iobj, (__http_client_callback){
                .response = __check_update_response,
                .error = __check_update_error
            });
        }

        __check_update();
        
    });
}


static void __require_file(const char *name)
{
    file f;
    char buf[1024];

    file_new(&f);
    file_open_append(f, name);
    release(f.iobj);

    sprintf(buf, "chmod 666 %s", name);

    system(buf);
}

static void __awake()
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC), awake_queue, ^{
        
        u32 count = 0;
        wiiauto_lua_get_current_running_scripts_count(&count);

        if (count > 0 && __daemon_auto_awake__) {
            common_undim_display();
        }
        __awake();
        
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
        sprintf(buf, "kill -9 %d", exec_pid);
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
        sprintf(buf, "kill -9 %d", exec_pid);
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
        sprintf(buf, "kill -9 %d", exec_pid);
        system(buf);    
    }
}

static void __schedule_restart()
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), restart_queue, ^{

        u32 count = 0;
        u64 cm = current_timestamp();
        if (cm - __restart_timestamp__ >= 1000 * 60 * 3) {

            wiiauto_lua_get_current_running_scripts_count(&count);
            if (count == 0 && __download_package__ == 0 && __daemon_auto_restart__) {

                __daemon_avaliable__ = 0; 
                system("rm -rf /private/var/mobile/Library/Caches/com.apple.iTunesCloud/URLBags"); 
                system("launchctl unload /System/Library/LaunchDaemons/com.apple.itunescloudd.plist");
                system("launchctl load /System/Library/LaunchDaemons/com.apple.itunescloudd.plist");
                __kill_atc();
                __kill_mediaserverd();
                __kill_fairplayd();
                __kill_nsurlsessiond();

                system("killall -9 SpringBoard");
                usleep(1000000);

                lock(&__timer_barrier__);
                kill(getpid(), SIGKILL);
                unlock(&__timer_barrier__);
            }
        }

        __schedule_restart();
    });
}

static int springboard_cd = 0;

static void __schedule_springboard_runtime()
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), runtime_springboard_queue, ^{

        if (__daemon_avaliable__ ) {
            u8 r = 0;
            int32_t spid;
            common_is_springboard_running(&r, &spid);
            if (r) {
                springboard_cd = 0;
            } else {
                springboard_cd++;
                if (springboard_cd == 300) {
                    springboard_cd = 0;
                    system("killall -9 SpringBoard");
                }
            }

            __schedule_springboard_runtime();
        }
    });
}

void daemon_init_first()
{
    wiiauto_daemon_web_init(); 
    int count = 0;

    while (!__daemon_web_success__) {
        usleep(1000000);
        if (count >= 10) {
            kill(getpid(), SIGKILL);
        }
    }
}

static void __fix_fb()
{
    json_element e, e_boottime;
    time_t bt;
    f64 c;
    u8 fix = 0;

    json_element_new(&e);
    json_element_load_file(e, DAEMON_FILE_CACHE);

    json_object_require_number_default(e, "boottime", &e_boottime, 0);    
    json_number_get(e_boottime, &c);

    bt = wiiauto_util_get_boottime();

    if (bt != (u64)c) {
        c = bt;
        json_number_set(e_boottime, c);
        json_element_save_file(e, DAEMON_FILE_CACHE);
        fix = 1;
    }
    
    release(e.iobj);

    if (fix) {
        wiiauto_util_reinstall_facebook();
    }
}

void wiiauto_device_db_share_setup();
void wiiauto_device_db_blob_share_setup();
void wiiauto_device_db_keychain_share_setup();
void wiiauto_device_db_multi_setup();
void wiiauto_device_db_email_setup();
void wiiauto_device_db_imessage_setup();

static void __handle_resetIDS()
{
    system("killall -9 identityservicesd");
}   

static void store_device_serial()
{



}

void daemon_init()
{    
    wiiauto_daemon_timer_init();

    wiiauto_daemon_screenbuffer_init_unix();

    file_require_folder(WIIAUTO_ROOT_SCRIPTS_PATH);
    checkupdate_queue = dispatch_queue_create(NULL, NULL);
    awake_queue = dispatch_queue_create(NULL, NULL);
    restart_queue = dispatch_queue_create(NULL, NULL);
    runtime_springboard_queue = dispatch_queue_create(NULL, NULL);

    __restart_timestamp__ = current_timestamp();

    {
        json_element e, e_awake;
        u8 v;
        json_element_new(&e);
        json_element_load_file(e, DAEMON_FILE_CONFIG);
        json_object_require_boolean_default(e, "awake", &e_awake, 1);
        json_boolean_get(e_awake, &v);
        __daemon_auto_awake__ = v;

        release(e.iobj);
    }

    wiiauto_device_db_set_system("default", "default", "default");
    {
        buffer s;
        buffer_new(&s);
        wiiauto_device_get_serial_number(s);
        release(s.iobj);
    }

    wiiauto_device_db_set_share("default", "default", "default");
    wiiauto_device_db_share_setup();

    wiiauto_device_db_set_blob_share("default", "default", strlen("default"), "default", strlen("default"));
    wiiauto_device_db_blob_share_setup();

    wiiauto_device_db_keychain_set_bundle_state("default", "default");
    wiiauto_device_db_keychain_share_setup();

    wiiauto_device_db_multi_delete("default", "default");
    wiiauto_device_db_multi_setup();

    wiiauto_device_db_email_setup();
    wiiauto_device_db_imessage_setup();

    __awake();
    // __check_update();
    // __schedule_restart();
    // __schedule_springboard_runtime();    

    __require_file(DAEMON_FILE_ALERT_APP);
    __require_file(DAEMON_FILE_ALERT_SPRINGBOARD);
    __require_file(DAEMON_FILE_LOCATION);
    __require_file(DAEMON_FILE_APPS_CLONED);
    __require_file(DAEMON_FILE_APPS_MESSENGER_CLONED);
    __require_file(DAEMON_FILE_APPS_ZALO_CLONED);
    __require_file(DAEMON_FILE_APPS_CHROME_CLONED);
    __require_file(DAEMON_FILE_APPS_YOUTUBE_CLONED);
    __require_file(DAEMON_FILE_APPS_FIREFOX_CLONED);
    __require_file(DAEMON_FILE_INPUT_TEXT_1);
    __require_file(DAEMON_FILE_INPUT_TEXT_2);
    __require_file(DAEMON_FILE_INPUT_TEXT_3);
    __require_file(DAEMON_FILE_INPUT_TEXT_4);
    __require_file(DAEMON_FILE_INPUT_TEXT_5);
    __require_file(DAEMON_FILE_INPUT_TEXT_6);
    __require_file(DAEMON_FILE_INPUT_TEXT_7);
    __require_file(DAEMON_FILE_INPUT_TEXT_8);
    __require_file(DAEMON_FILE_INPUT_TEXT_9);
    __require_file(DAEMON_FILE_INPUT_TEXT_10);

    __daemon_avaliable__ = 0;
    // __fix_fb();
    __daemon_avaliable__ = 1;

    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, __handle_resetIDS, CFSTR("com.wiimob.wiiauto/resetIDS"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);

    srand(time(NULL));
}
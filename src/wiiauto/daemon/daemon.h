#ifndef __wiiauto_daemon_h
#define __wiiauto_daemon_h

#if defined __cplusplus
extern "C" {
#endif

// #define DAEMON_MACH_PORT_NAME "com.wiimob.wiiauto.daemon"
#define DAEMON_MACH_PORT_NAME "/wiiauto_daemon_shared_memory"

#define DAEMON_FILE_ALERT_APP "/var/mobile/Library/WiiAuto/wiiauto_log_daemon_alert_app.txt"
#define DAEMON_FILE_ALERT_SPRINGBOARD "/var/mobile/Library/WiiAuto/wiiauto_log_daemon_alert_springboard.txt"
#define DAEMON_FILE_LOCATION "/var/mobile/Library/WiiAuto/wiiauto_log_daemon_location.txt"
#define DAEMON_FILE_CACHE "/var/mobile/Library/WiiAuto/wiiauto_daemon_cache.txt"
#define DAEMON_FILE_CONFIG "/var/mobile/Library/WiiAuto/wiiauto_daemon_config.txt"
#define DAEMON_FILE_APPS_CLONED "/var/mobile/Library/WiiAuto/wiiauto_apps_cloned.txt"
#define DAEMON_FILE_APPS_MESSENGER_CLONED "/var/mobile/Library/WiiAuto/wiiauto_apps_messenger_cloned.txt"
#define DAEMON_FILE_APPS_ZALO_CLONED "/var/mobile/Library/WiiAuto/wiiauto_apps_zalo_cloned.txt"
#define DAEMON_FILE_APPS_CHROME_CLONED "/var/mobile/Library/WiiAuto/wiiauto_apps_chrome_cloned.txt"
#define DAEMON_FILE_APPS_YOUTUBE_CLONED "/var/mobile/Library/WiiAuto/wiiauto_apps_youtube_cloned.txt"
#define DAEMON_FILE_APPS_FIREFOX_CLONED "/var/mobile/Library/WiiAuto/wiiauto_apps_firefox_cloned.txt"
#define DAEMON_FILE_INPUT_TEXT_1 "/var/mobile/Library/WiiAuto/input_text_1.txt"
#define DAEMON_FILE_INPUT_TEXT_2 "/var/mobile/Library/WiiAuto/input_text_2.txt"
#define DAEMON_FILE_INPUT_TEXT_3 "/var/mobile/Library/WiiAuto/input_text_3.txt"
#define DAEMON_FILE_INPUT_TEXT_4 "/var/mobile/Library/WiiAuto/input_text_4.txt"
#define DAEMON_FILE_INPUT_TEXT_5 "/var/mobile/Library/WiiAuto/input_text_5.txt"
#define DAEMON_FILE_INPUT_TEXT_6 "/var/mobile/Library/WiiAuto/input_text_6.txt"
#define DAEMON_FILE_INPUT_TEXT_7 "/var/mobile/Library/WiiAuto/input_text_7.txt"
#define DAEMON_FILE_INPUT_TEXT_8 "/var/mobile/Library/WiiAuto/input_text_8.txt"
#define DAEMON_FILE_INPUT_TEXT_9 "/var/mobile/Library/WiiAuto/input_text_9.txt"
#define DAEMON_FILE_INPUT_TEXT_10 "/var/mobile/Library/WiiAuto/input_text_10.txt"

void daemon_init_first();
void daemon_init();

extern int __daemon_web_success__;
extern int __daemon_avaliable__;
extern int __daemon_auto_restart__;
extern int __daemon_auto_awake__;
extern int __download_package__;

#if defined __cplusplus
}
#endif

#endif
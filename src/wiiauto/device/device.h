#ifndef __wiiauto_device_h
#define __wiiauto_device_h

#if defined __cplusplus
extern "C" {
#endif

#include "cherry/def.h"
#include "cherry/core/buffer.h"

#define WIIAUTO_ROOT_PATH "/var/mobile/Library/WiiAuto/"
#define WIIAUTO_ROOT_RESOURCE_PATH "/var/mobile/Library/WiiAuto/Resources_inner/com.wiimob.wiiauto.bundle"
#define WIIAUTO_ROOT_SCRIPTS_PATH "/var/mobile/Library/WiiAuto/Scripts/"
#define WIIAUTO_ROOT_TMP_SCRIPTS_PATH "/var/mobile/Library/WiiAuto/temporary/Scripts/"
#define WIIAUTO_ROOT_LOG_FILE_PATH "/var/mobile/Library/WiiAuto/log.txt"
#define WIIAUTO_ROOT_SYS_LOG_FILE_PATH "/var/mobile/Library/WiiAuto/sys_log.txt"

typedef enum
{
    WIIAUTO_DEVICE_ORIENTATION_UNKNOWN = 0,
    WIIAUTO_DEVICE_ORIENTATION_PORTRAIT,
    WIIAUTO_DEVICE_ORIENTATION_PORTRAIT_UPSIDE_DOWN,
    WIIAUTO_DEVICE_ORIENTATION_LANDSCAPE_LEFT,
    WIIAUTO_DEVICE_ORIENTATION_LANDSCAPE_RIGHT
}
__wiiauto_device_orientation;

typedef struct __attribute__((packed))
{
    u8 r;
    u8 g;
    u8 b;
    u8 a;
}
__wiiauto_pixel;

extern __wiiauto_pixel *__device_screen_buffer__;

void wiiauto_device_init();
void wiiauto_device_get_screen_size(float *width, float *height);
void wiiauto_device_get_retina_factor(float *factor);
void wiiauto_device_is_locked(u8 *flag);
void wiiauto_device_is_screen_on(u8 *flag);
void wiiauto_device_unlock();
void wiiauto_device_undim_display();
void wiiauto_device_get_current_screen_buffer(const __wiiauto_pixel **ptr, u32 *width, u32 *height);
void wiiauto_device_get_orientation(__wiiauto_device_orientation *o);
void wiiauto_device_get_app_orientation(__wiiauto_device_orientation *o);
// void wiiauto_device_register_alert_notification();
void wiiauto_device_register_app_orientation_notification();
// void wiiauto_device_is_keyboard_on(u8 *on);
// void wiiauto_device_is_alert_on(u8 *on);
void wiiauto_device_get_serial_number(const buffer b);
void wiiauto_device_is_toast_enable(u8 *on);
void wiiauto_device_is_log_enable(u8 *on);
void wiiauto_device_set_toast(const u8 on);
void wiiauto_device_set_log(const u8 on);

void __wiiauto_device_sys_log(const char *ptr, const int size);

#define wiiauto_device_sys_log(...) \
    do {\
        int size;\
        size = snprintf(NULL, 0, __VA_ARGS__);\
        char *s = (char *)malloc(size + 1);\
        sprintf(s, __VA_ARGS__);  \
        __wiiauto_device_sys_log(s, size);\
        free(s);\
    } while (0);

#if defined __cplusplus
}
#endif

#endif
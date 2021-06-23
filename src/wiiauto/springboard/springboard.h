#ifndef __wiiauto_springboard_h
#define __wiiauto_springboard_h

#if defined __cplusplus
extern "C" {
#endif

#include "cherry/def.h"

// #define SPRINGBOARD_MACH_PORT_NAME "com.wiimob.wiiauto.springboard"
// #define SPRINGBOARD_MACH_PORT_NAME "/wiiauto_springboard_handler"

#define SPRINGBOARD_MACH_PORT_NAME "/var/mobile/Library/SpringBoard/wiiauto_springboard_unixdomain.sock"
#define SPRINGBOARD_SCREENBUFFER_DOMAIN "/var/mobile/Library/SpringBoard/wiiauto_springboard_screenbuffer_domain.sock"

#define SPRINGBOARD_LOCAL_PORT_1 54321
#define SPRINGBOARD_LOCAL_PORT_2 54322
#define SPRINGBOARD_LOCAL_PORT_3 54323
#define SPRINGBOARD_LOCAL_PORT_4 54324
#define SPRINGBOARD_LOCAL_PORT_5 54325
#define SPRINGBOARD_LOCAL_PORT_6 54326
#define SPRINGBOARD_LOCAL_PORT_7 54327
#define SPRINGBOARD_LOCAL_PORT_8 54328
#define SPRINGBOARD_LOCAL_PORT_9 54329

typedef void(*springboard_set_status_bar_delegate)(const char *ptr);
typedef void(*springboard_set_status_bar_state_delegate)(const u8 visible);

void springboard_init();
void springboard_init_refresh();
void springboard_shm_init();
void springboard_screenbuffer_unix_init();
void springboard_init_status_bar_delegate(
    const springboard_set_status_bar_delegate delegate,
    const springboard_set_status_bar_state_delegate delegate2);

#if defined __cplusplus
}
#endif

#endif
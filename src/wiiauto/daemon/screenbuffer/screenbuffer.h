#ifndef __wiiauto_daemon_screenbuffer_h
#define __wiiauto_daemon_screenbuffer_h

#if defined __cplusplus
extern "C" {
#endif

#include "cherry/def.h"

extern spin_lock __screenbuffer_lock__;

void wiiauto_daemon_screenbuffer_init_shm();
void wiiauto_daemon_screenbuffer_init_unix();

#if defined __cplusplus
}
#endif

#endif
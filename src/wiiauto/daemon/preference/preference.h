#ifndef __wiiauto_daemon_preference_h
#define __wiiauto_daemon_preference_h

#if defined __cplusplus
extern "C" {
#endif

#include "wiiauto/preference/preference.h"

void wiiauto_daemon_preference_get(const char *path, wiiauto_preference *pref);

#if defined __cplusplus
}
#endif

#endif
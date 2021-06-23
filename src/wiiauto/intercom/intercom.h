#ifndef __wiiauto_intercom_h
#define __wiiauto_intercom_h

#if defined __cplusplus
extern "C" {
#endif

#include "cherry/def.h"

typedef CFDataRef(*wiiauto_intercom_callback)(CFMessagePortRef local, SInt32 msgid, CFDataRef cfData, void *info);

// void wiiauto_intercom_register_shm(const char *name, const wiiauto_intercom_callback callback);
// CFDataRef wiiauto_intercom_send_shm(const char *name, const void *data, const u32 len);

void wiiauto_intercom_register_unix(const char *name, const wiiauto_intercom_callback callback);
CFDataRef wiiauto_intercom_send_unix(const char *name, const void *data, const u32 len);

void wiiauto_intercom_register_local_port(const int num, const u16 *port, const wiiauto_intercom_callback callback);
CFDataRef wiiauto_intercom_send_local_port(const int num, const u16 *port, const void *data, const u32 len);

#if defined __cplusplus
}
#endif

#endif
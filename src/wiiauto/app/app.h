#ifndef __wiiauto_app_h
#define __wiiauto_app_h

#if defined __cplusplus
extern "C" {
#endif

#include "cherry/core/buffer.h"

void app_init();

void app_fill_message_port_name(const char *bundle, const buffer b);

#if defined __cplusplus
}
#endif

#endif
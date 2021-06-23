#ifndef __wiiauto_thread_h
#define __wiiauto_thread_h

#if defined __cplusplus
extern "C" {
#endif

#include "cherry/thread/thread.h"

void wiiauto_get_thread_pool(thread_pool *p);
void wiiauto_recycle_thread_pool(const thread_pool p);

#if defined __cplusplus
}
#endif

#endif
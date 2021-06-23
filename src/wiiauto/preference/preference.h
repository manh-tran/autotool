#ifndef __wiiauto_preference_h
#define __wiiauto_preference_h

#if defined __cplusplus
extern "C" {
#endif

#include "cherry/iobj.h"

type(wiiauto_preference);

void wiiauto_preference_create(const char *name, wiiauto_preference *p);
void wiiauto_preference_set_firetime(const wiiauto_preference p, const char *url, const time_t fire_time);
void wiiauto_preference_set_timer(const wiiauto_preference p, const char *url, const time_t fire_time, const u8 repeat, const i32 interval);
void wiiauto_preference_enable_timer(const wiiauto_preference p, const char *url, const u8 enable);
void wiiauto_preference_clear_timer(const wiiauto_preference p, const char *url);
void wiiauto_preference_iterate_timer(const wiiauto_preference p, const u32 index, const char **url, time_t *fire_time, u8 *repeat, i32 *interval, u8 *enable);
void wiiauto_preference_save(const wiiauto_preference p);

#if defined __cplusplus
}
#endif


#endif
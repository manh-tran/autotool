#ifndef __remote_log_h
#define __remote_log_h

#if defined __cplusplus
extern "C" {
#endif

#include <stdlib.h>

void remote_log_set_enable(const int v);
void remote_log_set_process(const char *tag);
void remote_log_send(const char *str, const unsigned int len);

#define remote_log(...) \
    do {\
        int size;\
        size = snprintf(NULL, 0, __VA_ARGS__);\
        char *s = (char *)malloc(size + 1);\
        sprintf(s, __VA_ARGS__);  \
        remote_log_send(s, size);\
        free(s);\
    } while (0);

#define remote_log_2(...) \
    do {\
    } while (0);

#if defined __cplusplus
}
#endif

#endif
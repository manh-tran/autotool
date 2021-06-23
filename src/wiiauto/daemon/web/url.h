#ifndef __wiiauto_daemon_web_url_h
#define __wiiauto_daemon_web_url_h

#if defined __cplusplus
extern "C" {
#endif

#include "cherry/net/socket.h"

type(wiiauto_daemon_web_url);

void wiiauto_daemon_web_url_parse(const wiiauto_daemon_web_url p, const char *ptr);
void wiiauto_daemon_web_url_get_path(const wiiauto_daemon_web_url p, const char **path);
void wiiauto_daemon_web_url_get_param(const wiiauto_daemon_web_url p, const char *key, const char **value);

#if defined __cplusplus
}
#endif

#endif
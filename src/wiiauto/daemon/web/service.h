#ifndef __wiiauto_daemon_web_service_h
#define __wiiauto_daemon_web_service_h

#if defined __cplusplus
extern "C" {
#endif

#include "cherry/net/socket.h"
#include "url.h"

type(wiiauto_daemon_web_service);

typedef void(*wiiauto_daemon_web_service_handler)(const wiiauto_daemon_web_service service, const net_socket server, const net_socket sock, const wiiauto_daemon_web_url url, const buffer current_read);

void wiiauto_daemon_web_service_register_handler(const wiiauto_daemon_web_service p, const char **methods, const char *path, const wiiauto_daemon_web_service_handler h);
void wiiauto_daemon_web_service_process(const wiiauto_daemon_web_service p, const net_socket server, const net_socket sock, const buffer first);

#if defined __cplusplus
}
#endif

#endif
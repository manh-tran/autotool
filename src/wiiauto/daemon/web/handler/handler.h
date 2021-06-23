#ifndef __wiiauto_daemon_web_handler_h
#define __wiiauto_daemon_web_handler_h

#if defined __cplusplus
extern "C" {
#endif

#include "../service.h"

void wiiauto_daemon_web_service_handle_get_home(const wiiauto_daemon_web_service service, const net_socket server, const net_socket sock, const wiiauto_daemon_web_url url, const buffer current_read);
void wiiauto_daemon_web_service_handle_start_playing(const wiiauto_daemon_web_service service, const net_socket server, const net_socket sock, const wiiauto_daemon_web_url url, const buffer current_read);
void wiiauto_daemon_web_service_handle_stop_playing(const wiiauto_daemon_web_service service, const net_socket server, const net_socket sock, const wiiauto_daemon_web_url url, const buffer current_read);
void wiiauto_daemon_web_service_handle_get_running_scripts(const wiiauto_daemon_web_service service, const net_socket server, const net_socket sock, const wiiauto_daemon_web_url url, const buffer current_read);
void wiiauto_daemon_web_service_handle_set_timer(const wiiauto_daemon_web_service service, const net_socket server, const net_socket sock, const wiiauto_daemon_web_url url, const buffer current_read);
void wiiauto_daemon_web_service_handle_get_timer(const wiiauto_daemon_web_service service, const net_socket server, const net_socket sock, const wiiauto_daemon_web_url url, const buffer current_read);
void wiiauto_daemon_web_service_handle_enable_timer(const wiiauto_daemon_web_service service, const net_socket server, const net_socket sock, const wiiauto_daemon_web_url url, const buffer current_read);
void wiiauto_daemon_web_service_handle_disable_timer(const wiiauto_daemon_web_service service, const net_socket server, const net_socket sock, const wiiauto_daemon_web_url url, const buffer current_read);
void wiiauto_daemon_web_service_handle_remove_timer(const wiiauto_daemon_web_service service, const net_socket server, const net_socket sock, const wiiauto_daemon_web_url url, const buffer current_read);
void wiiauto_daemon_web_service_handle_config(const wiiauto_daemon_web_service service, const net_socket server, const net_socket sock, const wiiauto_daemon_web_url url, const buffer current_read);
void wiiauto_daemon_web_service_handle_install(const wiiauto_daemon_web_service service, const net_socket server, const net_socket sock, const wiiauto_daemon_web_url url, const buffer current_read);
void wiiauto_daemon_web_service_handle_auto_restart(const wiiauto_daemon_web_service service, const net_socket server, const net_socket sock, const wiiauto_daemon_web_url url, const buffer current_read);
void wiiauto_daemon_web_service_handle_auto_awake(const wiiauto_daemon_web_service service, const net_socket server, const net_socket sock, const wiiauto_daemon_web_url url, const buffer current_read);
void wiiauto_daemon_web_service_handle_request_hotspot_delay(const wiiauto_daemon_web_service service, const net_socket server, const net_socket sock, const wiiauto_daemon_web_url url, const buffer current_read);

void wiiauto_daemon_web_service_handle_register_gate(const wiiauto_daemon_web_service service, const net_socket server, const net_socket sock, const wiiauto_daemon_web_url url, const buffer current_read);
void wiiauto_daemon_web_service_handle_remove_gate(const wiiauto_daemon_web_service service, const net_socket server, const net_socket sock, const wiiauto_daemon_web_url url, const buffer current_read);
void wiiauto_daemon_web_service_handle_process_gate(const wiiauto_daemon_web_service service, const net_socket server, const net_socket sock, const wiiauto_daemon_web_url url, const buffer current_read);


#if defined __cplusplus
}
#endif

#endif
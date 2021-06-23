#ifndef __wiiauto_tool_handler_h
#define __wiiauto_tool_handler_h

#if defined __cplusplus
extern "C" {
#endif

void wiiauto_tool_register();

void wiiauto_tool_run_daemon(const int argc, const char **argv);
void wiiauto_tool_run_daemon_execute(const int argc, const char **argv);
void wiiauto_tool_run_refresh(const int argc, const char **argv);
void wiiauto_tool_run_update_package(const int argc, const char **argv);
void wiiauto_tool_run_restart_substrate(const int argc, const char **argv);
void wiiauto_tool_run_ldrestart(const int argc, const char **argv);
void wiiauto_tool_run_clear_account(const int argc, const char **argv);
void wiiauto_tool_run_clear_keychain(const int argc, const char **argv);
void wiiauto_tool_run_check_substrate(const int argc, const char **argv);
void wiiauto_tool_run_show_ui(const int argc, const char **argv);
void wiiauto_tool_run_kill_app(const int argc, const char **argv);
void wiiauto_tool_run_restart_springboard(const int argc, const char **argv);
void wiiauto_tool_run_test(const int argc, const char **argv);
void wiiauto_tool_run_get_mgcopyanswer(const int argc, const char **argv);
void wiiauto_tool_run_clone_fb(const int argc, const char **argv);
void wiiauto_tool_run_clone_fb_2(const int argc, const char **argv);
void wiiauto_tool_run_clone_swordman(const int argc, const char **argv);
void wiiauto_tool_run_clone_samurai(const int argc, const char **argv);
void wiiauto_tool_run_print_app_info(const int argc, const char **argv);
void wiiauto_tool_run_open_swordman(const int argc, const char **argv);
void wiiauto_tool_run_test_data_app(const int argc, const char **argv);
void wiiauto_tool_run_test_register_app(const int argc, const char **argv);
void wiiauto_tool_run_test_unregister_app(const int argc, const char **argv);
void wiiauto_tool_run_check_uptime(const int argc, const char **argv);
void wiiauto_tool_run_test_compare(const int argc, const char **argv);
void wiiauto_tool_run_get_app_group(const int argc, const char **argv);
void wiiauto_tool_run_test_app_proxy(const int argc, const char **argv);

#if defined __cplusplus
}
#endif

#endif
#include "handler/handler.h"

int main(int argc, char **argv)
{
    if (argc == 1) goto finish;

#define _CASE(X,F) if (strcmp(argv[1], X) == 0) {F(argc, argv); goto finish;}

    _CASE("daemon", wiiauto_tool_run_daemon_execute);
    _CASE("daemon_execute", wiiauto_tool_run_daemon_execute);
    _CASE("refresh", wiiauto_tool_run_refresh);
    _CASE("update_package", wiiauto_tool_run_update_package);
    _CASE("clear_account", wiiauto_tool_run_clear_account);
    _CASE("clear_keychain", wiiauto_tool_run_clear_keychain);
    _CASE("restart_substrate", wiiauto_tool_run_restart_substrate);
    _CASE("check_substrate", wiiauto_tool_run_check_substrate);
    _CASE("show_ui", wiiauto_tool_run_show_ui);
    _CASE("ldrestart", wiiauto_tool_run_ldrestart);
    _CASE("kill_app", wiiauto_tool_run_kill_app);
    _CASE("restart_springboard", wiiauto_tool_run_restart_springboard);
    _CASE("test", wiiauto_tool_run_test);
    _CASE("get_mgcopyanswer", wiiauto_tool_run_get_mgcopyanswer);
    _CASE("clone_fb", wiiauto_tool_run_clone_fb);
    _CASE("clone_fb_2", wiiauto_tool_run_clone_fb_2);
    _CASE("clone_swordman", wiiauto_tool_run_clone_swordman);
    _CASE("clone_samurai", wiiauto_tool_run_clone_samurai);
    _CASE("print_app_info", wiiauto_tool_run_print_app_info);
    _CASE("test_register_app", wiiauto_tool_run_test_register_app);
    _CASE("test_unregister_app", wiiauto_tool_run_test_unregister_app);
    _CASE("test_data_app", wiiauto_tool_run_test_data_app);
    _CASE("check_uptime", wiiauto_tool_run_check_uptime);
    _CASE("test_compare", wiiauto_tool_run_test_compare);
    _CASE("get_app_group", wiiauto_tool_run_get_app_group);
    _CASE("test_app_proxy", wiiauto_tool_run_test_app_proxy);

finish:
    return 0;
}
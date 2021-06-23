#include "api.h"
#include <stdarg.h>
#include "wiiauto/event/event_press_button.h"
#include "wiiauto/device/device.h"
// #include "wiiauto/device/device_pref.h"

typedef struct
{
    int value;
    const char *name;
}
__lua_enum_field;

#define FIELD(n, v) &(__lua_enum_field){.name = n, .value = v}

static void __register_enum(lua_State *ls, const char *table, const __lua_enum_field *field, ...)
{
    va_list l;
    int num;
    const __lua_enum_field *e;

    va_start(l, field);
    e = field;
    num = 0;
    while (e) {
        num++;
        e = va_arg(l, const __lua_enum_field *);
    }
    va_end(l);

    lua_createtable(ls, 0, num);
    va_start(l, field);
    e = field;
    while (e) {
        lua_pushinteger(ls, e->value);
        lua_setfield(ls, -2, e->name);
        e = va_arg(l, const __lua_enum_field *);
    }
    va_end(l);
    lua_setglobal(ls, table);
    lua_settop(ls, 0); 
}

static void __append_path(lua_State *ls, const char *path)
{
    buffer b;
    const char *s;
    u32 len;

    len = strlen(path);

    lua_getglobal(ls, "package");
    lua_getfield(ls, -1, "path");

    s = lua_tostring(ls, -1);
    buffer_new(&b);
    buffer_append(b, path, strlen(path));
    if (path[len - 1] != '/') {
        buffer_append(b, "/", 1);
    }
    buffer_append(b, "?.lua", 5);
    buffer_append(b, ";", 1);
    buffer_append(b, s, strlen(s));

    buffer_get_ptr(b, &s);

    lua_pop(ls, 1);
    lua_pushstring(ls, s);
    lua_setfield(ls, -2, "path");
    lua_pop(ls, 1);
    lua_settop(ls, 0); 

    release(b.iobj);
}

static void __append_cpath_so(lua_State *ls, const char *cpath)
{
    buffer b;
    const char *s;
    u32 len;

    len = strlen(cpath);

    lua_getglobal(ls, "package");
    lua_getfield(ls, -1, "cpath");

    s = lua_tostring(ls, -1);
    buffer_new(&b);    
    buffer_append(b, cpath, strlen(cpath));
    if (cpath[len - 1] != '/') {
        buffer_append(b, "/", 1);
    }
    buffer_append(b, "?.so", 4);
    buffer_append(b, ";", 1);
    buffer_append(b, s, strlen(s));

    buffer_get_ptr(b, &s);

    lua_pop(ls, 1);
    lua_pushstring(ls, s);
    lua_setfield(ls, -2, "cpath");
    lua_pop(ls, 1);
    lua_settop(ls, 0); 

    release(b.iobj);
}

static void __append_cpath_dylib(lua_State *ls, const char *cpath)
{
    buffer b;
    const char *s;
    u32 len;

    len = strlen(cpath);

    lua_getglobal(ls, "package");
    lua_getfield(ls, -1, "cpath");

    s = lua_tostring(ls, -1);
    buffer_new(&b);    
    buffer_append(b, cpath, strlen(cpath));
    if (cpath[len - 1] != '/') {
        buffer_append(b, "/", 1);
    }
    buffer_append(b, "?.dylib", 7);
    buffer_append(b, ";", 1);
    buffer_append(b, s, strlen(s));

    buffer_get_ptr(b, &s);

    lua_pop(ls, 1);
    lua_pushstring(ls, s);
    lua_setfield(ls, -2, "cpath");
    lua_pop(ls, 1);
    lua_settop(ls, 0); 

    release(b.iobj);
}

static void __append_cpath(lua_State *ls, const char *cpath)
{
    __append_cpath_so(ls, cpath);
    __append_cpath_dylib(ls, cpath);
}

void wiiauto_lua_register_state(lua_State *ls)
{
    /*
     * register global enums
     */
    __register_enum(ls, "KEY_TYPE", 
        FIELD("HOME_BUTTON", WIIAUTO_BUTTON_HOME),
        FIELD("VOLUME_DOWN_BUTTON", WIIAUTO_BUTTON_VOLUME_DOWN),
        FIELD("VOLUME_UP_BUTTON", WIIAUTO_BUTTON_VOLUME_UP),
        FIELD("POWER_BUTTON", WIIAUTO_BUTTON_LOCK),
        FIELD("ENTER_BUTTON", WIIAUTO_BUTTON_ENTER),
        FIELD("BACKSPACE_BUTTON", WIIAUTO_BUTTON_BACKSPACE),
        NULL);

    __register_enum(ls, "ORIENTATION_TYPE",
        FIELD("UNKNOWN", WIIAUTO_DEVICE_ORIENTATION_UNKNOWN),
        FIELD("PORTRAIT", WIIAUTO_DEVICE_ORIENTATION_PORTRAIT),
        FIELD("PORTRAIT_UPSIDE_DOWN", WIIAUTO_DEVICE_ORIENTATION_PORTRAIT_UPSIDE_DOWN),
        FIELD("LANDSCAPE_LEFT", WIIAUTO_DEVICE_ORIENTATION_LANDSCAPE_LEFT),
        FIELD("LANDSCAPE_RIGHT", WIIAUTO_DEVICE_ORIENTATION_LANDSCAPE_RIGHT),
        NULL);
    
    // __register_enum(ls, "OVERRIDE_TYPE",
    //     FIELD("ALL", WIIAUTO_DEVICE_OVERRIDE_ALL),
    //     FIELD("DISABLED", WIIAUTO_DEVICE_OVERRIDE_DISABLED),
    //     FIELD("SEPARATELY", WIIAUTO_DEVICE_OVERRIDE_SEPARATELY),
    //     NULL);

    /*
     * register global functions
     */
    lua_register(ls, "touchDown", wiiauto_lua_touch_down);
    lua_register(ls, "touchMove", wiiauto_lua_touch_move);
    lua_register(ls, "touchUp", wiiauto_lua_touch_up);
    lua_register(ls, "zoomDown", wiiauto_lua_zoom_down);
    lua_register(ls, "zoomMove", wiiauto_lua_zoom_move);
    lua_register(ls, "zoomUp", wiiauto_lua_zoom_up);
    lua_register(ls, "keyDown", wiiauto_lua_key_down);
    lua_register(ls, "keyUp", wiiauto_lua_key_up);
    lua_register(ls, "keyDownDetail", wiiauto_lua_key_down_detail);
    lua_register(ls, "keyUpDetail", wiiauto_lua_key_up_detail);
    lua_register(ls, "getColor", wiiauto_lua_get_color);
    lua_register(ls, "getColors", wiiauto_lua_get_colors);
    lua_register(ls, "findColor", wiiauto_lua_find_color);
    lua_register(ls, "findColors", wiiauto_lua_find_colors);
    lua_register(ls, "findImageV2", wiiauto_lua_find_image_v2);
    lua_register(ls, "findImage", wiiauto_lua_find_image);
    lua_register(ls, "findImageGrayscale", wiiauto_lua_find_image_grayscale);
    lua_register(ls, "findImageBlackWhite", wiiauto_lua_find_image_blackwhite);
    lua_register(ls, "screenshot", wiiauto_lua_screen_shot);
    lua_register(ls, "rootDir", wiiauto_lua_root_dir);
    lua_register(ls, "currentPath", wiiauto_lua_current_path);
    lua_register(ls, "usleep", wiiauto_lua_usleep);
    lua_register(ls, "log", wiiauto_lua_log);
    lua_register(ls, "getOrientation", wiiauto_lua_get_orientation);
    lua_register(ls, "getScreenResolution", wiiauto_lua_get_screen_resolution);
    lua_register(ls, "getScreenSize", wiiauto_lua_get_screen_size);
    lua_register(ls, "frontMostAppId", wiiauto_lua_get_front_most_app_id);
    lua_register(ls, "frontMostAppOrientation", wiiauto_lua_get_front_most_app_orientation);
    lua_register(ls, "intToRgb", wiiauto_lua_int_to_rgb);
    lua_register(ls, "rgbToInt", wiiauto_lua_rgb_to_int);
    lua_register(ls, "copyText", wiiauto_lua_set_clipboard_text);
    lua_register(ls, "clipText", wiiauto_lua_get_clipboard_text);
    lua_register(ls, "inputText", wiiauto_lua_input_text);
    lua_register(ls, "inputTextPaste", wiiauto_lua_input_text_paste);
    lua_register(ls, "appRun", wiiauto_lua_run_app);
    lua_register(ls, "appKill", wiiauto_lua_kill_app);
    lua_register(ls, "appState", wiiauto_lua_get_app_state);
    lua_register(ls, "alert", wiiauto_lua_alert);
    lua_register(ls, "toast", wiiauto_lua_toast);
    lua_register(ls, "vibrate", wiiauto_lua_vibrate);
    lua_register(ls, "getSN", wiiauto_lua_get_serial_number);
    lua_register(ls, "openURL", wiiauto_lua_open_url);
    lua_register(ls, "setTimer", wiiauto_lua_set_timer);
    lua_register(ls, "removeTimer", wiiauto_lua_remove_timer);
    lua_register(ls, "appInfo", wiiauto_lua_get_app_info);
    lua_register(ls, "hasAlert", wiiauto_lua_has_alert);
    lua_register(ls, "awake", wiiauto_lua_awake);
    lua_register(ls, "memUsage", wiiauto_lua_get_memory_usage);
    lua_register(ls, "setGPSLocation", wiiauto_lua_set_gps_location);
    lua_register(ls, "overrideGPSLocation", wiiauto_lua_override_gps_location);
    lua_register(ls, "uninstallApp", wiiauto_lua_uninstall_app);
    lua_register(ls, "getVersion", wiiauto_lua_get_version);
    lua_register(ls, "findImageInImage", wiiauto_lua_find_image_in_image);
    lua_register(ls, "stop", wiiauto_lua_stop);
    lua_register(ls, "resetASID", wiiauto_lua_reset_advertising_id);
    lua_register(ls, "wiiTestScreen", wiiauto_lua_test_screen);
    lua_register(ls, "remoteLog", wiiauto_lua_remote_log);
    lua_register(ls, "setStatusBar", wiiauto_lua_set_status_bar);
    lua_register(ls, "getLocalIpv4", wiiauto_lua_get_local_ipv4_address);
    lua_register(ls, "clearAccount", wiiauto_lua_clear_account);
    lua_register(ls, "setBundlePref", wiiauto_lua_set_bundle_preference);
    lua_register(ls, "getBundlePref", wiiauto_lua_get_bundle_preference);
    lua_register(ls, "setBundleShare", wiiauto_lua_set_bundle_share);
    lua_register(ls, "getBundleShare", wiiauto_lua_get_bundle_share);
    lua_register(ls, "getBundleShareAll", wiiauto_lua_get_bundle_share_all);
    lua_register(ls, "getNewUUID", wiiauto_lua_get_new_uuid);
    // lua_register(ls, "saveBundleKeychain", wiiauto_lua_save_bundle_keychain);
    // lua_register(ls, "loadBundleKeychain", wiiauto_lua_load_bundle_keychain);

    lua_register(ls, "setBundleKeychainState", wiiauto_lua_set_bundle_keychain_state);
    lua_register(ls, "getBundleKeychainState", wiiauto_lua_get_bundle_keychain_state);

    lua_register(ls, "addBundleMulti", wiiauto_lua_add_bundle_key_multi_value);
    lua_register(ls, "delBundleMulti", wiiauto_lua_delete_bundle_key_multi_value);
    lua_register(ls, "getBundleMulti", wiiauto_lua_get_bundle_key_multi_value);

    lua_register(ls, "addEmail", wiiauto_lua_db_email_add);
    lua_register(ls, "setEmailAppleIDState", wiiauto_lua_db_email_set_appleid_register_state);
    lua_register(ls, "getEmailUnregisteredAppleID", wiiauto_lua_db_email_get_appleid_unregistered);
    lua_register(ls, "getEmailUnregisteredAppleIDAlike", wiiauto_lua_db_email_get_appleid_unregistered_alike);
    lua_register(ls, "addAppleIDMachine", wiiauto_lua_db_email_add_appleid_machine);

    lua_register(ls, "imessage_add", wiiauto_lua_db_imessage_add);
    lua_register(ls, "imessage_get", wiiauto_lua_db_imessage_get);
    lua_register(ls, "imessage_set_status", wiiauto_lua_db_imessage_set_status);
    lua_register(ls, "imessage_delete_processeds", wiiauto_lua_db_imessage_delete_processeds);

    // lua_register(ls, "setBundleKeyNumber", wiiauto_lua_set_bundle_key_number);
    // lua_register(ls, "getBundleKeyNumber", wiiauto_lua_get_bundle_key_number);
    // lua_register(ls, "delBundleKeyNumber", wiiauto_lua_remove_bundle_key_number);

    // lua_register(ls, "setAppPref", wiiauto_lua_set_app_preference);
    // lua_register(ls, "getAppPref", wiiauto_lua_get_app_preference);
    // lua_register(ls, "setAppPrefState", wiiauto_lua_set_app_preference_state);
    // lua_register(ls, "getAppPrefState", wiiauto_lua_get_app_preference_state);
    // lua_register(ls, "overrideAppBundle", wiiauto_lua_set_app_bundle_overrided);
    // lua_register(ls, "rollbackAppBundle", wiiauto_lua_set_app_bundle_original);

    lua_register(ls, "cloneFacebook", wiiauto_lua_clone_facebook);
    lua_register(ls, "removeFacebook", wiiauto_lua_remove_clone_facebook);
    lua_register(ls, "removeAllFacebook", wiiauto_lua_remove_all_clone_facebook);    
    lua_register(ls, "cloneFacebookBatch", wiiauto_lua_clone_facebook_batch);

    lua_register(ls, "cloneMessenger", wiiauto_lua_clone_messenger);
    lua_register(ls, "removeMessenger", wiiauto_lua_remove_clone_messenger);
    lua_register(ls, "removeAllMessenger", wiiauto_lua_remove_all_clone_messenger);    

    lua_register(ls, "cloneZalo", wiiauto_lua_clone_zalo);
    lua_register(ls, "removeAllZalo", wiiauto_lua_remove_all_clone_zalo);
    lua_register(ls, "cloneChrome", wiiauto_lua_clone_chrome);
    lua_register(ls, "removeAllChrome", wiiauto_lua_remove_all_clone_chrome);
    lua_register(ls, "cloneYoutube", wiiauto_lua_clone_youtube);
    lua_register(ls, "removeAllYoutube", wiiauto_lua_remove_all_clone_youtube);
    lua_register(ls, "cloneFirefox", wiiauto_lua_clone_firefox);
    lua_register(ls, "removeAllFirefox", wiiauto_lua_remove_all_clone_firefox);
    lua_register(ls, "setStatusBarState", wiiauto_lua_set_status_bar_state);
    lua_register(ls, "getMD5", wiiauto_lua_md5);
    lua_register(ls, "clearItunesCache", wiiauto_lua_clear_itunes_cache);
    lua_register(ls, "rememberHashCode", wiiauto_lua_remember_hashcode);
    lua_register(ls, "isHashCodeRemembered", wiiauto_lua_is_hashcode_remembered);
    lua_register(ls, "downloadPhotoToLibrary", wiiauto_lua_download_image_to_photo_library);
    lua_register(ls, "downloadPhoto", wiiauto_lua_download_image);
    lua_register(ls, "getIOSSystemVersion", wiiauto_lua_get_ios_system_version);
    lua_register(ls, "getAppGroupFolder", wiiauto_lua_get_app_group_folder);
    lua_register(ls, "deleteKeychainAll", wiiauto_lua_delete_keychain_all);
    lua_register(ls, "deleteKeychainGenp", wiiauto_lua_delete_keychain_genp);
    lua_register(ls, "deleteKeychainByName", wiiauto_lua_delete_keychain_by_name);
    lua_register(ls, "deleteKeychainByNameExactly", wiiauto_lua_delete_keychain_by_name_exactly);
    lua_register(ls, "checkHasKeychainCert", wiiauto_lua_check_has_keychain_cert);
    lua_register(ls, "isFileExist", wiiauto_lua_is_file_exist);
    lua_register(ls, "exeCmd", wiiauto_lua_exe);
    lua_register(ls, "getDeviceName", wiiauto_lua_get_device_name);
    lua_register(ls, "getDeviceModel", wiiauto_lua_get_device_model);
    lua_register(ls, "getSystemBuildVersion", wiiauto_lua_get_system_build_version);
    lua_register(ls, "getSystemVersion", wiiauto_lua_get_system_version);
    lua_register(ls, "deleteAppDataStartWith", wiiauto_lua_delete_app_data_start_with);
    lua_register(ls, "deleteAppGroupStartWith", wiiauto_lua_delete_app_group_start_with);
    lua_register(ls, "deleteAppDataExactly", wiiauto_lua_delete_app_data_exactly);
    lua_register(ls, "deleteAppGroupExactly", wiiauto_lua_delete_app_group_exactly);
    lua_register(ls, "connectToWifi", wiiauto_lua_connect_to_wifi);
    lua_register(ls, "setAirplaneMode", wiiauto_lua_set_airplane_mode);
    lua_register(ls, "addContact", wiiauto_lua_add_contact);
    lua_register(ls, "deleteAllContacts", wiiauto_lua_delete_all_contacts);

    lua_register(ls, "notify", wiiauto_lua_post_notification);

    lua_register(ls, "registerApplication", wiiauto_lua_register_application);
    lua_register(ls, "unregisterApplication", wiiauto_lua_unregister_application);

    lua_register(ls, "getContainerMetadata", wiiauto_lua_get_container_metadata);
    lua_register(ls, "setContainerMetadata", wiiauto_lua_set_container_metadata);

    lua_register(ls, "getPhoneNumber", wiiauto_lua_get_phone_number);
    lua_register(ls, "getRunningScripts", wiiauto_lua_get_running_scripts);

    lua_register(ls, "runScript", wiiauto_lua_run_script);
    lua_register(ls, "stopScript", wiiauto_lua_stop_script);

    lua_register(ls, "sendSMS", wiiauto_lua_send_sms);

    lua_register(ls, "getTotalZAccounts", wiiauto_lua_get_total_zaccounts);
    lua_register(ls, "checkHasZAccount", wiiauto_lua_check_has_zaccount);

    lua_register(ls, "setSystemVersionPlist", wiiauto_lua_set_system_version_plist);
    lua_register(ls, "setSystemProxy", wiiauto_lua_set_system_proxy);

    lua_register(ls, "validateImage", wiiauto_lua_validate_image);
    lua_register(ls, "gzipString", wiiauto_lua_gzip_string);

    lua_register(ls, "sendHTTPRequest", wiiauto_lua_send_http_request);
    lua_register(ls, "generatePersonaKB", wiiauto_lua_generate_persona_kb);

    __append_cpath(ls, "/usr/local/wiiauto/lua_lib/5.3/");
    __append_cpath(ls, "/usr/local/wiiauto/lua_lib/5.3/md5/");
    __append_cpath(ls, "/usr/local/lib/");

    __append_path(ls, "/var/mobile/Library/WiiAuto/Scripts/");
    __append_path(ls, "/usr/local/wiiauto/lua_code/");
    __append_path(ls, "/usr/local/wiiauto/lua_code/cURL/");
    __append_path(ls, "/usr/local/wiiauto/lua_code/cURL/impl/");
    __append_path(ls, "/usr/local/wiiauto/lua_code/pl/");
    __append_path(ls, "/usr/local/wiiauto/lua_code/socket/");
    __append_path(ls, "/usr/local/wiiauto/lua_code/ssl/");
    __append_path(ls, "/usr/local/wiiauto/lua_code/websocket/");

    wiiauto_lua_register_json(ls);
}
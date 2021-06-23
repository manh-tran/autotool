#ifndef __wiiauto_lua_h
#define __wiiauto_lua_h

#if defined __cplusplus
extern "C" {
#endif

#include "lua/lua.h"
#include "lua/lauxlib.h"
#include "lua/lualib.h"
#include "cherry/core/buffer.h"

void wiiauto_lua_get_json_string_running_scripts(const buffer b, const u8 fullpath);
int wiiauto_lua_execute_file(const char *url, const u8 force, const char *func, const char *json_arguments, char **result);
void wiiauto_lua_stop_file(const char *url);
void wiiauto_lua_execute_buffer(const char *mem, const unsigned int len);

void wiiauto_lua_process_input_path(lua_State *ls, const char *path, const buffer b);
void wiiauto_lua_get_current_executing_path(lua_State *ls, const char **path);

void wiiauto_lua_get_current_running_scripts_count(u32 *count);

#if defined __cplusplus
}
#endif


#endif
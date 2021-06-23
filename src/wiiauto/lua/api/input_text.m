#include "api.h"
#include "wiiauto/device/device.h"
#include "wiiauto/common/common.h"

int wiiauto_lua_input_text(lua_State *ls)
{
#if WIIAUTO_DEBUG_LUA_API == 1
    printf("wiiauto_lua_input_text_start\n");
#endif
    const char *text = "";
    int word_by_word = 0;

    text = luaL_optstring(ls, 1, "");
    word_by_word = luaL_optinteger(ls, 2, 0);
    common_append_text(text, word_by_word);

#if WIIAUTO_DEBUG_LUA_API == 1
    printf("wiiauto_lua_input_text_end\n");
#endif
    return 0;
}

int wiiauto_lua_input_text_paste(lua_State *ls)
{
#if WIIAUTO_DEBUG_LUA_API == 1
    printf("wiiauto_lua_input_text_start\n");
#endif
    const char *text = "";
    int word_by_word = 0;

    text = luaL_optstring(ls, 1, "");
    word_by_word = luaL_optinteger(ls, 2, 0);
    common_append_text_paste(text, word_by_word);

#if WIIAUTO_DEBUG_LUA_API == 1
    printf("wiiauto_lua_input_text_end\n");
#endif
    return 0;
}
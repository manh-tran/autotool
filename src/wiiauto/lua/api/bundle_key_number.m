// #include "api.h"
// #include "wiiauto/device/device_db.h"

// int wiiauto_lua_set_bundle_key_number(lua_State *ls)
// {
//     const char *bundle = luaL_optstring(ls, 1, NULL);
//     const char *key = luaL_optstring(ls, 2, NULL);
//     const int num = luaL_optinteger(ls, 1, 0);

//     if (!bundle || !key) goto finish;

//     wiiauto_device_db_key_number_set(bundle, key, num);

// finish:
//     return 0;
// }

// int wiiauto_lua_get_bundle_key_number(lua_State *ls)
// {
//     const char *bundle = luaL_optstring(ls, 1, NULL);
//     const int limit = luaL_optstring(ls, 2, 0);
//     const int offset = luaL_optstring(ls, 3, -1);

//     int len = 0;
//     __db_key_number_result *result = NULL;

//     if (!bundle || limit <= 0 || offset < 0) goto finish;

//     wiiauto_device_db_key_number_get_lowest(bundle, limit, offset, &len, &result);
//     if (len > 0) {

//     } else {
//         lua_pushnil(ls);
//     }

// finish:
//     return 1;
// }

// int wiiauto_lua_remove_bundle_key_number(lua_State *ls)
// {
//     const char *bundle = luaL_optstring(ls, 1, NULL);
//     const char *key = luaL_optstring(ls, 2, NULL);

//     if (!bundle || !key) goto finish;

//     wiiauto_device_db_key_number_remove(bundle, key);

// finish:
//     return 0;
// }
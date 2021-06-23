#include "api.h"
#include "wiiauto/device/device_db.h"

int wiiauto_lua_db_email_add(lua_State *ls)
{   
    const char *email = luaL_optstring(ls, 1, NULL);
    const char *password = luaL_optstring(ls, 2, NULL);

    if (!email || !password) goto finish;

    wiiauto_device_db_email_add(email, password);

finish:
    return 0;
}

int wiiauto_lua_db_email_set_appleid_register_state(lua_State *ls)
{
    const char *email = luaL_optstring(ls, 1, NULL);
    const char *password = luaL_optstring(ls, 2, NULL);
    const int state = luaL_optinteger(ls, 3, -1);

    if (!email || !password || state < 0) goto finish;

    wiiauto_device_db_email_set_appleid_register_state(email, password, state);

finish:
    return 0;
}

int wiiauto_lua_db_email_get_appleid_unregistered(lua_State *ls)
{
    const char *serial = luaL_optstring(ls, 1, NULL);
    const int auto_register = luaL_optinteger(ls, 2, 0);

    char *email = NULL;
    char *password = NULL;

    if (!serial) {
        lua_pushnil(ls);
        goto finish;
    }

    wiiauto_device_db_email_get_appleid_unregistered(serial, &email, &password, auto_register);

    if (email && password) {
        lua_newtable(ls);

        lua_pushstring(ls, email);
        lua_setfield(ls, -2, "email");

        lua_pushstring(ls, password);
        lua_setfield(ls, -2, "password");
    } else {
        lua_pushnil(ls);
    }

    if (email) {
        free(email);
    }
    if (password) {
        free(password);
    }

finish:
    return 1;
}

int wiiauto_lua_db_email_get_appleid_unregistered_alike(lua_State *ls)
{
    const char *serial = luaL_optstring(ls, 1, NULL);    
    const char *alike = luaL_optstring(ls, 2, NULL);
    const int auto_register = luaL_optinteger(ls, 3, 0);

    char *email = NULL;
    char *password = NULL;

    if (!serial || !alike) {
        lua_pushnil(ls);
        goto finish;
    }

    wiiauto_device_db_email_get_appleid_unregistered_alike(serial, &email, &password, alike, auto_register);

    if (email && password) {
        lua_newtable(ls);

        lua_pushstring(ls, email);
        lua_setfield(ls, -2, "email");

        lua_pushstring(ls, password);
        lua_setfield(ls, -2, "password");
    } else {
        lua_pushnil(ls);
    }

    if (email) {
        free(email);
    }
    if (password) {
        free(password);
    }

finish:
    return 1;
}

int wiiauto_lua_db_email_add_appleid_machine(lua_State *ls)
{
    const char *serial = luaL_optstring(ls, 1, NULL);
    const char *email = luaL_optstring(ls, 2, NULL);
    const char *password = luaL_optstring(ls, 3, NULL);

    if (!email || !password || !serial) goto finish;

    wiiauto_device_db_email_add_appleid_machine(serial, email, password);

finish:
    return 0;
}
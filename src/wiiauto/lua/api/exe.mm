#include "api.h"
#include <string>

int wiiauto_lua_exe(lua_State *ls)
{
    const char *cmd;

    cmd = luaL_optstring(ls, 1, NULL);
    if (cmd) {
        std::string scmd = cmd;
        scmd += " &> /dev/null";
        system(scmd.c_str());
    }

    return 0;
}
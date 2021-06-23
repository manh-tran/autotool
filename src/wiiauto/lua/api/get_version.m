#include "api.h"
#include "wiiauto/version.h"

int wiiauto_lua_get_version(lua_State *ls)
{
    lua_pushstring(ls, __wiiauto_version__);
    return 1;
}
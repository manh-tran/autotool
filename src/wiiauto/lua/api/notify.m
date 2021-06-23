#include "api.h"
#import <notify.h>

int wiiauto_lua_post_notification(lua_State *ls)
{
    const char *ids = luaL_optstring(ls, 1, NULL);
    if (!ids) goto finish;

    notify_post(ids);

finish:
    return 0;
}
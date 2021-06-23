#include "api.h"
#include "openssl/md5.h"

int wiiauto_lua_md5(lua_State *ls)
{
    const char *s = luaL_optstring(ls, 1, NULL);
    unsigned char hash[MD5_DIGEST_LENGTH];
    char md5string[33];
    int i;
    
    if (!s) {
        lua_pushstring(ls, "");
    } else {

        MD5((const unsigned char *)s, strlen(s), hash);
        memset(md5string, 0, 33);
        for(i = 0; i < 16; ++i) {
            sprintf(&md5string[i*2], "%02x", (unsigned int)hash[i]);
        }

        lua_pushstring(ls, md5string);
    }

    return 1;
}
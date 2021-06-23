#include "api.h"

#import <AudioToolbox/AudioServices.h>

int wiiauto_lua_vibrate(lua_State *ls)
{
#if WIIAUTO_DEBUG_LUA_API == 1
    printf("wiiauto_lua_vibrate_start\n");
#endif

    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate); 

#if WIIAUTO_DEBUG_LUA_API == 1
    printf("wiiauto_lua_vibrate_end\n");
#endif
    return 0;
}
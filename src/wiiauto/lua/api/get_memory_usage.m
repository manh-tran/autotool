#include "api.h"

#import <mach/mach.h>

int wiiauto_lua_get_memory_usage(lua_State *ls)
{
    struct task_basic_info info;
    mach_msg_type_number_t size = TASK_BASIC_INFO_COUNT;
    kern_return_t kerr = task_info(mach_task_self(),
                                TASK_BASIC_INFO,
                                (task_info_t)&info,
                                &size);
    if( kerr == KERN_SUCCESS ) {
        lua_pushinteger(ls, info.resident_size);
    } else {
        lua_pushinteger(ls, 0);
    }
    return 1;
}
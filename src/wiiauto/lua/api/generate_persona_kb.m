#include "api.h"

int wiiauto_lua_generate_persona_kb(lua_State *ls)
{
    const char *output = luaL_optstring(ls, 1, NULL);
    if (!output) {
        lua_pushboolean(ls, 0);
        return 1;
    }

    int result = 0;

    @autoreleasepool {
        
        @try {
            NSError *error;
            NSPropertyListFormat format;
            
            NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:@"/private/var/keybags/persona.kb"];
            NSData *blob = [dict objectForKey:@"BLOB"];
            
            NSMutableArray *a = [NSPropertyListSerialization propertyListWithData:blob options:NSPropertyListMutableContainersAndLeaves format:&format error:&error];
            NSMutableDictionary *a0 = a[0];
            a0[@"UserPersonaUniqueString"] = [[NSUUID UUID] UUIDString];

            NSData *blob2 = [NSPropertyListSerialization dataWithPropertyList:a format:NSPropertyListBinaryFormat_v1_0 options:0 error:NULL];
            NSMutableDictionary *dict2 = [dict mutableCopy];
            dict2[@"BLOB"] = blob2;

            NSData *outkb = [NSPropertyListSerialization dataWithPropertyList:dict2 format:NSPropertyListBinaryFormat_v1_0 options:0 error:NULL];
            [outkb writeToFile:[NSString stringWithUTF8String:output] atomically:YES];
            result = 1;
        } @catch (NSException *e) {            
        }

    }

    lua_pushboolean(ls, result);
    return 1;
}
#include "api.h"

int wiiauto_lua_get_container_metadata(lua_State *ls)
{
    const char *path = luaL_optstring(ls, 1, NULL);
    NSString *metadata_uuid = NULL;
    NSString *personal_uuid = NULL;
    NSMutableDictionary *dict;

    if (!path) goto finish;

    dict = [[NSMutableDictionary alloc] initWithContentsOfFile:[NSString stringWithUTF8String: path]];

    if (dict) {
        metadata_uuid = [dict objectForKey:@"MCMMetadataUUID"];

        if ([dict objectForKey:@"MCMMetadataUserIdentity"]) {
            NSDictionary *d = dict[@"MCMMetadataUserIdentity"];
            personal_uuid = [d objectForKey:@"personaUniqueString"];
        }
    }

finish:
    if (!metadata_uuid && !personal_uuid) {
        lua_pushnil(ls);
    } else {

        lua_newtable(ls);

        if (metadata_uuid) {
            lua_pushstring(ls, [metadata_uuid UTF8String]);
            lua_setfield(ls, -2, "metadata_uuid");
        }

        if (personal_uuid) {
            lua_pushstring(ls, [personal_uuid UTF8String]);
            lua_setfield(ls, -2, "personal_uuid");
        }

    }

    dict = nil;
    metadata_uuid = nil;
    personal_uuid = nil;

    return 1;
}

int wiiauto_lua_set_container_metadata(lua_State *ls)
{  
    const char *path = luaL_optstring(ls, 1, NULL);
    const char *metadata_uuid = luaL_optstring(ls, 2, NULL);
    const char *personal_uuid = luaL_optstring(ls, 3, NULL);

    NSMutableDictionary *dict;
    NSError *err;
    NSDictionary* dict2;

    @try {
        if (!path) goto finish;
        if (!metadata_uuid && !personal_uuid) goto finish;

        dict = [[NSMutableDictionary alloc] initWithContentsOfFile:[NSString stringWithUTF8String:path]];
        if (!dict) goto finish;


        if (metadata_uuid) {
            dict[@"MCMMetadataUUID"] = [NSString stringWithUTF8String:metadata_uuid];
        }

        if (personal_uuid) {
            if ([dict objectForKey:@"MCMMetadataUserIdentity"]) {
                NSMutableDictionary *d = [dict[@"MCMMetadataUserIdentity"] mutableCopy];
                d[@"personaUniqueString"] = [NSString stringWithUTF8String:personal_uuid];
                dict[@"MCMMetadataUserIdentity"] = d;
            }
        }
        
        dict2 = [NSPropertyListSerialization dataFromPropertyList:dict
            format:NSPropertyListBinaryFormat_v1_0
            errorDescription:&err];
        [dict2 writeToFile:[NSString stringWithUTF8String:path] atomically:YES];

    } @catch (NSException *e) {

    }

finish:
    return 0;
}
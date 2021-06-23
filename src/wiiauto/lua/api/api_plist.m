#include "api.h"
#include "../lua.h"
#include "wiiauto/file/file.h"

static int __plist_string_to_json(lua_State *ls)
{
    const char *s;
    NSMutableDictionary *pl;
    NSData *jd;
    NSString *js;

    s = luaL_optstring(ls, 1, NULL);
    if (!s) {
        lua_pushstring(ls, "{}");
        goto finish;
    }

    @try {
        jd = [[NSString stringWithUTF8String:s] dataUsingEncoding:NSUTF8StringEncoding];
        js = [NSJSONSerialization JSONObjectWithData:jd options:0 error:nil];
    } @catch (NSException *e) {
        pl = nil;
        jd = nil;
    }

    if (js) {
        lua_pushstring(ls, [js UTF8String]);
    } else {
        lua_pushstring(ls, "{}");
    }

    pl = nil;
    jd = nil;
    js = nil;
finish:
    return 1;
}

static int __file_to_json(lua_State *ls) 
{
    const char *s;
    buffer b, full;
    NSMutableDictionary *pl;
    NSError *e; 
    NSData *jd;
    NSString *js;

    s = luaL_optstring(ls, 1, NULL);
    if (!s) {
        lua_pushstring(ls, "{}");
        goto finish;
    }

    buffer_new(&b);
    buffer_new(&full);
    wiiauto_lua_process_input_path(ls, s, b);
    buffer_get_ptr(b, &s);
    wiiauto_convert_url(s, full);
    buffer_get_ptr(full, &s);

    @try {
        pl = [[NSMutableDictionary alloc] initWithContentsOfFile: [NSString stringWithUTF8String:s]];
        jd = [NSJSONSerialization dataWithJSONObject:pl options:0 error:&e];    
    } @catch (NSException *e) {
        pl = nil;
        jd = nil;
    }

    js = nil;
    if (jd) {
        @try {
            js = [[NSString alloc] initWithData:jd encoding:NSUTF8StringEncoding];
        } @catch (NSException *e) {
            js = nil;
        }
    }
    
    if (js) {
        lua_pushstring(ls, [js UTF8String]);
    } else {
        lua_pushstring(ls, "{}");
    }

    pl = nil;
    jd = nil;
    js = nil;
    e = nil;
    release(b.iobj);
    release(full.iobj);
finish:
    return 1;
}

static int __json_to_file(lua_State *ls)
{
    const char *s;
    const char *path;
    buffer b, full;
    NSDictionary *d;

    s = luaL_optstring(ls, 1, NULL);
    path = luaL_optstring(ls, 2, NULL);

    if (!s || !path) {
        lua_pushboolean(ls, 0);
        goto finish;
    }

    buffer_new(&b);
    buffer_new(&full);
    wiiauto_lua_process_input_path(ls, path, b);
    buffer_get_ptr(b, &path);
    wiiauto_convert_url(path, full);
    buffer_get_ptr(full, &path);

    @try {
        d = [NSJSONSerialization JSONObjectWithData:[[NSString stringWithUTF8String:s] dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
    } @catch (NSException *e) {
        d = nil;
    }

    @try {
        if (d) {
            [d writeToFile:[NSString stringWithUTF8String:path] atomically:YES];
            lua_pushboolean(ls, 1);
        } else {
            lua_pushboolean(ls, 0);
        }
    } @catch (NSException *e) {
        lua_pushboolean(ls, 0);
    }

    release(b.iobj);
    release(full.iobj);

finish:
    return 1;
}

static const struct luaL_Reg functions [] = 
{
    {"fileToJson", __file_to_json},
    {"jsonToFile", __json_to_file},
    ("plistStringToJson", __plist_string_to_json),
    {NULL, NULL}
};

void wiiauto_lua_register_json(lua_State *ls)
{
    luaL_register(ls, "wiiplist", functions);
}
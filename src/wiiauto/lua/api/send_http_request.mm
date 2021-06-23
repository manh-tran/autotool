#include "api.h"
#include <string>
#include "log/remote_log.h"

int wiiauto_lua_send_http_request(lua_State *ls)
{
    NSMutableURLRequest *request = nil;
    
    if (lua_istable(ls, 1)) {

        {
            lua_getfield(ls, 1, "url");
            const char *str = luaL_optstring(ls, -1, NULL);
            if (str) {
                NSURL *url = [NSURL URLWithString:[NSString stringWithUTF8String:str]];
                request = [NSMutableURLRequest requestWithURL:url];
            }
            lua_pop(ls, 1);            
        }

        if (request) {
            lua_getfield(ls, 1, "method");
            const char *str = luaL_optstring(ls, -1, NULL);
            if (str) {
                [request setHTTPMethod:[NSString stringWithUTF8String:str]];
            }
            lua_pop(ls, 1);
        }

        if (request) {
            lua_getfield(ls, 1, "body");
            size_t len = 0;
            const char *str = lua_tolstring(ls, -1, &len);
            if (str) {
                remote_log("SELFHTTP-length: %p | %u\n", str, len);
                NSData *data = [NSData dataWithBytes:str length:len];
                [request setHTTPBody:data];
            }
            lua_pop(ls, 1);
        }
        
        if (request) {
            lua_getfield(ls, 1, "headers");
            if (lua_istable(ls, -1)) {

                lua_pushnil(ls);
                while (lua_next(ls, -2)) {  
                    lua_pushvalue(ls, -2);  
                    const char *key = luaL_optstring(ls, -1, NULL);
                    const char *value = luaL_optstring(ls, -2, NULL);
                    [request setValue:[NSString stringWithUTF8String:value] forHTTPHeaderField:[NSString stringWithUTF8String:key]];
                    lua_pop(ls, 2);  
                } 

            }
            lua_pop(ls, 1);
        }

        dispatch_semaphore_t    sem;  
        __block NSData *result;  

        result = nil;  

        sem = dispatch_semaphore_create(0);  

        [[[NSURLSession sharedSession] dataTaskWithRequest:request  
            completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {  
            if (error == nil) {  
                result = data;  
            }  
            dispatch_semaphore_signal(sem);  
        }] resume];  

        dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);  
        if (result) {
            lua_pushlstring(ls, (const char *)[result bytes], [result length]);
        } else {
            lua_pushnil(ls);
        }

    } else {
        lua_pushnil(ls);
    }

    return 1;
}
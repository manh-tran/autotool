#include "api.h"
#include "wiiauto/common/common.h"

int wiiauto_lua_download_image(lua_State *ls)
{
    const char *url = luaL_optstring(ls, 1, NULL);
    const char *out_path = luaL_optstring(ls, 2, NULL);

    if (!url || !out_path) {
        lua_pushboolean(ls, 0);
        return 1;
    }

    @autoreleasepool {

        @try {
            NSString *path = [[NSString stringWithUTF8String:url] stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
            NSData * imageData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString:path]];
            if (imageData) {
                UIImage *img = [UIImage imageWithData: imageData];
                if (img && img.size.width > 0 && img.size.height > 0) {

                    // [imageData writeToFile:[NSString stringWithUTF8String:out_path] atomically:YES];

                    [UIImagePNGRepresentation(img) writeToFile:[NSString stringWithUTF8String:out_path] atomically:YES];

                    lua_pushboolean(ls, 1);
                } else {
                    lua_pushboolean(ls, 0);    
                }               
            } else {
                lua_pushboolean(ls, 0);
            }         
        } @catch (NSException *e) {
            lua_pushboolean(ls, 0);
        }
        
    }

    return 1;
}
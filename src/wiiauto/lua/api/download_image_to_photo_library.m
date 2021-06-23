#include "api.h"
#include "wiiauto/common/common.h"

int wiiauto_lua_download_image_to_photo_library(lua_State *ls)
{
    const char *url = luaL_optstring(ls, 1, NULL);
    if (!url) {
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
                    UIImageWriteToSavedPhotosAlbum(img, nil, nil, nil);
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
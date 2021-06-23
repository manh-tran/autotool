#include "save_photo.h"

CFDataRef springboard_handle_request_save_photo(const __wiiauto_event_request_save_photo *input)
{   
    __wiiauto_event_result_save_photo rt;
    __wiiauto_event_result_save_photo_init(&rt);

    @autoreleasepool {
        @try {
            UIImage *image = [UIImage imageWithContentsOfFile:[NSString stringWithUTF8String:input->full_path]];
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
            rt.result = 1;
        } @catch (NSException *e) {
            rt.result = 0;
        }
    }

    return CFDataCreate(NULL, (const UInt8 *)&rt, sizeof(rt));
}
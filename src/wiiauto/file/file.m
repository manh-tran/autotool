#include "file.h"
#include "wiiauto/device/device.h"

int wiiauto_parse_url(const char *url, const char **mode, const buffer b)
{
    const char *name;

    buffer_erase(b);

    int ret = 0;
    if (strncmp(url, WIIAUTO_SCRIPT_URL, sizeof(WIIAUTO_SCRIPT_URL) - 1) == 0) {
        *mode = "wb+";
        name = url + sizeof(WIIAUTO_SCRIPT_URL) - 1;

        buffer_append(b, WIIAUTO_ROOT_SCRIPTS_PATH, strlen(WIIAUTO_ROOT_SCRIPTS_PATH));
        if (name[0] == '/') {
            buffer_append(b, name + 1, strlen(name + 1));
        } else {
            buffer_append(b, name, strlen(name));
        }
        ret = 1;
    } else if (strncmp(url, WIIAUTO_INTERNAL_URL, sizeof(WIIAUTO_INTERNAL_URL) - 1) == 0) {
        *mode = "wb+";
        name = url + sizeof(WIIAUTO_INTERNAL_URL) - 1;

        buffer_append(b, WIIAUTO_ROOT_PATH, strlen(WIIAUTO_ROOT_PATH));
        if (name[0] == '/') {
            buffer_append(b, name + 1, strlen(name + 1));
        } else {
            buffer_append(b, name, strlen(name));
        }
        ret = 1;
    } else if (strncmp(url, WIIAUTO_RESOURCE_URL, sizeof(WIIAUTO_RESOURCE_URL) - 1) == 0) {
        *mode = "wb+";
        name = url + sizeof(WIIAUTO_RESOURCE_URL) - 1;
        if (name[0] == '/') {
            name++;
        }

        NSBundle *bundle = [[NSBundle alloc] initWithPath:[NSString stringWithUTF8String:WIIAUTO_ROOT_RESOURCE_PATH]];
        // NSString *nspath = [bundle pathForResource:[NSString stringWithUTF8String:name] ofType:nil];

        // const char *path = [nspath UTF8String];
        NSString *bp = [bundle resourcePath];
        const char *bps = [bp UTF8String];
        buffer_append(b, bps, strlen(bps));
        if (bps[strlen(bps) - 1] != '/') {
            buffer_append(b, "/", 1);
        }

        buffer_append(b, name, strlen(name));
        ret = 1;
    } else if (strncmp(url, IOS_FILE_URL, sizeof(IOS_FILE_URL) - 1) == 0) {
        *mode = "wb+";
        name = url + sizeof(IOS_FILE_URL) - 1;

        buffer_append(b, name, strlen(name));
        ret = 1;
    }

    return ret;
}

void wiiauto_convert_url(const char *url, const buffer b)
{
    const char *mode;
    int ret;
    const char *ptr;
    buffer fix;

    ret = wiiauto_parse_url(url, &mode, b);
    if (ret == 0) {
        buffer_append(b, url, strlen(url));
    }

    buffer_get_ptr(b, &ptr);
    if (strncmp(ptr, "/var", 4) == 0) {
        buffer_new(&fix);
        buffer_append(fix, "/private", strlen("/private"));
        buffer_append_buffer(fix, b);
        buffer_erase(b);
        buffer_append_buffer(b, fix);
        release(fix.iobj);
    }

    buffer_replace(b, "//", 2, "/", 1);
}
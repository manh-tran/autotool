#ifndef __wiiauto_file_h
#define __wiiauto_file_h

#if defined __cplusplus
extern "C" {
#endif

#include "cherry/core/file.h"

#define WIIAUTO_SCRIPT_URL "wiiauto_script://"
#define IOS_FILE_URL "file://"
#define WIIAUTO_INTERNAL_URL "wiiauto_internal://"
#define WIIAUTO_RESOURCE_URL "wiiauto_resource://"

int wiiauto_parse_url(const char *url, const char **mode, const buffer b);
void wiiauto_convert_url(const char *url, const buffer b);

#if defined __cplusplus
}
#endif


#endif
#include "handler.h"
#include "wiiauto/common/common.h"

#import <BackBoardServices/BackBoardServices.h>

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
// 
void wiiauto_tool_run_kill_app(const int argc, const char **argv)
{
    common_kill_app(argv[2]);
}
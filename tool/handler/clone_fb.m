#include "handler.h"
#include "wiiauto/util/util.h"

void wiiauto_tool_run_clone_fb(const int argc, const char **argv)
{
    int i;
    char buf[2048];

    int from = atoi(argv[2]);
    int to = atoi(argv[3]);

    for (i = from; i <= to; ++i) {

        sprintf(buf, "com.facebook.Facebook.app%d", i);
        wiiauto_util_clone_facebook(buf, 1);

    }
}
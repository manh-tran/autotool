#include "api.h"

#include <ifaddrs.h>
#include <arpa/inet.h>

static NSString *getIPAddress() {

    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];

                }

            }

            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    if (interfaces) {
        freeifaddrs(interfaces);
    }
    return address;

} 

int wiiauto_lua_get_local_ipv4_address(lua_State *ls)
{
    NSString *addr = getIPAddress();

    if (addr) {
        lua_pushstring(ls, [addr UTF8String]);
    } else {
        lua_pushstring(ls, "");
    }
    return 1;
}
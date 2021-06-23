#include "api.h"
#include "wiiauto/common/common.h"
#include "log/remote_log.h"

@import NetworkExtension;

int wiiauto_lua_connect_to_wifi(lua_State *ls)
{
    const char *ssid = luaL_optstring(ls, 1, NULL);
    const char *pass = luaL_optstring(ls, 2, NULL);

    if (!ssid || !pass) goto finish;

    // common_connect_wifi(ssid, pass);

    //  @try {

    //     @autoreleasepool {

    //         NSString *ssidToConnect = [NSString stringWithUTF8String:ssid];
    //         remote_log("connect to: %s | %s\n", ssid, pass);

    //         NEHotspotConfiguration * configuration = [[NEHotspotConfiguration alloc] initWithSSID:ssidToConnect passphrase:[NSString stringWithUTF8String:pass] isWEP:NO];
    //         configuration.joinOnce = NO;

    //         [[NEHotspotConfigurationManager sharedManager] getConfiguredSSIDsWithCompletionHandler:^(NSArray<NSString *> * _Nonnull wifiList) {

    //             if ([wifiList containsObject:ssidToConnect]) {
    //                 remote_log("remove ssid\n");
    //                 [[NEHotspotConfigurationManager sharedManager] removeConfigurationForSSID:ssidToConnect];
    //             }

    //             remote_log("connect\n");
    //             [[NEHotspotConfigurationManager sharedManager] applyConfiguration:configuration completionHandler:^(NSError *error){
    //                 if (error != nil) {
    //                     remote_log("has error: %s\n", [[error localizedDescription] UTF8String]);
    //                 } else {
    //                     remote_log("is it ok!?\n");
    //                 }
    //             }];
    //         }];  

    //     }

    // } @catch (NSException *e) {

    // }


finish:
    return 0;
}
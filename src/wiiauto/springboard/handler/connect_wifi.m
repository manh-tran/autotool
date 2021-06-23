#include "connect_wifi.h"
#include "log/remote_log.h"

@import NetworkExtension;

CFDataRef springboard_handle_connect_wifi(const __wiiauto_event_connect_wifi *input)
{
    const char *ssid = input->ssid;
    const char *pass = input->pass;

    if (!ssid || !pass) goto finish;


    @try {

        @autoreleasepool {

            NSString *ssidToConnect = [NSString stringWithUTF8String:ssid];
            remote_log("connect to: %s | %s\n", ssid, pass);

            NEHotspotConfiguration * configuration = [[NEHotspotConfiguration alloc] initWithSSID:ssidToConnect];
            configuration.joinOnce = NO;

            [[NEHotspotConfigurationManager sharedManager] getConfiguredSSIDsWithCompletionHandler:^(NSArray<NSString *> * _Nonnull wifiList) {

                if ([wifiList containsObject:ssidToConnect]) {
                    remote_log("remove ssid\n");
                    [[NEHotspotConfigurationManager sharedManager] removeConfigurationForSSID:ssidToConnect];
                }

                remote_log("connect\n");
                [[NEHotspotConfigurationManager sharedManager] applyConfiguration:configuration completionHandler:^(NSError *error){
                    if (error != nil) {
                        remote_log("has error\n");
                    } else {
                        remote_log("is it ok!?\n");
                    }
                }];
            }];  

        }

    } @catch (NSException *e) {

    }

finish:
    return NULL;
}
// #include "device_pref.h"
// #import <notify.h>
// #include "log/remote_log.h"

// NSDictionary *__modifiedKeys__ = nil;
// NSArray *__appsChosen__ = nil;
// NSDictionary *__pref_configs__ = nil;
// unsigned char __mgoverrided__ = 1;
// unsigned char __init__ = 0;

// extern CFTypeRef MGCopyAnswer(CFStringRef);

// static void __init()
// {
//     if (!__init__) {
//         __init__ = 1;

//         NSUserDefaults *prefs = [[NSUserDefaults alloc] initWithSuiteName:@"com.tonyk7.MGSpoofHelperPrefsSuite"];
// 	    __modifiedKeys__ = [prefs objectForKey:@"modifiedKeys"];
//         __appsChosen__ = [prefs objectForKey:@"spoofApps"];
//         __pref_configs__ = [prefs objectForKey:@"configs"];
//     }
// }

// void wiiauto_device_set_pref(NSString *key, NSString *value)
// {
//     __init();

//     NSUserDefaults *prefs = [[NSUserDefaults alloc] initWithSuiteName:@"com.tonyk7.MGSpoofHelperPrefsSuite"];
//     NSMutableDictionary *newDict = ((NSDictionary *)[prefs objectForKey:@"modifiedKeys"]).mutableCopy;
//     if (!newDict) {
//         [prefs setValue:@{} forKey:@"modifiedKeys"];
//         newDict = @{}.mutableCopy;
//     }
//     newDict[key] = value;
//     [prefs setValue:newDict forKey:@"modifiedKeys"];

//     __modifiedKeys__ = newDict;
//     [prefs synchronize];
//     notify_post("com.tonyk7.mgspoof/modifiedKeyUpdated");
// }

// NSString *wiiauto_device_get_pref(NSString *key)
// {    
//     __init();

//     if (__modifiedKeys__) {
//         NSString *s = [NSString stringWithFormat:@"my dictionary is %@", __modifiedKeys__];
//         const char *ptr = [s UTF8String];
//         remote_log("dict: %s\n", ptr);
//     }

//     if (__modifiedKeys__ && __mgoverrided__ && [__modifiedKeys__ objectForKey:key]) {
//         return __modifiedKeys__[key];
//     } else {
//         CFTypeRef t = MGCopyAnswer((__bridge CFStringRef)key);
//         if (t) {
//             return (__bridge NSString *)t;
//         } 
//     }
//     return nil;

//     // CFTypeRef t = MGCopyAnswer((__bridge CFStringRef)key);
//     // if (t) {
//     //     return (__bridge NSString *)t;
//     // } else {
//     //     if (__modifiedKeys__ && __mgoverrided__) {
//     //         return __modifiedKeys__[key];
//     //     }
//     // }
//     // return nil;
// }

// static void __refresh_mgflag()
// {
//     __init();

// 	@try {
// 		if (__pref_configs__) {
// 			NSString *state = __pref_configs__[@"override_state"];
// 			if (state) {
// 				if ([state isEqualToString:@"all"]) {
// 					__mgoverrided__ = 1;
// 				} else if ([state isEqualToString:@"disabled"]) {
// 					__mgoverrided__ = 0;
// 				} else if ([state isEqualToString:@"separately"]) {
// 					if (__appsChosen__) {
// 						if ([__appsChosen__ containsObject:[NSBundle mainBundle].bundleIdentifier]) {
// 							__mgoverrided__ = 1;
// 						} else {
// 							__mgoverrided__ = 0;
// 						}
// 					} else {
// 						__mgoverrided__ = 0;
// 					}
// 				}
// 				state = nil;
// 			}
// 		} else {
// 			__mgoverrided__ = 1;
// 		}
// 	} @catch (NSException *e) {
// 		__mgoverrided__ = 1;
// 	}
// }

// void wiiauto_device_set_override_state(const __wiiauto_device_pref_override s)
// {
//     __init();

//     NSUserDefaults *prefs = [[NSUserDefaults alloc] initWithSuiteName:@"com.tonyk7.MGSpoofHelperPrefsSuite"];
//     NSMutableDictionary *newDict = ((NSDictionary *)[prefs objectForKey:@"configs"]).mutableCopy;
//     if (!newDict) {
//         [prefs setValue:@{} forKey:@"configs"];
//         newDict = @{}.mutableCopy;
//     }
//     switch (s) {
//         case WIIAUTO_DEVICE_OVERRIDE_ALL:
//             newDict[@"override_state"] = @"all";
//             break;
//         case WIIAUTO_DEVICE_OVERRIDE_DISABLED:
//             newDict[@"override_state"] = @"disabled";
//             break;
//         case WIIAUTO_DEVICE_OVERRIDE_SEPARATELY:
//             newDict[@"override_state"] = @"separately";
//             break;
//         default:
//             break;
//     }
    
//     [prefs setValue:newDict forKey:@"configs"];

//     __pref_configs__ = newDict;
//     __refresh_mgflag();

//     [prefs synchronize];

//     notify_post("com.tonyk7.mgspoof/configUpdated");
// }

// void wiiauto_device_get_override_state(__wiiauto_device_pref_override *s)
// {
//     __init();

//     *s = WIIAUTO_DEVICE_OVERRIDE_ALL;

//     if (__pref_configs__) {
//         NSString *state = __pref_configs__[@"override_state"];
//         if (state) {
//             if ([state isEqualToString:@"all"]) {
//                 *s = WIIAUTO_DEVICE_OVERRIDE_ALL;
//             } else if ([state isEqualToString:@"disabled"]) {
//                 *s = WIIAUTO_DEVICE_OVERRIDE_DISABLED;
//             } else if ([state isEqualToString:@"separately"]) {
//                 *s = WIIAUTO_DEVICE_OVERRIDE_SEPARATELY;
//             }
//             state = nil;
//         }
//     }
// }

// void wiiauto_device_add_override_app(const char *bundle)
// {
//     __init();

//     NSUserDefaults *prefs = [[NSUserDefaults alloc] initWithSuiteName:@"com.tonyk7.MGSpoofHelperPrefsSuite"];
//     NSArray *oldArray = (NSArray *)[prefs objectForKey:@"spoofApps"];
//     if (!oldArray) {
// 		[prefs setValue:@[] forKey:@"spoofApps"];
// 		oldArray = @[];
// 	}
//     NSMutableArray *tempArray = oldArray.mutableCopy;
//     NSString *nsbundle = [NSString stringWithUTF8String:bundle];

//     if (![tempArray containsObject:nsbundle]) {
//         [tempArray addObject:nsbundle];
//     }
    
//     [prefs setValue:tempArray forKey:@"spoofApps"];

//     __appsChosen__= tempArray;
//     __refresh_mgflag();

//     [prefs synchronize];

//     notify_post("com.tonyk7.mgspoof/appsChosenUpdated");
// }

// void wiiauto_device_remove_override_app(const char *bundle)
// {
//     __init();

//     NSUserDefaults *prefs = [[NSUserDefaults alloc] initWithSuiteName:@"com.tonyk7.MGSpoofHelperPrefsSuite"];
//     NSArray *oldArray = (NSArray *)[prefs objectForKey:@"spoofApps"];
//     if (!oldArray) {
// 		[prefs setValue:@[] forKey:@"spoofApps"];
// 		oldArray = @[];
// 	}
//     NSMutableArray *tempArray = oldArray.mutableCopy;
//     NSString *nsbundle = [NSString stringWithUTF8String:bundle];

//     if ([tempArray containsObject:nsbundle]) {
//         [tempArray removeObject:nsbundle];
//     }
    
//     [prefs setValue:tempArray forKey:@"spoofApps"];

//     __appsChosen__= tempArray;
//     __refresh_mgflag();

//     [prefs synchronize];

//     notify_post("com.tonyk7.mgspoof/appsChosenUpdated");
// }
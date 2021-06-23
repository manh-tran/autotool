// #include "api.h"
// #include "wiiauto/device/device_pref.h"
// #import <Foundation/Foundation.h>
// #import <sys/utsname.h>

// static NSDictionary *codeForCountryDictionary = nil;

// static NSString *__country_name_to_code(const char *s)
// {
//     if (!codeForCountryDictionary) {
//         NSArray *countryCodes = [NSLocale ISOCountryCodes];
//         NSMutableArray *countries = [NSMutableArray arrayWithCapacity:[countryCodes count]];

//         for (NSString *countryCode in countryCodes)
//         {
//             NSString *identifier = [NSLocale localeIdentifierFromComponents: [NSDictionary dictionaryWithObject: countryCode forKey: NSLocaleCountryCode]];
//             NSString *country = [[[NSLocale alloc] initWithLocaleIdentifier:@"en_UK"] displayNameForKey: NSLocaleIdentifier value: identifier];
//             [countries addObject: country];
//         }

//         codeForCountryDictionary = [[NSDictionary alloc] initWithObjects:countryCodes forKeys:countries];
//     }

//     return [codeForCountryDictionary objectForKey:[NSString stringWithUTF8String:s]];
// }

// @interface ASIdentifierManager : NSObject

// @property (nonatomic, readonly) NSUUID *advertisingIdentifier;
// @property (getter=isAdvertisingTrackingEnabled, nonatomic, readonly) BOOL advertisingTrackingEnabled;

// + (id)sharedManager;

// - (NSUUID *)advertisingIdentifier;
// - (BOOL)isAdvertisingTrackingEnabled;

// @end

// int wiiauto_lua_set_app_preference(lua_State *ls)
// {
//     const char *key = luaL_optstring(ls, 1, NULL);
//     const char *value = luaL_optstring(ls, 2, NULL);
//     NSString *nsvalue = nil;

//     if (!key || !value) goto finish;
//     if (strlen(value) == 0) goto finish;

//     nsvalue = [NSString stringWithUTF8String: value];

//     if (strcmp(key, "DeviceType") == 0) {
//         wiiauto_device_set_pref(@"DeviceClass", nsvalue);

//     } else if (strcmp(key, "DeviceName") == 0) {
//         wiiauto_device_set_pref(@"UserAssignedDeviceName", nsvalue);

//     } else if (strcmp(key, "DeviceModel") == 0) {
//         wiiauto_device_set_pref(@"ProductType", nsvalue);

//     } else if (strcmp(key, "DeviceScreen") == 0) {
        
//     } else if (strcmp(key, "BuildVersion") == 0) {
//         wiiauto_device_set_pref(@"BuildVersion", nsvalue);

//     } else if (strcmp(key, "OSVersion") == 0) {
//         wiiauto_device_set_pref(@"ProductVersion", nsvalue);

//     } else if (strcmp(key, "IDFA") == 0) {
//         wiiauto_device_set_pref(@"WiiAuto_IDFA", nsvalue);

//     } else if (strcmp(key, "VendorID") == 0) {
//         wiiauto_device_set_pref(@"WiiAuto_VendorID", nsvalue);

//     } else if (strcmp(key, "CountryName") == 0) {
//         // wiiauto_device_set_pref(@"WiiAuto_CountryName", nsvalue);

//         NSString *code = __country_name_to_code(value);
//         if (code) {
//             wiiauto_device_set_pref(@"WiiAuto_CountryCode", code);
//             code = nil;
//         }

//     } else if (strcmp(key, "Webkit") == 0) {
//         wiiauto_device_set_pref(@"WiiAuto_Webkit", nsvalue);

//         @try {
//             NSString* path = @"/System/Library/Frameworks/WebKit.framework/Info.plist";
//             NSMutableDictionary* dict = [NSDictionary dictionaryWithContentsOfFile:path].mutableCopy; 
//             NSString *old = [dict valueForKey:@"CFBundleVersion"];
//             NSString *gi = [dict valueForKey:@"CFBundleGetInfoString"];
//             gi = [gi stringByReplacingOccurrencesOfString:old withString:nsvalue];
//             dict[@"CFBundleGetInfoString"] = gi;
//             dict[@"CFBundleVersion"] = nsvalue;
//             [dict writeToFile:@"/System/Library/Frameworks/WebKit.framework/Info.plist" atomically:YES];
//             dict = nil;
//         } @catch (NSException *e) {

//         }
        
//     } else if (strcmp(key, "Safari") == 0) {
//         wiiauto_device_set_pref(@"WiiAuto_Safari", nsvalue);

//         @try {
//             NSString* path = @"/System/Library/Frameworks/SafariServices.framework/Info.plist";
//             NSMutableDictionary* dict = [NSDictionary dictionaryWithContentsOfFile:path].mutableCopy; 
//             dict[@"CFBundleVersion"] = nsvalue;
//             [dict writeToFile:@"/System/Library/Frameworks/SafariServices.framework/Info.plist" atomically:YES];
//             dict = nil;
//         } @catch (NSException *e) {

//         }

//         @try {
//             NSString* path = @"/Applications/MobileSafari.app/Info.plist";
//             NSMutableDictionary* dict = [NSDictionary dictionaryWithContentsOfFile:path].mutableCopy; 
//             dict[@"CFBundleVersion"] = nsvalue;
//             [dict writeToFile:@"/Applications/MobileSafari.app/Info.plist" atomically:YES];
//             dict = nil;
//         } @catch (NSException *e) {

//         }
//     }

//     usleep(0.05 * 1000000);

//     nsvalue = nil;

// finish:
//     return 0;
// }

// int wiiauto_lua_get_app_preference(lua_State *ls)
// {
//     const char *key = luaL_optstring(ls, 1, NULL);
//     NSString *nsvalue = nil;

//     if (!key) goto finish;

//     if (strcmp(key, "DeviceType") == 0) {
//         // nsvalue = wiiauto_device_get_pref(@"DeviceClass");
//         nsvalue = [[UIDevice currentDevice] model];

//     } else if (strcmp(key, "DeviceName") == 0) {
//         // nsvalue = wiiauto_device_get_pref(@"UserAssignedDeviceName");
//         nsvalue = [[UIDevice currentDevice] name];

//     } else if (strcmp(key, "DeviceModel") == 0) {
//         // nsvalue = wiiauto_device_get_pref(@"ProductType");

//         struct utsname systemInfo;
//         uname(&systemInfo);
//         nsvalue = [NSString stringWithCString:systemInfo.machine
//                                         encoding:NSUTF8StringEncoding];

//     } else if (strcmp(key, "DeviceScreen") == 0) {
        
//     } else if (strcmp(key, "BuildVersion") == 0) {
//         nsvalue = wiiauto_device_get_pref(@"BuildVersion");

//     } else if (strcmp(key, "OSVersion") == 0) {
//         // nsvalue = wiiauto_device_get_pref(@"ProductVersion");
//         nsvalue = [[UIDevice currentDevice] systemVersion];

//     } else if (strcmp(key, "IDFA") == 0) {
//         // nsvalue = wiiauto_device_get_pref(@"WiiAuto_IDFA");

//         @try {
//             nsvalue = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
//         } @catch (NSException *e) {
//             nsvalue = nil;
//         }

//     } else if (strcmp(key, "VendorID") == 0) {
//         // nsvalue = wiiauto_device_get_pref(@"WiiAuto_VendorID");
//         nsvalue = [[[UIDevice currentDevice] identifierForVendor] UUIDString];

//     } else if (strcmp(key, "CountryName") == 0) {
//         // nsvalue = wiiauto_device_get_pref(@"WiiAuto_CountryName");
//         NSString *code = [[NSLocale currentLocale] countryCode];
//         nsvalue = [[NSLocale currentLocale] localizedStringForCountryCode: code];

//     } else if (strcmp(key, "Webkit") == 0) {
//         // nsvalue = wiiauto_device_get_pref(@"WiiAuto_Webkit");
        
//         NSString* path = @"/System/Library/Frameworks/WebKit.framework/Info.plist";
//         NSDictionary* dict = [NSDictionary dictionaryWithContentsOfFile:path]; 
//         nsvalue = [dict valueForKey:@"CFBundleVersion"];
//         dict = nil;
//         path = nil;

//     } else if (strcmp(key, "Safari") == 0) {
//         // nsvalue = wiiauto_device_get_pref(@"WiiAuto_Safari");

//         NSString* path = @"/System/Library/Frameworks/SafariServices.framework/Info.plist";
//         NSDictionary* dict = [NSDictionary dictionaryWithContentsOfFile:path]; 
//         nsvalue = [dict valueForKey:@"CFBundleVersion"];
//         dict = nil;
//         path = nil;
//     }

// finish:
//     if (nsvalue) {
//         lua_pushstring(ls, [nsvalue UTF8String]);
//         nsvalue = nil;
//     } else {
//         lua_pushnil(ls);
//     }

//     return 1;
// }

// int wiiauto_lua_set_app_preference_state(lua_State *ls)
// {
//     int s = luaL_optnumber(ls, 1, 0);
//     wiiauto_device_set_override_state(s);

//     usleep(0.05 * 1000000);

//     return 0;
// }

// int wiiauto_lua_get_app_preference_state(lua_State *ls)
// {
//     __wiiauto_device_pref_override s;
//     wiiauto_device_get_override_state(&s);  

//     lua_pushinteger(ls, s);
//     return 1;
// }

// int wiiauto_lua_set_app_bundle_overrided(lua_State *ls)
// {
//     const char *bundle = luaL_optstring(ls, 1, NULL);
//     if (bundle && strlen(bundle) > 0) {
//         wiiauto_device_add_override_app(bundle);

//         usleep(0.05 * 1000000);
//     }
//     return 0;
// }

// int wiiauto_lua_set_app_bundle_original(lua_State *ls)
// {
//     const char *bundle = luaL_optstring(ls, 1, NULL);
//     if (bundle && strlen(bundle) > 0) {
//         wiiauto_device_remove_override_app(bundle);

//         usleep(0.05 * 1000000);
//     }
//     return 0;
// }
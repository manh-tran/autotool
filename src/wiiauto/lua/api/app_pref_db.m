#include "api.h"
#import <sqlite3.h>
#include "wiiauto/file/file.h"
#include "wiiauto/device/device_db.h"

#import <Foundation/Foundation.h>
#import <sys/utsname.h>

static NSDictionary *codeForCountryDictionary = nil;

static NSString *__country_name_to_code(const char *s)
{
    if (!codeForCountryDictionary) {
        NSArray *countryCodes = [NSLocale ISOCountryCodes];
        NSMutableArray *countries = [NSMutableArray arrayWithCapacity:[countryCodes count]];

        for (NSString *countryCode in countryCodes)
        {
            NSString *identifier = [NSLocale localeIdentifierFromComponents: [NSDictionary dictionaryWithObject: countryCode forKey: NSLocaleCountryCode]];
            NSString *country = [[[NSLocale alloc] initWithLocaleIdentifier:@"en_UK"] displayNameForKey: NSLocaleIdentifier value: identifier];
            [countries addObject: country];
        }

        codeForCountryDictionary = [[NSDictionary alloc] initWithObjects:countryCodes forKeys:countries];
    }

    return [codeForCountryDictionary objectForKey:[NSString stringWithUTF8String:s]];
}

@interface ASIdentifierManager : NSObject

@property (nonatomic, readonly) NSUUID *advertisingIdentifier;
@property (getter=isAdvertisingTrackingEnabled, nonatomic, readonly) BOOL advertisingTrackingEnabled;

+ (id)sharedManager;

- (NSUUID *)advertisingIdentifier;
- (BOOL)isAdvertisingTrackingEnabled;

@end


int wiiauto_lua_set_bundle_preference(lua_State *ls)
{
    const char *bundle = luaL_optstring(ls, 1, NULL);
    const char *key = luaL_optstring(ls, 2, NULL);
    const char *value = luaL_optstring(ls, 3, NULL);
    int ret = 0;

    if (strcmp(key, "DeviceType") == 0) {
        ret = wiiauto_device_db_set(bundle, "DeviceClass", value);
    } else if (strcmp(key, "DeviceName") == 0) {
        ret = wiiauto_device_db_set(bundle, "UserAssignedDeviceName", value);
    } else if (strcmp(key, "DeviceModel") == 0) {
        ret = wiiauto_device_db_set(bundle, "ProductType", value);
    } else if (strcmp(key, "DeviceScreen") == 0) {

    } else if (strcmp(key, "BuildVersion") == 0) {
        ret = wiiauto_device_db_set(bundle, "BuildVersion", value);
    } else if (strcmp(key, "OSVersion") == 0) {
        ret = wiiauto_device_db_set(bundle, "ProductVersion", value);
    } else if (strcmp(key, "IDFA") == 0) {
        ret = wiiauto_device_db_set(bundle, "WiiAuto_IDFA", value);
    } else if (strcmp(key, "VendorID") == 0) {
        ret = wiiauto_device_db_set(bundle, "WiiAuto_VendorID", value);
    } else if (strcmp(key, "CountryName") == 0) {
        if (value) {
            @autoreleasepool {
                NSString *code = __country_name_to_code(value);
                if (code) {
                    ret = wiiauto_device_db_set(bundle, "WiiAuto_CountryCode", [code UTF8String]);
                }
            }
        } else {
            ret = wiiauto_device_db_set(bundle, "WiiAuto_CountryCode", value);
        }
    } else {
        ret = wiiauto_device_db_set_other(bundle, key, value);
    }

    lua_pushinteger(ls, ret);

    return 1;
}

int wiiauto_lua_get_bundle_preference(lua_State *ls)
{
    const char *bundle = luaL_optstring(ls, 1, NULL);
    const char *key = luaL_optstring(ls, 2, NULL);

    const char *value = NULL;

    if (strcmp(key, "DeviceType") == 0) {
        value = wiiauto_device_db_get(bundle, "DeviceClass");

    } else if (strcmp(key, "DeviceName") == 0) {
        value = wiiauto_device_db_get(bundle, "UserAssignedDeviceName");

    } else if (strcmp(key, "DeviceModel") == 0) {
        value = wiiauto_device_db_get(bundle, "ProductType");

    } else if (strcmp(key, "DeviceScreen") == 0) {
        
    } else if (strcmp(key, "BuildVersion") == 0) {
        value = wiiauto_device_db_get(bundle, "BuildVersion");

    } else if (strcmp(key, "OSVersion") == 0) {
        value = wiiauto_device_db_get(bundle, "ProductVersion");

    } else if (strcmp(key, "IDFA") == 0) {
        value = wiiauto_device_db_get(bundle, "WiiAuto_IDFA");

    } else if (strcmp(key, "VendorID") == 0) {
        value = wiiauto_device_db_get(bundle, "WiiAuto_VendorID");

    } else if (strcmp(key, "CountryName") == 0) {
        value = wiiauto_device_db_get(bundle, "WiiAuto_CountryCode");
    } else {
        value = wiiauto_device_db_get_other(bundle, key);
    }

    if (value) {
        lua_pushstring(ls, value);
        free(value);
    } else {
        lua_pushnil(ls);
    }

    return 1;
}

int wiiauto_lua_save_bundle_keychain(lua_State *ls)
{
    const char *bundle = NULL;
    const char *name = NULL;
    const char *names[10];
    int ret = 0;
    int i;
    int length = 0;

    bundle = luaL_optstring(ls, 1, NULL);
    if (!bundle) {
        goto finish;
    }

    for (i = 0; i < 10; ++i) {
        name = luaL_optstring(ls, i + 2, NULL);
        if (name) {
            length++;
            names[i] = name;
        } else {
            break;
        }
    }
    
    if (length == 0) {
        goto finish;
    }

    ret = wiiauto_device_keychain_save(bundle, length, names);

finish:
    lua_pushboolean(ls, ret);
    return 1;
}

int wiiauto_lua_load_bundle_keychain(lua_State *ls)
{
    const char *bundle = NULL;
    const char *name = NULL;
    const char *names[10];
    int ret = 0;
    int i;
    int length = 0;

    bundle = luaL_optstring(ls, 1, NULL);
    if (!bundle) {
        goto finish;
    }

    for (i = 0; i < 10; ++i) {
        name = luaL_optstring(ls, i + 2, NULL);
        if (name) {
            length++;
            names[i] = name;
        } else {
            break;
        }
    }
    
    if (length == 0) {
        goto finish;
    }

    ret = wiiauto_device_keychain_load(bundle, length, names);

finish:
    lua_pushboolean(ls, ret);
    return 1;
}


int wiiauto_lua_set_bundle_share(lua_State *ls)
{
    const char *bundle = luaL_optstring(ls, 1, NULL);
    const char *key = luaL_optstring(ls, 2, NULL);
    const char *value = luaL_optstring(ls, 3, NULL);
    int ret = 0;

    ret = wiiauto_device_db_set_share(bundle, key, value);

    lua_pushinteger(ls, ret);

    return 1;
}

int wiiauto_lua_get_bundle_share(lua_State *ls)
{
    const char *bundle = luaL_optstring(ls, 1, NULL);
    const char *key = luaL_optstring(ls, 2, NULL);

    const char *value = NULL;

    value = wiiauto_device_db_get_share(bundle, key);

    if (value) {
        lua_pushstring(ls, value);
        free(value);
    } else {
        lua_pushnil(ls);
    }

    return 1;
}

static void __share_all_callback(lua_State *ls, const char *bundle, const char *key, const char *value)
{
    lua_pushstring(ls, value);
    lua_setfield(ls, -2, key);
}

int wiiauto_lua_get_bundle_share_all(lua_State *ls)
{
    const char *bundle = luaL_optstring(ls, 1, NULL);

    lua_newtable(ls);

    wiiauto_device_db_get_share_all(bundle, ls, __share_all_callback);

    return 1;
}

int wiiauto_lua_set_bundle_keychain_state(lua_State *ls)
{
    const char *bundle = luaL_optstring(ls, 1, NULL);
    const char *state = luaL_optstring(ls, 2, NULL);

    if (!bundle) goto finish;

    wiiauto_device_db_keychain_set_bundle_state(bundle, state);

finish:
    return 0;
}

int wiiauto_lua_get_bundle_keychain_state(lua_State *ls)
{
    const char *bundle = luaL_optstring(ls, 1, NULL);
    char *state = NULL;

    if (!bundle) {
        lua_pushnil(ls);
        goto finish;
    }

    wiiauto_device_db_keychain_get_bundle_state(bundle, &state);
    if (state) {
        lua_pushstring(ls, state);
        free(state);
    } else {
        lua_pushnil(ls);
    }

finish:
    return 1;
}

int wiiauto_lua_add_bundle_key_multi_value(lua_State *ls)
{
    const char *bundle = luaL_optstring(ls, 1, NULL);
    const char *key = luaL_optstring(ls, 2, NULL);
    const char *value = luaL_optstring(ls, 3, NULL);

    if (!bundle || !key || !value) goto finish;

    wiiauto_device_db_multi_add(bundle, key, value);

finish:
    return 0;
}

int wiiauto_lua_delete_bundle_key_multi_value(lua_State *ls)
{
    const char *bundle = luaL_optstring(ls, 1, NULL);
    const char *key = luaL_optstring(ls, 2, NULL);

    if (!bundle || !key) goto finish;

    wiiauto_device_db_multi_delete(bundle, key);

finish:
    return 0;
}

int wiiauto_lua_get_bundle_key_multi_value(lua_State *ls)
{
    const char *bundle = luaL_optstring(ls, 1, NULL);
    const char *key = luaL_optstring(ls, 2, NULL);
    const index = luaL_optinteger(ls, 3, -1);

    if (!bundle || !key || index < 0) {
        lua_pushnil(ls);
        goto finish;
    }

    const char *value = wiiauto_device_db_multi_get(bundle, key, index);
    if (value) {
        lua_pushstring(ls, value);
        free(value);
    } else {
        lua_pushnil(ls);
    }

finish:
    return 1;
}
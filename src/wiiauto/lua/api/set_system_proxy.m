#include "api.h"

// OBJC
#import <Foundation/Foundation.h>

typedef const struct __SCPreferences *SCPreferencesRef;

extern const CFStringRef kSCPrefNetworkServices;
extern const CFStringRef kSCPrefCurrentSet;
extern const CFStringRef kSCEntNetProxies;
extern const CFStringRef kSCPropNetProxiesHTTPEnable;
extern const CFStringRef kSCPropNetProxiesHTTPProxy;
extern const CFStringRef kSCPropNetProxiesHTTPPort;
extern const CFStringRef kSCPropNetProxiesHTTPSEnable;
extern const CFStringRef kSCPropNetProxiesHTTPSProxy;
extern const CFStringRef kSCPropNetProxiesHTTPSPort;
extern const CFStringRef kSCPropNetProxiesSOCKSEnable;
extern const CFStringRef kSCPropNetProxiesSOCKSProxy;
extern const CFStringRef kSCPropNetProxiesSOCKSPort;
extern const CFStringRef kSCPrefSets;
extern const CFStringRef kSCPropUserDefinedName;

extern const CFStringRef kSCCompNetwork;
extern const CFStringRef kSCCompService;


extern SCPreferencesRef SCPreferencesCreate ( CFAllocatorRef allocator, CFStringRef name, CFStringRef prefsID );

extern CFArrayRef SCPreferencesCopyKeyList ( SCPreferencesRef prefs );

extern CFPropertyListRef SCPreferencesGetValue ( SCPreferencesRef prefs, CFStringRef key );

extern Boolean SCPreferencesSetValue ( SCPreferencesRef prefs, CFStringRef key, CFPropertyListRef value );

extern Boolean SCPreferencesLock ( SCPreferencesRef prefs, Boolean wait );

extern Boolean SCPreferencesUnlock ( SCPreferencesRef prefs );

extern Boolean SCPreferencesApplyChanges ( SCPreferencesRef prefs );

extern Boolean SCPreferencesCommitChanges ( SCPreferencesRef prefs );

extern CFDictionaryRef SCPreferencesPathGetValue ( SCPreferencesRef prefs, CFStringRef path );

#define cfs2nss(cfs) ((__bridge NSString *)(cfs))


// AUTO

static void __set_proxy_B(NSString * ipaddr, NSUInteger port, NSMutableDictionary * proxies, int mode)
{
    if (mode == 1) {
   		[proxies setObject:@(1) forKey:cfs2nss(kSCPropNetProxiesHTTPEnable)];
        [proxies setObject:ipaddr forKey:cfs2nss(kSCPropNetProxiesHTTPProxy)];
        [proxies setObject:@(port) forKey:cfs2nss(kSCPropNetProxiesHTTPPort)];
        [proxies setObject:@(1) forKey:cfs2nss(kSCPropNetProxiesHTTPSEnable)];
        [proxies setObject:ipaddr forKey:cfs2nss(kSCPropNetProxiesHTTPSProxy)];
        [proxies setObject:@(port) forKey:cfs2nss(kSCPropNetProxiesHTTPSPort)];

        [proxies setObject:@(0) forKey:cfs2nss(kSCPropNetProxiesSOCKSEnable)];
   } else {
   	    [proxies removeAllObjects];
   }
}

static void __set_proxy_A(NSString * ipaddr, NSUInteger port, int mode)
{
    SCPreferencesRef prefRef = SCPreferencesCreate(NULL, CFSTR("set_proxy"), NULL);

	SCPreferencesLock(prefRef, true);

    CFStringRef currentSetPath = SCPreferencesGetValue(prefRef, kSCPrefCurrentSet);

    NSDictionary *currentSet = (__bridge NSDictionary *)SCPreferencesPathGetValue(prefRef, currentSetPath);
   	if (currentSet) {
   		NSDictionary *currentSetServices = currentSet[cfs2nss(kSCCompNetwork)][cfs2nss(kSCCompService)];

	    NSDictionary *services = (__bridge NSDictionary *)SCPreferencesGetValue(prefRef, kSCPrefNetworkServices);

		NSData *data = [NSPropertyListSerialization dataWithPropertyList:services
	                                             format:NSPropertyListBinaryFormat_v1_0
	                                             options:0
	                                        	   error:nil];
	 	NSMutableDictionary *nservices = [NSPropertyListSerialization propertyListWithData:data
	                                  		   options:NSPropertyListMutableContainersAndLeaves
	                                            format:NULL
	                                  			 error:nil];
	    
	    NSString *wifiServiceKey = nil;
	    for (NSString *key in currentSetServices) {
	   		NSDictionary *service = services[key];
	   		NSString *name = service[cfs2nss(kSCPropUserDefinedName)];
	   		if (service && [@"Wi-Fi" isEqualToString: name]) {
	   			wifiServiceKey = key;
		 	
			    NSMutableDictionary *proxies = nservices[wifiServiceKey][(__bridge NSString *)kSCEntNetProxies];
			    
                __set_proxy_B(ipaddr, port, proxies, mode);
	   		}
	    }

	    SCPreferencesSetValue(prefRef, kSCPrefNetworkServices, (__bridge CFPropertyListRef)nservices);
		SCPreferencesCommitChanges(prefRef);
		SCPreferencesApplyChanges(prefRef);
   	} else {
   		NSLog(@"Does not find set for set key:%@", currentSetPath);
   	}
	SCPreferencesUnlock(prefRef);
	CFRelease(prefRef);
}

int wiiauto_lua_set_system_proxy(lua_State *ls)
{
    const char *host = luaL_optstring(ls, 1, NULL);
    if (!host) {
        @autoreleasepool {
            __set_proxy_A(nil, 0, 0);
        }
        return 0;
    }

    const int port = luaL_optinteger(ls, 2, 0);

    @autoreleasepool {
        __set_proxy_A([NSString stringWithUTF8String: host], port, 1);
    }

    return 0;
}
#include "wiiauto/backboardd/backboardd.h"
#include "wiiauto/springboard/springboard.h"
#include "wiiauto/daemon/daemon.h"
#include "wiiauto/app/app.h"
#include "log/remote_log.h"
#include "wiiauto/event/event_register_app.h"
#include "wiiauto/event/event_alert.h"
#include "wiiauto/event/event_gps_location.h"
#include "wiiauto/event/event_daemon_state.h"
#include "wiiauto/file/file.h"
#include "log/remote_log.h"
#include "wiiauto/common/common.h"
#include "wiiauto/device/device.h"
#include "wiiauto/device/device_db.h"
#import <CoreLocation/CLLocation.h>
#import <CoreLocation/CLLocationManagerDelegate.h>
#import <CoreLocation/CLHeading.h>
#import <AdSupport/ASIdentifierManager.h>
#include "wiiauto/version.h"
#include "cherry/json/json.h"
#import <sys/utsname.h>
#import <StoreKit/StoreKit.h>
#include "cherry/encoding/utf8.h"
#import <WebKit/WebKit.h>
#import <Security/Security.h>
#include <sys/types.h>
#include <sys/sysctl.h>
#include "wiiauto/util/nsdata_compression.h"

@import Metal;
@import MetalKit;

#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>

// @interface NSProcessInfo : NSObject



// @end


@interface CKMediaObject : NSObject

@end

@interface CKMediaObjectManager : NSObject

+(id)sharedInstance;
-(id)mediaObjectWithFileURL:(id)arg1 filename:(id)arg2 transcoderUserInfo:(id)arg3 ;
-(id)transferWithFileURL:(id)arg1 transcoderUserInfo:(id)arg2 attributionInfo:(id)arg3 hideAttachment:(BOOL)arg4 ;
-(id)mediaObjectWithFileURL:(id)arg1 filename:(id)arg2 transcoderUserInfo:(id)arg3 attributionInfo:(id)arg4 hideAttachment:(BOOL)arg5 ;

@end

@interface CKConversationList : NSObject

+(id)sharedConversationList;
-(id)conversationForExistingChatWithGroupID:(id)arg1;
-(id)_conversationForChat:(id)arg1 ;
-(id)conversationForHandles:(id)arg1 displayName:(id)arg2 joinedChatsOnly:(bool)arg3 create:(bool)arg4 ;
-(id)conversations;
-(void)deleteConversations:(id)arg1 ;
-(BOOL)loadingConversations;
-(id)activeConversations;
-(BOOL)loadedConversations;
@end


@interface IMChat : NSObject

-(void)leave;
-(void)leaveiMessageGroup;
-(BOOL)canLeaveChat;
-(void)refreshServiceForSending;
-(void)sendMessage:(id)arg1 ;
-(void)setVIP:(BOOL)arg1 ;

@end

@interface CKConversation : NSObject
-(id)messageWithComposition:(id)arg1 ;
-(void)sendMessage:(id)arg1 newComposition:(BOOL)arg2 ;
-(void)sendMessage:(id)arg1 onService:(id)arg2 newComposition:(BOOL)arg3 ;
-(BOOL)_sms_canSendToRecipients:(id)arg1 alertIfUnable:(BOOL)arg2 ;
-(BOOL)_iMessage_canSendToRecipients:(id)arg1 alertIfUnable:(BOOL)arg2 ;
+(id)conversationForAddresses:(id)arg1 allowRetargeting:(BOOL)arg2 candidateConversation:(id)arg3 ;
+(id)newPendingConversation;
-(void)setRecipients:(NSArray *)arg1 ;
-(IMChat *)chat;
@end

@interface CKComposition : NSObject

+(id)composition;

-(id)initWithText:(id)arg1 subject:(id)arg2 ;
-(id)compositionByAppendingMediaObject:(id)arg1 ;
-(id)compositionByAppendingText:(id)arg1 ;


@end

@interface IMHandle : NSObject

+(id)imHandlesForIMPerson:(id)arg1 ;
-(id)initWithAccount:(id)arg1 ID:(id)arg2 ;

@end

@interface IMPerson : NSObject

-(void)setPhoneNumbers:(NSArray *)arg1 ;

@end

@interface IDSIDQueryController
+ (instancetype)sharedInstance;

-(long long)_currentCachedIDStatusForDestination:(id)arg1 service:(id)arg2 listenerID:(id)arg3 ;
- (NSDictionary *)_currentIDStatusForDestinations:(NSArray *)arg1 service:(NSString *)arg2 listenerID:(NSString *)arg3;

-(long long)_currentIDStatusForDestination:(id)arg1 service:(id)arg2 listenerID:(id)arg3 ;

-(BOOL)_warmupQueryCacheForService:(id)arg1 ;
-(BOOL)_flushQueryCacheForService:(id)arg1 ;
-(BOOL)_hasCacheForService:(id)arg1 ;

-(void)_setCurrentIDStatus:(long long)arg1 forDestination:(id)arg2 service:(id)arg3 ;

-(long long)_refreshIDStatusForDestination:(id)arg1 service:(id)arg2 listenerID:(id)arg3 ;
-(id)_refreshIDStatusForDestinations:(id)arg1 service:(id)arg2 listenerID:(id)arg3 ;
@end

@interface IMServiceImpl : NSObject
+ (instancetype)iMessageService;
@end

@interface IMMessage : NSObject
+ (instancetype)instantMessageWithText:(NSAttributedString*)arg1 flags:(unsigned long long)arg2;
@end

@interface IMAccount : NSObject{
	NSString *_loginID;
    NSString *_displayName;
    NSString *_uniqueID;
    long long _accountType;
    NSString *_strippedLogin;
}
- (IMHandle *)imHandleWithID:(NSString *)arg1 alreadyCanonical:(BOOL)arg2;
@property(copy, nonatomic) NSString *displayName;
@property(readonly, nonatomic) unsigned long long loginStatus;
@property(readonly, nonatomic) unsigned long long capabilities;
- (id)_aliases;
-(BOOL)canSendMessages;
-(void)clearServiceCaches;
-(BOOL)isConnected;
-(BOOL)isManaged;
-(BOOL)isRegistered;
-(unsigned long long)myStatus;
-(void)_invalidateCachedAliases;
-(BOOL)requestNewAuthorizationCredentials;
-(NSString *) get_login_id;
-(NSString *) get_unique_id;

- (long long)validationErrorReasonForAlias:(id)arg1 type:(long long)arg2;
- (long long)validationErrorReasonForAlias:(id)arg1;
- (long long)validationStatusForAlias:(id)arg1 type:(long long)arg2;
- (long long)validationStatusForAlias:(id)arg1;
- (_Bool)validateAlias:(id)arg1 type:(long long)arg2;
- (_Bool)validateAliases:(id)arg1;
- (_Bool)validateAlias:(id)arg1;
- (_Bool)unvalidateAliases:(id)arg1;
- (_Bool)unvalidateAlias:(id)arg1;
- (long long)typeForAlias:(id)arg1;
- (_Bool)removeAlias:(id)arg1 type:(long long)arg2;
- (_Bool)removeAliases:(id)arg1;
- (_Bool)removeAlias:(id)arg1;
- (_Bool)addAlias:(id)arg1 type:(long long)arg2;
- (_Bool)addAliases:(id)arg1;
- (_Bool)addAlias:(id)arg1;
- (id)aliasesForType:(long long)arg1;
- (_Bool)hasAlias:(id)arg1 type:(long long)arg2;
- (_Bool)hasAlias:(id)arg1;

- (void)forgetAllWatches;
- (void)disconnectAllIMHandles;
@end

@interface IMAccountController : NSObject
+ (instancetype)sharedInstance;
- (IMAccount *)__ck_defaultAccountForService:(IMServiceImpl *)arg1;
-(NSArray *)accounts;
-(NSArray *)activeAccounts;
-(NSArray *)operationalAccounts;
-(NSArray *)connectedAccounts;
@end

@interface IMChatRegistry : NSObject
+ (instancetype)sharedInstance;
- (IMChat *)chatForIMHandle:(IMHandle *)arg1;
@end












static int os_greater_than_12 = 1;

static void __tweak_replace_data(NSData *d, const unsigned char *ptr, const size_t size)
{
    if (!d) return;

    unsigned char *p = (unsigned char *) [d bytes];
    if ([d length] > 0) {
        for (int i = 0; i < size; ++i) {
            p[i] = ptr[i];
        }		
    }
}

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)


#include <sys/time.h>
#import <objc/runtime.h>

#import <substrate.h>
extern CFPropertyListRef MGCopyAnswer(CFStringRef);
extern CFPropertyListRef MGCopyMultipleAnswers(CFArrayRef questions, int __unknown0);
extern int MGSetAnswer(CFStringRef question, CFTypeRef answer);
extern CFPropertyListRef MGCopyAnswerWithError(CFStringRef question, int *error, ...);

@interface SBApplication : NSObject
-(NSString *)bundleIdentifier;
@end

@interface SBApplicationIcon : NSObject
- (NSString *)applicationBundleID;
@end

static u64 __current_timestamp() 
{
    struct timeval te; 
    gettimeofday(&te, NULL);
    u64 milliseconds = te.tv_sec*1000LL + te.tv_usec/1000;
    return milliseconds;
}

static u8 __springboard_inited__ = 0;
static u8 __backboardd_inited__ = 0;
static u8 __app_inited__ = 0;

#include <ifaddrs.h>
#include <arpa/inet.h>

static NSString *getIPAddress() {

    NSString *address = @"";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;

    success = getifaddrs(&interfaces);
    if (success == 0) {

        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) 
			{
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) 
				{
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }

            }

            temp_addr = temp_addr->ifa_next;
        }
    }

    freeifaddrs(interfaces);
    return address;
} 

@interface LogWindow: UIWindow
{
	UITextView *textView;
	UIView *anim;
	CAGradientLayer *anim_layer;
	NSString *head;
	NSString *content;
	float percentage;
	int fade;
	int end;
	float alpha;
	float gradient_alpha_from;
	float graidnet_alpha_to;
	UIColor *gradient_from;
	UIColor *gradient_to;
}

-(void)setStatus:(NSString *)str;
@end

@implementation LogWindow {
	 dispatch_queue_t _running_queue;
}

-(id)init{
	self = [super initWithFrame:[UIScreen mainScreen].bounds];
	if(self)
	{
		head = getIPAddress();
		content = @"";

		_running_queue = dispatch_queue_create("wiiauto_status_bar", 0);

		/* background */
		self.backgroundColor = [UIColor clearColor];
		self.windowLevel = UIWindowLevelStatusBar + 10000;
		self.hidden = NO;

		/*
		 * background
		 */
		UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 20)];
		view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.85];
		[self addSubview:view];

		/* animation */
		percentage = 0;
		fade = 0;
		end = 0;
		alpha = 1;
		gradient_alpha_from = 1;
		graidnet_alpha_to = 1;
		gradient_from = [UIColor redColor];
		gradient_to = [UIColor redColor];
		anim = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 20)];
		anim_layer = [CAGradientLayer layer];

		anim_layer.frame = CGRectMake(0, 0, 0, 20);
		anim_layer.startPoint = CGPointMake(0, 0.5);
   		anim_layer.endPoint = CGPointMake(1, 0.5);
		anim_layer.colors = @[(id)[gradient_from colorWithAlphaComponent:gradient_alpha_from].CGColor, (id)[gradient_to colorWithAlphaComponent:graidnet_alpha_to].CGColor];

		[anim.layer insertSublayer:anim_layer atIndex:0];
		[self addSubview:anim];

		/* text view */
		textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 20)];		
		textView.textAlignment = NSTextAlignmentLeft;

		textView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.0];
		textView.textColor = [UIColor whiteColor];
		textView.contentSize = textView.bounds.size;
		textView.clipsToBounds = YES;
		textView.contentInset = UIEdgeInsetsZero;
		textView.textContainer.lineFragmentPadding = 0;
		textView.textContainerInset = UIEdgeInsetsMake(2.0f, 2.0f, 2.0f, 2.0f);

		if (head.length == 0) {
			textView.text = [NSString stringWithFormat:@"%s: %@", __wiiauto_version__, content];
		} else {
			textView.text = [NSString stringWithFormat:@"%s@%@: %@", __wiiauto_version__, head, content];
		}	
		textView.font = [UIFont boldSystemFontOfSize:12];
		textView.scrollEnabled = false;

		[self addSubview:textView];
		[self setUserInteractionEnabled:NO];

		[self check_ip];
		[self refresh_animation];

		self.hidden = YES;
	}
	return self;
}

- (void) refresh_animation
{
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (1.0f / 60) * NSEC_PER_SEC), dispatch_get_main_queue() , ^{

		@try {
			percentage += (2.0 - percentage) * (1.0f / 60) * 3;

			if (!end) {
				anim_layer.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width * MIN(1.0f, percentage), 20);
			}		

			if (percentage > 1 && alpha > 0) {
				alpha += (0 - alpha) * (1.0f / 60) * 12;
				if (alpha < 0.001) {
					alpha = 0;
				}
				anim_layer.colors = @[(id)[gradient_from colorWithAlphaComponent:gradient_alpha_from * alpha].CGColor, (id)[gradient_to colorWithAlphaComponent:graidnet_alpha_to * alpha].CGColor];		
			}

			if (percentage > 1 && !end && alpha == 0) {
				end = 1;
				alpha = 1;
				[CATransaction begin];
				[CATransaction setDisableActions:YES];
				anim_layer.frame = CGRectMake(0, 0, 0, 20);
				anim_layer.colors = @[(id)[gradient_from colorWithAlphaComponent:gradient_alpha_from].CGColor, (id)[gradient_to colorWithAlphaComponent:graidnet_alpha_to].CGColor];
				[CATransaction commit];		
			} else if (end) {
				percentage = 0;
				fade = 0;
				end = 0;
				alpha = 1;
			}
		} @catch (NSException *e) {
			percentage = 0;
			fade = 0;
			end = 0;
			alpha = 1;
		}


		[self refresh_animation];

	});
}

-(void)check_ip
{
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC), _running_queue , ^{

		NSString *s = getIPAddress();
		if (s && ![s isEqualToString:head]) {
			head = s;

			dispatch_async(dispatch_get_main_queue() , ^{
				if (head.length == 0) {
					textView.text = [NSString stringWithFormat:@"%s: %@", __wiiauto_version__, content];
				} else {
					textView.text = [NSString stringWithFormat:@"%s@%@: %@", __wiiauto_version__, head, content];
				}	
			});
			
		}

		[self check_ip];

	});
}

-(void)setStatus:(NSString *)str
{
	content = str;

	if (head.length == 0) {
		textView.text = [NSString stringWithFormat:@"%s: %@", __wiiauto_version__, content];
	} else {
		textView.text = [NSString stringWithFormat:@"%s@%@: %@", __wiiauto_version__, head, content];
	}	
}

@end

static LogWindow *logWindow = nil;

static void springboard_set_status_bar(const char *ptr)
{
	if (!ptr) return;

	NSString *str;

	@try {
		str = [NSString stringWithUTF8String:ptr];
	} @catch (NSException *e) {
		str = nil;
	}	 

	if (!str) return;

	dispatch_async(dispatch_get_main_queue() , ^{
		
		@try {
			if (logWindow) {

				[logWindow setStatus:str];
			}
		} @catch (NSException *e) {}

	});

}

static void springboard_set_status_bar_state(const u8 visible)
{
	@try {
		if (logWindow) {

			[logWindow setHidden:!visible];
		}
	} @catch (NSException *e) {}
}

/*
 * SPRINGBOARD EVENT SENDER
 */
CFDataRef springboard_callback(CFMessagePortRef local, SInt32 msgid, CFDataRef cfData, void *info);

static int __is_in_springboard()
{
	NSString *idr;

	@try {
		idr = [[NSBundle mainBundle] bundleIdentifier];
	} @catch (NSException *e) {
		idr = nil;
	}

	if (idr && [idr isEqualToString:@"com.apple.springboard"]) {
		return 1;
	} else {
		return 0;
	}
}

static u16 __sport[9] = {
	SPRINGBOARD_LOCAL_PORT_1,
	SPRINGBOARD_LOCAL_PORT_2,
	SPRINGBOARD_LOCAL_PORT_3,
	SPRINGBOARD_LOCAL_PORT_4,
	SPRINGBOARD_LOCAL_PORT_5,
	SPRINGBOARD_LOCAL_PORT_6,
	SPRINGBOARD_LOCAL_PORT_7,
	SPRINGBOARD_LOCAL_PORT_8,
	SPRINGBOARD_LOCAL_PORT_9
};

static void __springboard_send_event(const int msgid, const void *ptr, const u32 len, CFDataRef *ret)
{
	NSString *idr;

	@try {
		idr = [[NSBundle mainBundle] bundleIdentifier];
	} @catch (NSException *e) {
		idr = nil;
	}

	if (idr && [idr isEqualToString:@"com.apple.springboard"]) {
			
		CFDataRef src = CFDataCreate(NULL, (const UInt8 *)ptr, len);
		*ret = springboard_callback(NULL, msgid, src, NULL);
		
		CFRelease(src);
        
	} else {
		// wiiauto_send_event(msgid, ptr, len, SPRINGBOARD_MACH_PORT_NAME, ret);
		wiiauto_send_event_local_port(msgid, ptr, len, 9, __sport, ret);
	}
}

static void __springboard_send_event_uncheck_return(const int msgid, const void *ptr, const u32 len)
{
	NSString *idr;

	@try {
		idr = [[NSBundle mainBundle] bundleIdentifier];
	} @catch (NSException *e) {
		idr = nil;
	}

	if (idr && [idr isEqualToString:@"com.apple.springboard"]) {
				
		CFDataRef src = CFDataCreate(NULL, (const UInt8 *)ptr, len);
		CFDataRef ret = springboard_callback(NULL, msgid, src, NULL);
		
		CFRelease(src);
		if (ret) CFRelease(ret);
        
	} else {
		// wiiauto_send_event_uncheck_return(msgid, ptr, len, SPRINGBOARD_MACH_PORT_NAME);
		wiiauto_send_event_local_port_uncheck_return(msgid, ptr, len,  9, __sport);
	}
}

static double __latitude__ = 0;
static double __longitude__ = 0;
static int __replace__ = 0;
static bool managerInitialized;
static u64 __coord_timestamp__ = 0;


// typedef struct CLHeadingInternalStruct {
//     double x;
//     double y;
//     double z;
//     double magneticHeading;
//     double trueHeading;
//     double accuracy;
//     double timestamp;
//     double temperature;
//     double magnitude;
//     double inclination;
//     int calibration;
// } CLHeadingInternalStruct;

// @interface CLHeading(Private)

// - (id)initWithClientHeading:(CLHeadingInternalStruct)arg1;

// @end

// @interface WiiAutoRLCManager : NSObject {
//     NSMutableArray *_managers;
//     NSTimer *_timer;
// }

// +(instancetype)sharedInstance;
// -(id)init;
// -(void)update;
// -(void)updateManager:(CLLocationManager*)manager;
// -(void)addManager:(CLLocationManager*)manager;
// -(void)removeManager:(CLLocationManager*)manager;

// +(CLLocation *)getOverridenLocation:(CLLocation *)location;
// +(CLLocation *)getFabricatedLocation;
// +(CLHeading *)getFabricatedHeading;

// @end

// @implementation WiiAutoRLCManager

// +(instancetype)sharedInstance {
//     static WiiAutoRLCManager *sharedInstance = nil;
//     static dispatch_once_t onceToken;
//     dispatch_once(&onceToken, ^{
//         sharedInstance = [WiiAutoRLCManager alloc];
//         managerInitialized = YES;
//     });
//     return sharedInstance;
// }

// +(CLLocation *)getOverridenLocation:(CLLocation *)location {
//     double altitude = location.altitude;
    
// 	CLLocationCoordinate2D coordinate;
// 	f64 lat, lng;
// 	u8 ovr;

// 	common_get_gps_location(&lat, &lng, &ovr);
// 	if (ovr && (lat > 0 || lng > 0)) {
// 		__latitude__ = lat;
// 		__longitude__ = lng;
// 		__replace__ = 1;
// 		coordinate = CLLocationCoordinate2DMake(__latitude__, __longitude__);
// 	} else {
// 		coordinate = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude);
// 	}

//     return [[CLLocation alloc] initWithCoordinate:coordinate
//         altitude:altitude
//         horizontalAccuracy:location.horizontalAccuracy
//         verticalAccuracy:location.verticalAccuracy
//         course:location.course
//         speed:0
//         timestamp:location.timestamp
//     ];
// }

// +(CLLocation *)getFabricatedLocation {
//     double altitude = 420;
    
// 	CLLocationCoordinate2D coordinate;
// 	coordinate = CLLocationCoordinate2DMake(__latitude__, __longitude__);

//     return [[CLLocation alloc]
//         initWithCoordinate:coordinate
//         altitude:altitude
//         horizontalAccuracy:10
//         verticalAccuracy:10
//         course:1
//         speed:0
//         timestamp:[NSDate date]
//     ];
// }

// +(CLHeading *)getFabricatedHeading {
//     CLHeadingInternalStruct internal;
//     internal.x = 1;
//     internal.y = 1;
//     internal.z = 1;
//     internal.magneticHeading = 1;
//     internal.trueHeading = 1;
//     internal.accuracy = 20;
//     internal.timestamp = [[NSDate date] timeIntervalSinceReferenceDate];
//     internal.temperature = 0;
//     internal.magnitude = 0;
//     internal.inclination = 0;
//     internal.calibration = 5;
//     return [[CLHeading alloc] initWithClientHeading:internal];
// }

// -(id)init {
//     return [WiiAutoRLCManager sharedInstance];
// }

// -(void)update {
//     if (!_managers || [_managers count] == 0) return;

//     for (id manager in [[_managers copy] reverseObjectEnumerator]) {
//         [self updateManager:manager];
//     }
// }

// -(void)updateManager:(CLLocationManager*)manager {
//     if (!manager) return;
//     if ([[manager delegate] respondsToSelector:@selector(locationManager:didUpdateLocations:)]) {
//         [[manager delegate] locationManager:manager didUpdateLocations:@[
//             [WiiAutoRLCManager getFabricatedLocation]
//         ]];
//     }

//     if ([[manager delegate] respondsToSelector:@selector(locationManager:didUpdateToLocation:fromLocation:)]) {
//         [[manager delegate] locationManager:manager didUpdateToLocation:[WiiAutoRLCManager getFabricatedLocation] fromLocation:[WiiAutoRLCManager getFabricatedLocation]];
//     }

//     if ([[manager delegate] respondsToSelector:@selector(locationManager:didUpdateHeading:)]) {
//         [[manager delegate] locationManager:manager didUpdateHeading:[WiiAutoRLCManager getFabricatedHeading]];
//     }
// }

// -(void)addManager:(CLLocationManager*)manager {
//     if (!manager) return;
//     if (!_managers) _managers = [NSMutableArray new];
//     if (![_managers containsObject:manager]) [_managers addObject:manager];

//     if (!_timer) {
//         _timer = [NSTimer scheduledTimerWithTimeInterval:8 target:self selector:@selector(update) userInfo:nil repeats:YES];
//     }
// }

// -(void)removeManager:(CLLocationManager*)manager {
//     if (!_managers || !manager) return;
//     [_managers removeObject:manager];
// }

// @end






/*
 * LOCATION
 */
@interface WiiAutoLocationManagerDelegate : NSObject <CLLocationManagerDelegate>

@property (nonatomic, retain) id<CLLocationManagerDelegate> delegate;
@property (nonatomic, retain) id manager;

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations;
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error;
- (void)locationManager:(CLLocationManager *)manager didFinishDeferredUpdatesWithError:(NSError *)error;
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation;
- (void)locationManagerDidPauseLocationUpdates:(CLLocationManager *)manager;
- (void)locationManagerDidResumeLocationUpdates:(CLLocationManager *)manager;
- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading;
- (BOOL)locationManagerShouldDisplayHeadingCalibration:(CLLocationManager *)manager;
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status;

@end

@implementation WiiAutoLocationManagerDelegate

static char __wiiauto_is_override_location()
{
	u8 enable = 1;
	common_is_gps_overrided(&enable);
	return enable;
}

static CLLocation *__wiiauto_location(CLLocation *o)
{
	CLLocation *loc = o;

	double altitude = loc.altitude;
	CLLocationCoordinate2D coordinate;
	f64 lat, lng;
	u8 ovr;

	u64 cm = __current_timestamp();
	if (cm - __coord_timestamp__ >= 1000) {
		__coord_timestamp__ = cm;

		common_get_gps_location(&lat, &lng, &ovr);
		if (ovr && (lat > 0 || lng > 0)) {
			__latitude__ = lat;
			__longitude__ = lng;
			__replace__ = 1;
			coordinate = CLLocationCoordinate2DMake(__latitude__, __longitude__);
		} else {
			coordinate = CLLocationCoordinate2DMake(loc.coordinate.latitude, loc.coordinate.longitude);
		}
	} else {
		coordinate = CLLocationCoordinate2DMake(__latitude__, __longitude__);
	}

    return [[CLLocation alloc] initWithCoordinate:coordinate
        altitude:altitude
        horizontalAccuracy:loc.horizontalAccuracy
        verticalAccuracy:loc.verticalAccuracy
        course:loc.course
        speed:0
        timestamp:loc.timestamp
    ];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations 
{
	char enable = __wiiauto_is_override_location();

    if ([self.delegate respondsToSelector:@selector(locationManager:didUpdateLocations:)]) {
		if (enable) {
			NSMutableArray *betterLocations = [NSMutableArray new];
			for (CLLocation *location in locations) {
				[betterLocations addObject:__wiiauto_location(location)];
			}
			[self.delegate locationManager:manager didUpdateLocations:[[NSArray alloc] initWithArray:betterLocations]];
		} else {
			[self.delegate locationManager:manager didUpdateLocations:locations];
		}        
    }

    if ([self.delegate respondsToSelector:@selector(locationManager:didUpdateToLocation:fromLocation:)] && [locations count] > 0) {
		if (enable) {
        	[self.delegate locationManager:manager didUpdateToLocation:__wiiauto_location(locations[[locations count] - 1]) fromLocation:__wiiauto_location(locations[0])];
		} else {
            [self.delegate locationManager:manager didUpdateToLocation:locations[[locations count] - 1] fromLocation:locations[0]];
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    if ([self.delegate respondsToSelector:@selector(locationManager:didFailWithError:)]) [self.delegate locationManager:manager didFailWithError:error];
}

- (void)locationManager:(CLLocationManager *)manager didFinishDeferredUpdatesWithError:(NSError *)error {
    if ([self.delegate respondsToSelector:@selector(locationManager:didFinishDeferredUpdatesWithError:)]) [self.delegate locationManager:manager didFinishDeferredUpdatesWithError:error];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    if (![self.delegate respondsToSelector:@selector(locationManager:didUpdateToLocation:fromLocation:)]) return;

	char enable = __wiiauto_is_override_location();
	if (enable) {
		[self.delegate locationManager:manager didUpdateToLocation:__wiiauto_location(newLocation) fromLocation:__wiiauto_location(oldLocation)];
	} else {
		[self.delegate locationManager:manager didUpdateToLocation:newLocation fromLocation:oldLocation];
	}    
}

- (void)locationManagerDidPauseLocationUpdates:(CLLocationManager *)manager {
    if ([self.delegate respondsToSelector:@selector(locationManagerDidPauseLocationUpdates:)]) [self.delegate locationManagerDidPauseLocationUpdates:manager];
}

- (void)locationManagerDidResumeLocationUpdates:(CLLocationManager *)manager {
    if ([self.delegate respondsToSelector:@selector(locationManagerDidResumeLocationUpdates:)]) [self.delegate locationManagerDidResumeLocationUpdates:manager];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
    if ([self.delegate respondsToSelector:@selector(locationManager:didUpdateHeading:)]) [self.delegate locationManager:manager didUpdateHeading:newHeading];
}

- (BOOL)locationManagerShouldDisplayHeadingCalibration:(CLLocationManager *)manager {
    if ([self.delegate respondsToSelector:@selector(locationManagerShouldDisplayHeadingCalibration:)]) return [self.delegate locationManagerShouldDisplayHeadingCalibration:manager];
    return NO;
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if ([self.delegate respondsToSelector:@selector(locationManager:didChangeAuthorizationStatus:)]) {
        [self.delegate locationManager:manager didChangeAuthorizationStatus:status];
    }
}

- (void)locationManager:(CLLocationManager *)manager didVisit:(CLVisit *)visit {
	char enabled = __wiiauto_is_override_location();
    if (!enabled && [self.delegate respondsToSelector:@selector(locationManager:didVisit:)]) {
        [self.delegate locationManager:manager didVisit:visit];
    }
}

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region {
	char enabled = __wiiauto_is_override_location();
    if (!enabled && [self.delegate respondsToSelector:@selector(locationManager:didRangeBeacons:inRegion:)]) {
        [self.delegate locationManager:manager didRangeBeacons:beacons inRegion:region];
    }
}

- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region {
	char enabled = __wiiauto_is_override_location();
    if (!enabled && [self.delegate respondsToSelector:@selector(locationManager:didStartMonitoringForRegion:)]) {
        [self.delegate locationManager:manager didStartMonitoringForRegion:region];
    }
}

- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region {
	char enabled = __wiiauto_is_override_location();
    if (!enabled && [self.delegate respondsToSelector:@selector(locationManager:didDetermineState:forRegion:)]) {
        [self.delegate locationManager:manager didDetermineState:state forRegion:region];
    }
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
	char enabled = __wiiauto_is_override_location();
    if (!enabled && [self.delegate respondsToSelector:@selector(locationManager:didEnterRegion:)]) {
        [self.delegate locationManager:manager didEnterRegion:region];
    }
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
	char enabled = __wiiauto_is_override_location();
    if (!enabled && [self.delegate respondsToSelector:@selector(locationManager:didExitRegion:)]) {
        [self.delegate locationManager:manager didExitRegion:region];
    }
}

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error {
	char enabled = __wiiauto_is_override_location();
    if (!enabled && [self.delegate respondsToSelector:@selector(locationManager:monitoringDidFailForRegion:withError:)]) {
        [self.delegate locationManager:manager monitoringDidFailForRegion:region withError:error];
    }
}

- (void)locationManager:(CLLocationManager *)manager rangingBeaconsDidFailForRegion:(CLBeaconRegion *)region withError:(NSError *)error {
	char enabled = __wiiauto_is_override_location();
    if (!enabled && [self.delegate respondsToSelector:@selector(locationManager:rangingBeaconsDidFailForRegion:withError:)]) {
        [self.delegate locationManager:manager rangingBeaconsDidFailForRegion:region withError:error];
    }
}

- (void)dealloc {
}

@end

@interface CLLocationManager(WiiAuto)
@property (nonatomic, retain) WiiAutoLocationManagerDelegate* wiiDelegate;
@end

@interface UIAlertController(WiiAuto)
@property (nonatomic, assign) int wiiauto_visible;
@end

@interface UITextField(WiiAuto)
@property (nonatomic, assign) u64 wiiauto_delay;
@end

@interface UILabel(WiiAuto)
@property (nonatomic, assign) int wiiauto_label_registered;
@end

@interface NSLocale(WiiAuto)
@property (nonatomic, assign) u8 wiiauto_current;
@end

@interface __NSCFLocale : NSLocale
@end

%group WiiAuto

/*
 * UIVIEWCONTROLLER
 */
%hook UIViewController

static void __send_orientation(UIViewController *s, const float delay)
{
	if (s && [s isKindOfClass:[UIAlertController class]]) {
		return;
	}
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) , ^{

		switch([[UIApplication sharedApplication] applicationState]) {
        	case UIApplicationStateActive:
				@try {
					UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;

					if(orientation == 0) {
						CFNotificationCenterPostNotification(
							CFNotificationCenterGetDarwinNotifyCenter(), 
							CFSTR("WIIAUTO_APP_ORIENTATION_PORTRAIT"), 
							NULL, 
							NULL, 
							TRUE);
					} else if(orientation == UIInterfaceOrientationPortrait) {
						CFNotificationCenterPostNotification(
							CFNotificationCenterGetDarwinNotifyCenter(), 
							CFSTR("WIIAUTO_APP_ORIENTATION_PORTRAIT"), 
							NULL, 
							NULL, 
							TRUE);
					} else if(orientation == UIInterfaceOrientationPortraitUpsideDown) {
						CFNotificationCenterPostNotification(
							CFNotificationCenterGetDarwinNotifyCenter(), 
							CFSTR("WIIAUTO_APP_ORIENTATION_PORTRAIT_UPSIDE_DOWN"), 
							NULL, 
							NULL, 
							TRUE);
					} else if(orientation == UIInterfaceOrientationLandscapeLeft) {
						CFNotificationCenterPostNotification(
							CFNotificationCenterGetDarwinNotifyCenter(), 
							CFSTR("WIIAUTO_APP_ORIENTATION_LANDSCAPE_LEFT"), 
							NULL, 
							NULL, 
							TRUE);
					} else if(orientation == UIInterfaceOrientationLandscapeRight) {
						CFNotificationCenterPostNotification(
							CFNotificationCenterGetDarwinNotifyCenter(), 
							CFSTR("WIIAUTO_APP_ORIENTATION_LANDSCAPE_RIGHT"), 
							NULL, 
							NULL, 
							TRUE);
					}
				} @catch (NSException *e) {

				}
				break;
			default:
				break;
		}

	});
}

-(void)willTransitionToTraitCollection:(UITraitCollection *)newCollection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
	@try {

		for (float i = 0; i < 3; i += 0.5) {
			__send_orientation(self, i);	
		}

	} @catch (NSException *e) {

	}

	%orig;
}

- (void) viewDidAppear:(BOOL)animated
{
	@try {

		for (float i = 0; i < 3; i += 0.5) {
			__send_orientation(self, i);	
		}		
	} @catch (NSException *e) {

	}

	%orig;
}

-(UIInterfaceOrientationMask) supportedInterfaceOrientations
{
	@try {

		for (float i = 0; i < 3; i += 0.5) {
			__send_orientation(self, i);	
		}

	} @catch (NSException *e) {

	}

	return %orig;
}

%end

/*
 * ALERT
 */
%hook UIAlertController

%property (nonatomic, assign) int wiiauto_visible;

- (void)viewWillDisappear:(BOOL)animated
{	
	self.wiiauto_visible = 0;
	%orig;
}

static UIView *__search(const char *name, UIView *root)
{
	@try {
		if (root && [root class] == [UIButton class]) {
			UIButton *b = (UIButton *)root;
			const char *s = NULL;
			if (b && b.titleLabel && b.titleLabel.text) {
				s = [b.titleLabel.text UTF8String];
			}
			if (s && strcmp(name, s) == 0) {
				return root;
			}
			b = nil;
		}
		if (root && [root class] == [UILabel class]) {
			UILabel *b = (UILabel *)root;
			const char *s = NULL;
			if (b && b.text) {
				s = [b.text UTF8String];
			}
			if (s && strcmp(name, s) == 0) {
				return root;
			}
			b = nil;
		}
	} @catch (NSException *e) {

	}

	@try {
		for (UIView *v in root.subviews) {
			UIView *ret = __search(name, v);
			if (ret) return ret;
			ret = nil;
		}
	} @catch (NSException *e) {

	}

	return nil;
}

static void __do_send_text(UIView *view, const char *text, const json_element labels)
{
	__wiiauto_event_alert_on_add_label evt;
	__wiiauto_event_alert_on_add_label_init(&evt);

	evt.priority = __is_in_springboard() ? 0 : 1;

	u32 len = sizeof(evt.title) - 1;

	strncpy(evt.title, text, len - 1);
	evt.title[len - 1] = '\0';

	CGRect frame = [view convertRect:view.bounds toView:nil];
	evt.x = frame.origin.x + frame.size.width * 0.5f;
	evt.y = frame.origin.y + frame.size.height * 0.5f;
	evt.x *= [UIScreen mainScreen].scale;
	evt.y *= [UIScreen mainScreen].scale;

	__springboard_send_event_uncheck_return(1, &evt, sizeof(evt));
}

static void __send_text(UIView *root, const json_element labels)
{
	@try {
		if (root && [root isKindOfClass:[UIButton class]]) {
			UIButton *b = (UIButton *)root;
			const char *s = NULL;
			if (b && b.titleLabel && b.titleLabel.text) {
				s = [b.titleLabel.text UTF8String];
			}
			if (s) {
				__do_send_text(b.titleLabel, s, labels);
			}

			b = nil;
		}
		if (root && [root isKindOfClass:[UILabel class]]) {
			UILabel *b = (UILabel *)root;
			const char *s = NULL;
			if (b && b.text) {
				s = [b.text UTF8String];
			}
			if (s) {
				__do_send_text(b, s, labels);
			}
			b = nil;
		}
		if (root && [root isKindOfClass:[UITextField class]]) {
			UITextField *b = (UITextField *)root;
			const char *s = NULL;
			if (b && b.text) {
				s = [b.text UTF8String];
			}
			if (s) {
				__do_send_text(b, s, labels);
			}
			b = nil;
		}
	} @catch (NSException *e) {

	}

	@try {
		for (UIView *v in root.subviews) {
			__send_text(v, labels);
		}
	} @catch (NSException *e) {

	}
}

static void __send_alert_content(UIAlertController *self)
{
	{
		__wiiauto_event_alert_begin_commit evt;
		__wiiauto_event_alert_begin_commit_init(&evt);
		evt.priority = __is_in_springboard() ? 0 : 1;

		__springboard_send_event_uncheck_return(1, &evt, sizeof(evt));
	}

	@try {
		NSString *title = [self title];
		if (title) {
			__wiiauto_event_alert_on_add_title evt;

			__wiiauto_event_alert_on_add_title_init(&evt);
			evt.priority = __is_in_springboard() ? 0 : 1;

			u32 len = sizeof(evt.title) - 1;
			strncpy(evt.title, [title UTF8String], len - 1);
			evt.title[len - 1] = '\0';
			__springboard_send_event_uncheck_return(1, &evt, sizeof(evt));
		}
		title = nil;
	} @catch (NSException *e) {

	}

	@try {
		__send_text(self.view, (json_element){id_null});
	} @catch (NSException *e) {

	}

	@try {
		NSArray<UIAlertAction *> *actions = [self actions];
		for (UIAlertAction *a in actions) {
			NSString *a_title = a.title;

			__wiiauto_event_alert_on_add_action evt;
			__wiiauto_event_alert_on_add_action_init(&evt);

			evt.priority = __is_in_springboard() ? 0 : 1;

			if (a_title) {
				u32 len = sizeof(evt.title) - 1;
				strncpy(evt.title, [a_title UTF8String], len - 1);
				evt.title[len - 1] = '\0';
			}
			evt.x = 0;
			evt.y = 0;

			UIView *v = __search(evt.title, self.view);
			if (v) {
				CGRect frame = [v convertRect:v.bounds toView:nil];
				evt.x = frame.origin.x + frame.size.width * 0.5f;
				evt.y = frame.origin.y + frame.size.height * 0.5f;
				evt.x *= [UIScreen mainScreen].scale;
				evt.y *= [UIScreen mainScreen].scale;
			}

			__springboard_send_event_uncheck_return(1, &evt, sizeof(evt));

			v = nil;
			a_title = nil;
		}
		actions = nil;
	} @catch (NSException *e) {

	}

	{
		__wiiauto_event_alert_end_commit evt;
		__wiiauto_event_alert_end_commit_init(&evt);
		evt.priority = __is_in_springboard() ? 0 : 1;

		__springboard_send_event_uncheck_return(1, &evt, sizeof(evt));
	}
}

static void __schedule_send_alert_content(UIAlertController *self)
{
	__weak __typeof(self) selfWeak = self;    

	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.2 * NSEC_PER_SEC), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

		__strong __typeof(selfWeak) selfStrong = selfWeak;
		if (selfStrong) {
			__send_alert_content(selfStrong);

			if (selfStrong.wiiauto_visible) {
				__schedule_send_alert_content(selfStrong);
			}
		}		

	});
}

- (void) viewDidAppear:(BOOL)animated
{
	self.wiiauto_visible = 1;
	__schedule_send_alert_content(self);

	NSString *bundle = nil;
	@try {
		bundle = [NSBundle mainBundle].bundleIdentifier;
	} @catch (NSException *e) {
		bundle = nil;
	}	

	%orig;
}
%end

static NSString* __localeKey()
{
    NSArray* lang = [[NSUserDefaults standardUserDefaults]objectForKey:@"AppleLanguages"];
    NSString* currentLang = lang[0];
    return currentLang;
}


static  NSString *__langFromLocale(NSString *locale) 
{
    NSRange r = [locale rangeOfString:@"_"];
    if (r.length == 0) r.location = locale.length;
    NSRange r2 = [locale rangeOfString:@"-"];
    if (r2.length == 0) r2.location = locale.length;
    return [[locale substringToIndex:MIN(r.location, r2.location)] lowercaseString];
}

%hook UITextView

- (UITextInputMode *) textInputMode {
    @try {
		for (UITextInputMode *inputMode in [UITextInputMode activeInputModes])
		{
			if ([__langFromLocale(__localeKey()) isEqualToString:__langFromLocale(inputMode.primaryLanguage)])
				return inputMode;
		}
	} @catch (NSException *e) {}
    return %orig;
}

%end

/*
 * TEXT FIELD
 */
%hook UITextField

- (UITextInputMode *) textInputMode {
	@try {
		for (UITextInputMode *inputMode in [UITextInputMode activeInputModes])
		{
			if ([__langFromLocale(__localeKey()) isEqualToString:__langFromLocale(inputMode.primaryLanguage)])
				return inputMode;
		}
	} @catch (NSException *e) {}
    
    return %orig;
}

// %property (nonatomic, assign) u64 wiiauto_delay;

// - (BOOL)canPerformAction:(SEL)action withSender:(id)sender
// {
// 	int pasted = 0;
// 	BOOL ret = NO;

// 	// @synchronized(self) {
// 		if (action == @selector(paste:)) {
// 			// u64 cm = __current_timestamp();
// 			// if (cm - self.wiiauto_delay >= 400) {
// 			// 	self.wiiauto_delay = cm;
// 			// 	pasted = 1;
// 			// 	ret = YES;
// 			// } else {
// 			// 	pasted = 1;
// 			// }   
// 			ret = YES;
// 			pasted = 1;     
// 		}
// 	// }
// 	if (pasted) {
// 		return ret;
// 	}

//     return %orig;
// }

// -(void)drawTextInRect:(CGRect)rect
// {
// 	if (self.smartInsertDeleteType != UITextSmartInsertDeleteTypeNo) {
// 		self.smartInsertDeleteType = UITextSmartInsertDeleteTypeNo;
// 	}
// 	%orig;
// }

// -(void)drawPlaceholderInRect:(CGRect)rect
// {
// 	if (self.smartInsertDeleteType != UITextSmartInsertDeleteTypeNo) {
// 		self.smartInsertDeleteType = UITextSmartInsertDeleteTypeNo;
// 	}
// 	%orig;
// }

%end

%hook CLLocationManager

%property (nonatomic, retain) WiiAutoLocationManagerDelegate* wiiDelegate;

-(void)setDelegate:(id)delegate {
    if (!self.wiiDelegate) {
        self.wiiDelegate = [[WiiAutoLocationManagerDelegate alloc] init];
    }

    self.wiiDelegate.manager = self;
    self.wiiDelegate.delegate = delegate;

    %orig(self.wiiDelegate);
}

-(id)delegate {
    return self.wiiDelegate.delegate;
}

-(CLLocation *)location {
	CLLocation *loc = %orig;

	return __wiiauto_location(loc);
}

%end

%hook CLLocation

- (CLLocationCoordinate2D) coordinate {
    
    CLLocationCoordinate2D pos = %orig;
    
	f64 lat, lng;
	u8 ovr;

	u64 cm = __current_timestamp();
	if (cm - __coord_timestamp__ >= 1000) {
		__coord_timestamp__ = cm;

		common_get_gps_location(&lat, &lng, &ovr);
		if (ovr && (lat > 0 || lng > 0)) {
			__latitude__ = lat;
			__longitude__ = lng;
		} else {
			__latitude__ = pos.latitude;
			__longitude__ = pos.longitude;
		}
	}

	return CLLocationCoordinate2DMake(__latitude__, __longitude__);
}

%end

%hook NSProcessInfo 


-(NSString *)operatingSystemVersionString
{
	NSString *v = nil;
	const char *value;
	value = wiiauto_device_db_get_share("nsprocessinfo", "operating.system.version.string");
	if (value) {
		v = [NSString stringWithUTF8String:value];
		free(value);
	}	
	if (!v) {
		v = %orig;
	}
	remote_log("NSPRocessInfo-operatingSystemVersionString: %s\n", [v UTF8String]);
	return v;
}

-(BOOL)isOperatingSystemAtLeastVersion:(NSOperatingSystemVersion)arg1
{
	const char *majorVersion = NULL;
	const char *minorVersion = NULL;
	const char *patchVersion = NULL;

	majorVersion = wiiauto_device_db_get_share("nsprocessinfo", "operating.system.version.major");
	minorVersion = wiiauto_device_db_get_share("nsprocessinfo", "operating.system.version.minor");
	patchVersion = wiiauto_device_db_get_share("nsprocessinfo", "operating.system.version.patch");

	remote_log("NSPRocessInfo-isOperatingSystemAtLeastVersion\n");

	if (majorVersion && minorVersion && patchVersion) {

		NSInteger a = atoi(majorVersion);
		NSInteger b = atoi(minorVersion);
		NSInteger c = atoi(patchVersion);

		if (a < arg1.majorVersion) return FALSE;
		if (a > arg1.majorVersion) return TRUE;

		if (b < arg1.minorVersion) return FALSE;
		if (b > arg1.minorVersion) return TRUE;

		if (c < arg1.patchVersion) return FALSE;
		return TRUE;
	}
	
	return %orig;
}

-(NSOperatingSystemVersion)operatingSystemVersion
{
	NSOperatingSystemVersion ret;
	int overrided = 0;
	const char *majorVersion = NULL;
	const char *minorVersion = NULL;
	const char *patchVersion = NULL;

	majorVersion = wiiauto_device_db_get_share("nsprocessinfo", "operating.system.version.major");
	minorVersion = wiiauto_device_db_get_share("nsprocessinfo", "operating.system.version.minor");
	patchVersion = wiiauto_device_db_get_share("nsprocessinfo", "operating.system.version.patch");

	if (majorVersion && minorVersion && patchVersion) {
		overrided = 1;
		ret.majorVersion = atoi(majorVersion);
		ret.minorVersion = atoi(minorVersion);
		ret.patchVersion = atoi(patchVersion);
	}

	if (majorVersion) {
		free(majorVersion);
	}
	if (minorVersion) {
		free(minorVersion);
	}
	if (patchVersion) {
		free(patchVersion);
	}

	remote_log("NSPRocessInfo-operatingSystemVersion\n");
	if (overrided) {
		return ret;
	} else {
		return %orig;
	}
}

-(double)systemUptime
{	
	const char *value;
	value = wiiauto_device_db_get_share("google", "gmail_boottime");
	if (!value) {
		value = wiiauto_device_db_get_share("sysctl", "kern.boottime");
	}
	if (value) {
		int d = atoi(value);
		free(value);

		double cf;
		struct timeval tv;
		gettimeofday( &tv, NULL );
		cf = tv.tv_sec + ( tv.tv_usec / 1000000.0 );

		// u64 ml = __current_timestamp();
		// double cf = ml * 1.0f / 1000.0f;

		double dd = cf - d * 1.0f;
		// remote_log("NSPRocessInfo-systemUptime: %lf\n", dd);
		return dd;
	} else {
		double dd = %orig;
		// remote_log("NSPRocessInfo-systemUptime: %lf\n", dd);
		return dd;
	}
}

%end


// %hook BluetoothManager

// - (BOOL)setEnabled:(BOOL)arg1 {
//    return %orig(NO);
// }

// - (BOOL)setPowered:(BOOL)arg1{
//     return %orig(NO);
// }

// -(BOOL)enabled {
//     return NO;
// }
// %end

// %hook MCMMetadata

// + (id)readAndValidateMetadataAtFileUrl:(id)arg1 forUserIdentity:(id)arg2 checkClassPath:(_Bool)arg3 error:(id *)arg4
// {
// 	@try {
// 		NSString *str = [NSString stringWithFormat:@"%@ %@", arg1, arg2];
// 		const char *content = [str UTF8String];
// 		remote_log_2("meta1: %s\n", content);
// 	} @catch (NSException *e) {

// 	}
	
// 	return %orig;
// }

// + (id)readAndValidateMetadataAtUrl:(id)arg1 forUserIdentity:(id)arg2 checkClassPath:(_Bool)arg3 error:(id *)arg4
// {
// 	@try {
// 		NSString *str = [NSString stringWithFormat:@"%@ %@", arg1, arg2];
// 		const char *content = [str UTF8String];
// 		remote_log_2("meta2: %s\n", content);
// 	} @catch (NSException *e) {

// 	}
// 	return %orig;
// }

// %end

%hook SpringBoard

-(void)applicationDidFinishLaunching:(id)application {
	%orig;

	wiiauto_device_init();
	springboard_init();
	springboard_init_refresh();

	logWindow = [[LogWindow alloc] init];

	springboard_init_status_bar_delegate(springboard_set_status_bar, springboard_set_status_bar_state);
}

%end

%hook WiiAutoWatcher

-(BOOL) is_jailbreaking
{
	return YES;
}

%end

%hook UIDevice

-(id)uniqueIdentifier
{
	// remote_log("OLD_UDID\n");
	return %orig;
}

-(id) identifierForVendor {

	NSString *bundle = [NSBundle mainBundle].bundleIdentifier;

	if (bundle) {
		// remote_log("bundle_need_vendor: %s\n", [bundle UTF8String]);
		const char *ss = wiiauto_device_db_get([bundle UTF8String], "WiiAuto_VendorID");
		if (ss) {
			// remote_log("bundle_need_vendor_is: %s - %s\n", [bundle UTF8String], ss);
			NSUUID *u = [[NSUUID alloc] initWithUUIDString:[NSString stringWithUTF8String:ss]];
			free(ss);
			bundle = nil;
			return u;
		}
		bundle = nil;
	}

	return %orig;

	// NSString *s = wiiauto_device_get_pref(@"WiiAuto_VendorID");
	// if (s) {
	// 	return [[NSUUID alloc] initWithUUIDString:s];
	// } else {
	// 	return %orig;
	// }
}

-(NSString *) model {

	NSString *bundle = [NSBundle mainBundle].bundleIdentifier;

	if (bundle) {
		const char *s = wiiauto_device_db_get([bundle UTF8String], "DeviceClass");
		if (s) {
			NSString *ns = [NSString stringWithUTF8String:s];
			free(s);
			bundle = nil;
			return ns;
		}
		bundle = nil;
	}

	return %orig;

	// NSString *s = wiiauto_device_get_pref(@"DeviceClass");
	// if (s) {
	// 	return s;
	// } else {
	// 	return %orig;
	// }
}

-(NSString *)buildVersion
{
	NSString *bundle = [NSBundle mainBundle].bundleIdentifier;

	if (bundle) {
		const char *s = wiiauto_device_db_get([bundle UTF8String], "BuildVersion");
		if (s) {
			NSString *ns = [NSString stringWithUTF8String:s];
			free(s);
			bundle = nil;
			return ns;
		}
		bundle = nil;
	}

	return %orig;

    // NSString *buildVersion = wiiauto_device_get_pref(@"BuildVersion");
    // if (buildVersion != nil)
    // {
    //     return buildVersion;
    // }
     
    // return %orig;
}

%end

%hook ASIdentifierManager

- (NSUUID *)advertisingIdentifier {

	NSString *bundle = [NSBundle mainBundle].bundleIdentifier;

	if (bundle) {
		// remote_log("bundle_need_idfa: %s\n", [bundle UTF8String]);
		const char *ss = wiiauto_device_db_get([bundle UTF8String], "WiiAuto_IDFA");
		if (ss) {
			// remote_log("bundle_need_idfa_is: %s - %s\n", [bundle UTF8String], ss);
			NSUUID *u = [[NSUUID alloc] initWithUUIDString:[NSString stringWithUTF8String:ss]];
			free(ss);
			bundle = nil;
			return u;
		}
		bundle = nil;
	}

	return %orig;

	// NSString *s = wiiauto_device_get_pref(@"WiiAuto_IDFA");
	// if (s) {
	// 	return [[NSUUID alloc] initWithUUIDString:s];
	// } else {
	// 	return %orig;
	// }
}

%end

%hook __NSCFLocale

%property (nonatomic, assign) u8 wiiauto_current;

- (id)objectForKey:(NSLocaleKey)key
{
	if (self.wiiauto_current == 55) {
		if ([((NSString *)key) isEqualToString:NSLocaleCountryCode]) {

			// NSString *rpl = wiiauto_device_get_pref(@"WiiAuto_CountryCode");

			NSString *bundle = [NSBundle mainBundle].bundleIdentifier;

			if (bundle) {
				const char *s = wiiauto_device_db_get([bundle UTF8String], "WiiAuto_CountryCode");
				if (s) {
					NSString *ns = [NSString stringWithUTF8String:s];
					free(s);
					bundle = nil;
					return ns;
				}
				bundle = nil;
			}
		}
	}
	return %orig;
}

%end

%hook NSLocale

%property (nonatomic, assign) u8 wiiauto_current;

- (id)init {
	self = %orig;
	if (self != nil) {
		self.wiiauto_current = 0;
	}
	return self;
}

-(id)initWithLocaleIdentifier:(id)arg1
{
	self = %orig(arg1);
	if (self != nil) {
		self.wiiauto_current = 0;
	}
	return self;
}

-(id)initWithCoder:(id)arg1
{
	self = %orig(arg1);
	if (self != nil) {
		self.wiiauto_current = 0;
	}
	return self;
}

+(NSLocale *)currentLocale
{
	NSLocale *l = %orig;
	l.wiiauto_current = 55;
	return l;
}

- (id)copyWithZone:(NSZone *)zone {

	NSLocale *l = %orig;
	l.wiiauto_current = self.wiiauto_current;
    return l;
}

- (id)objectForKey:(NSLocaleKey)key
{
	if (self.wiiauto_current == 55) {
		if ([((NSString *)key) isEqualToString:NSLocaleCountryCode]) {
			// NSString *rpl = wiiauto_device_get_pref(@"WiiAuto_CountryCode");
			// if (rpl) return rpl;

			NSString *bundle = [NSBundle mainBundle].bundleIdentifier;

			if (bundle) {
				const char *s = wiiauto_device_db_get([bundle UTF8String], "WiiAuto_CountryCode");
				if (s) {
					NSString *ns = [NSString stringWithUTF8String:s];
					free(s);
					bundle = nil;
					return ns;
				}
				bundle = nil;
			}
		}
	}

	return %orig;
}

-(NSString *)countryCode
{
	if (self.wiiauto_current == 55) {
		// NSString *rpl = wiiauto_device_get_pref(@"WiiAuto_CountryCode");
		// if (rpl) return rpl;

		NSString *bundle = [NSBundle mainBundle].bundleIdentifier;

		if (bundle) {
			const char *s = wiiauto_device_db_get([bundle UTF8String], "WiiAuto_CountryCode");
			if (s) {
				NSString *ns = [NSString stringWithUTF8String:s];
				free(s);
				bundle = nil;
				return ns;
			}
			bundle = nil;
		}
	}

	return %orig;
}

%end

// %hook LSApplicationWorkspace

// - (bool)openApplicationWithBundleID:(NSString *)arg1
// {
// 	char buf[1024];
// 	if (arg1) {
// 		sprintf(buf, "open: %s", [arg1 UTF8String]);
// 		common_set_status_bar(buf);
// 	}
// 	return %orig;
// }

// %end


%hook WKWebView

static void notificationCallback(CFNotificationCenterRef center,
                               void * observer,
                               CFStringRef name,
                               void const * object,
                               CFDictionaryRef userInfo) {
   
	WKWebView *self = (__bridge WKWebView *)observer;

	[self evaluateJavaScript:@"document.documentElement.outerHTML.toString()" completionHandler:^(id __nullable source, NSError * __nullable error) {
		
		if (source) {
			wiiauto_device_db_set_share("wkwebview", "source", [source UTF8String]);
		}

	}];
}

static void notificationApplyUserAgent(CFNotificationCenterRef center,
                               void * observer,
                               CFStringRef name,
                               void const * object,
                               CFDictionaryRef userInfo)
{
	WKWebView *self = (__bridge WKWebView *)observer;

	const char *str = wiiauto_device_db_get_share("wkwebview", "apply-user-agent");
	if (str) {
		self.customUserAgent = [NSString stringWithUTF8String:str];
		free(str);
	}
}

// %new
// -(void)getSource:(NSNotification *)notification 
// {

// 	[self evaluateJavaScript:@"document.getElementsByTagName('html')[0].innerHTML" completionHandler:^(id __nullable source, NSError * __nullable error) {
		
// 		if (source) {
// 			wiiauto_device_db_set_share("wkwebview", "source", [source UTF8String]);
// 		}

// 	}];
// }

-(id)initWithCoder:(id)arg1
{
	self = %orig;

	const char *str = wiiauto_device_db_get_share("wkwebview", "init-user-agent");
	if (str) {
		WKWebView *__self = self;
		__self.customUserAgent = [NSString stringWithUTF8String:str];
		free(str);
	}

	return self;
}

-(id)initWithFrame:(CGRect)arg1 {

	self = %orig;

	const char *str = wiiauto_device_db_get_share("wkwebview", "init-user-agent");
	if (str) {
		WKWebView *__self = self;
		__self.customUserAgent = [NSString stringWithUTF8String:str];
		free(str);
	}


	return self;

}

- (id)initWithFrame:(CGRect)arg1 configuration:(id)arg2 {
	self = %orig;

	// NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
	// [center addObserver:self selector:@selector(getSource:) name:@"wkwebview_getSource" object:nil];

	CFNotificationCenterRef const center = CFNotificationCenterGetDarwinNotifyCenter();
    CFNotificationCenterAddObserver(center,
                                    (__bridge const void *)(self),
                                    notificationCallback,
                                    CFSTR("wkwebview_getSource"),
                                    NULL,
                                    CFNotificationSuspensionBehaviorDeliverImmediately);
	CFNotificationCenterAddObserver(center,
                                    (__bridge const void *)(self),
                                    notificationApplyUserAgent,
                                    CFSTR("wkwebview_applyUserAgent"),
                                    NULL,
                                    CFNotificationSuspensionBehaviorDeliverImmediately);

	WKWebView *__self = self;
	const char *str = wiiauto_device_db_get_share("wkwebview", "init-user-agent");
	if (str) {
		__self.customUserAgent = [NSString stringWithUTF8String:str];
		free(str);
	}

	// __self.customUserAgent = @"Mozilla/5.0 (iPhone; CPU iPhone OS 12_4 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/12.1 Mobile/15E148 Safari/604.1";

	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue() , ^{

		[__self evaluateJavaScript:@"navigator.userAgent" completionHandler:^(id __nullable userAgent, NSError * __nullable error) {
			if (__self.URL) {
				NSString *str = __self.URL.absoluteString;
				if (str) {
					wiiauto_device_db_set_share("wkwebview", "url", [str UTF8String]);
				}
			}
			if (userAgent) {
				wiiauto_device_db_set_share("wkwebview", "user-agent", [userAgent UTF8String]);
			}
		}];

	});

	return self;
}

-(id)loadRequest:(id)arg1
{
	// remote_log("wkwebivew_loadrequest\n");
	return %orig(arg1);
}

- (void)dealloc 
{
    // [[NSNotificationCenter defaultCenter] removeObserver:self];
	CFNotificationCenterRef const center = CFNotificationCenterGetDarwinNotifyCenter();
    CFNotificationCenterRemoveObserver(center,
                                       (__bridge const void *)(self),
                                       CFSTR("wkwebview_getSource"),
                                       NULL);
}

%end

/*
 * sbapplication
 */
 %hook SBIconListModel

BOOL checkIfHideCString(const char *str, const char *bundle)
{
	bool ret = NO;

	if (str) {
		size_t len_orig = strlen(bundle);
		size_t len = strlen(str);
		if (strncmp(str, bundle, len_orig) == 0) {
			if (len > len_orig) {
				ret = YES;
			}
		}
	}

	return ret;
}

BOOL checkIfHide(NSString *appID) {
	
	bool ret = NO;

	@try {
		if (appID) {
			const char *str = [appID UTF8String];
			if (str) {
				if (!ret) ret = checkIfHideCString(str, "com.gamehd.swordsmanlegend");
				if (!ret) ret = checkIfHideCString(str, "com.bgate.samurai");
			}
		}
	} @catch (NSException *e) {
	}

	return ret;
}

- (id)placeIcon:(SBApplicationIcon *)icon atIndex:(unsigned long long*)arg2 {
	bool ret = NO;

	@try {
		ret = checkIfHide([icon applicationBundleID]);
	} @catch (NSException *e) {
		ret = NO;
	}

	if (!ret) {
		return %orig;
	}
	return nil;
}

- (id)insertIcon:(SBApplicationIcon *)icon atIndex:(unsigned long long*)arg2 options:(unsigned long long)arg3 {
	bool ret = NO;

	@try {
		ret = checkIfHide([icon applicationBundleID]);
	} @catch (NSException *e) {
		ret = NO;
	}
	
	if (!ret) {
		return %orig;
	}
	return nil;
}

- (BOOL)addIcon:(SBApplicationIcon *)icon asDirty:(BOOL)arg2 {
	bool ret = NO;

	@try {
		ret = checkIfHide([icon applicationBundleID]);
	} @catch (NSException *e) {
		ret = NO;
	}
	
	if (!ret) {
		return %orig;
	}

	return NO;
}

%end

%hook AppDelegate

-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
	{
		NSData *d = deviceToken;
		if (d) {
			const unsigned char *p = (const unsigned char *) [d bytes];
			int i;
			char buf[1024];
			for(i = 0; i < [d length]; i++)
			{
				if (i > 0) {
					sprintf(buf + strlen(buf), ":%02hhX", p[i]);
				} else {
					sprintf(buf + strlen(buf), "%02hhX", p[i]);
				}				
			}

			wiiauto_device_db_set_share("google", "gmail_push_token", buf);					
		} else {
			wiiauto_device_db_set_share("google", "gmail_push_token", NULL);	
		}
	}

	%orig;
}

%end

%hook NRDevice

-(id)valueForProperty:(id)arg1
{
	// remote_log("NRDEVICE: valueForProperty\n");
	return %orig(arg1);
}

%end

%hook IMAccount

%new
- (NSString *) get_login_id {
    return [self valueForKey:@"_loginID"];
}

%new
- (NSString *) get_unique_id {
    return [self valueForKey:@"_uniqueID"];
}

%end



// %hook MTLTexture

// - (void)replaceRegion:(MTLRegion)region 
//           mipmapLevel:(NSUInteger)level 
//             withBytes:(const void *)pixelBytes 
//           bytesPerRow:(NSUInteger)bytesPerRow
// {
// 	remote_log("replaceRegion1: %d %d\n", region.size.width, region.size.height);
// 	%orig;
// }

// - (void)replaceRegion:(MTLRegion)region 
//           mipmapLevel:(NSUInteger)level 
//                 slice:(NSUInteger)slice 
//             withBytes:(const void *)pixelBytes 
//           bytesPerRow:(NSUInteger)bytesPerRow 
//         bytesPerImage:(NSUInteger)bytesPerImage
// {
// 	remote_log("replaceRegion2: %d %d\n", region.size.width, region.size.height);
// 	%orig;
// }

// %end

%hook  LSApplicationProxy 


+(id)applicationProxyForIdentifier:(id)arg1 placeholder:(BOOL)arg2
{
	NSString *l = [NSString stringWithFormat:@"%@", arg1];
	if (l && [l UTF8String]) remote_log("LSApplicationProxy : applicationProxyForIdentifier placeholder | %s\n", [l UTF8String]);
	return %orig;
}

+(id)applicationProxyForSystemPlaceholder:(id)arg1
{
	NSString *l = [NSString stringWithFormat:@"%@", arg1];
	if (l && [l UTF8String]) remote_log("LSApplicationProxy : applicationProxyForSystemPlaceHolder | %s\n", [l UTF8String]);
	return %orig;
}

+(id)applicationProxyForIdentifier:(id)arg1
{
	NSString *l = [NSString stringWithFormat:@"%@", arg1];
	if (l && [l UTF8String]) remote_log("LSApplicationProxy : applicationProxyForIdentitifer | %s\n", [l UTF8String]);
	return %orig;
}

+(id)applicationProxyForBundleURL:(id)arg1
{
	NSString *l = [NSString stringWithFormat:@"%@", arg1];
	if (l && [l UTF8String]) remote_log("LSApplicationProxy : applicationProxyForBundleURL | %s\n", [l UTF8String]);
	return %orig;
}

+(id)applicationProxyWithBundleUnitID:(unsigned)arg1 withContext:(void*)arg2
{
	remote_log("LSApplicationProxy : applicationProxyForBundleUnitID WithContext | %u\n", arg1);
	return %orig;
}

+(id)applicationProxyForIdentifier:(id)arg1 withContext:(void*)arg2
{
	NSString *l = [NSString stringWithFormat:@"%@", arg1];
	if (l && [l UTF8String]) remote_log("LSApplicationProxy : applicationProxyForIdentitifer WithContext | %s\n", [l UTF8String]);
	return %orig;
}

+(id)applicationProxyForBundleType:(unsigned long long)arg1 identifier:(id)arg2 isCompanion:(BOOL)arg3 URL:(id)arg4 itemID:(id)arg5 bundleUnit:(unsigned*)arg6
{
	NSString *l = [NSString stringWithFormat:@"%@", arg2];
	if (l && [l UTF8String]) remote_log("LSApplicationProxy : applicationProxyForBundleType | %s\n", [l UTF8String]);
	return %orig;
}

+(id)iconQueue
{
	remote_log("LSApplicationProxy : iconQueue\n");
	return %orig;
}

+(id)applicationProxyForCompanionIdentifier:(id)arg1
{
	NSString *l = [NSString stringWithFormat:@"%@", arg1];
	if (l && [l UTF8String]) remote_log("LSApplicationProxy : applicationProxyForCompanionIdentitifer | %s\n", [l UTF8String]);
	return %orig;
}

+(id)applicationProxyForItemID:(id)arg1
{
	NSString *l = [NSString stringWithFormat:@"%@", arg1];
	if (l && [l UTF8String]) remote_log("LSApplicationProxy : applicationProxyForItemID | %s\n",[l UTF8String]);
	return %orig;
}


%end

%hook NSURLSession

- (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request
                            completionHandler:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completionHandler
{
	// remote_log("nsurlsession: datataskwithrequest_handler\n");
	NSString *l = [NSString stringWithFormat:@"%@", request.URL];
	@try {		
		if (l) {
			remote_log("%p nsurlsession: datataskwithrequest_handler : %s\n", self, [l UTF8String]);
		}
	} @catch (NSException *e) {

	}

	return %orig(request, completionHandler);
}

- (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request
{
	@try {

		NSString *l = [NSString stringWithFormat:@"%@", request.URL];
		if (l) {
			remote_log("%p nsurlsession: datataskwithrequest : %s\n", self, [l UTF8String]);
		}
	} @catch (NSException *e) {

	}
    return %orig(request);
}

- (id)dataTaskWithURL:(NSURL *)url completionHandler:(id)completionHandler{
    @try {

		NSString *l = [NSString stringWithFormat:@"%@", url];
		if (l) {
			remote_log("nsurlsession: datataskwithurl : %s\n", [l UTF8String]);
		}
	} @catch (NSException *e) {

	}
    return %orig;
}

%end

%hook NSURLRequest

+ (id)requestWithURL:(NSURL *)URL
{
	@try {

		NSString *l = [NSString stringWithFormat:@"%@", URL];
		if (l) {
			remote_log("%p nsurlrequest requestWithURL: %s\n", self, [l UTF8String]);
		}	
	} @catch (NSException *e) {

	}
    return %orig(URL);
}

+(id)requestWithURL:(id)arg1 cachePolicy:(unsigned long long)arg2 timeoutInterval:(double)arg3
{
	@try {

		NSString *l = [NSString stringWithFormat:@"%@", arg1];
		if (l) {
			remote_log("%p nsurlrequest requestWithURL-cachePolicy: %s\n", self, [l UTF8String]);
		}	
	} @catch (NSException *e) {

	}
    return %orig;
}

%end

%hook NSMutableURLRequest

static long long __inapp_request_id = 0;
static double __inapp_time = 0;

static double __current_time()
{
	double cf;
	struct timeval tv;
	gettimeofday( &tv, NULL );
	cf = tv.tv_sec + ( tv.tv_usec / 1000000.0 );
	return cf;
}

+ (id)requestWithURL:(NSURL *)URL
{
	@try {

		NSString *l = [NSString stringWithFormat:@"%@", URL];
		if (l) {
			remote_log("nsmutableurlrequest requestWithURL: %s\n", [l UTF8String]);
		}	
	} @catch (NSException *e) {

	}
    return %orig(URL);
}

+(id)requestWithURL:(id)arg1 cachePolicy:(unsigned long long)arg2 timeoutInterval:(double)arg3
{
	@try {

		NSString *l = [NSString stringWithFormat:@"%@", arg1];
		if (l) {
			remote_log("nsmutableurlrequest requestWithURL-cachePolicy: %s\n", [l UTF8String]);
		}	
	} @catch (NSException *e) {

	}
    return %orig;
}

-(void)setURL:(id)arg1
{
	int replaced = 0;
	@try {

		NSString *l = [NSString stringWithFormat:@"%@", arg1];
		if (l) {
			remote_log("%p nsmutableurlrequest-setURL: %s\n",  self, [l UTF8String]);
		}
	} @catch (NSException *e) {

	}
	if (replaced == 0) {
		%orig(arg1);
	}
}

-(void)setAllHTTPHeaderFields:(id)arg1
{
	@try {

		NSString *l = [NSString stringWithFormat:@"%@", arg1];
		if (l) {
			remote_log("%p nsmutableurlrequest: setAllHTTPHeaderFields %s\n", self,  [l UTF8String]);
		}
	} @catch (NSException *e) {

	}
	remote_log("nsmutableurlrequest: finished\n");
	%orig;
}

-(void)addValue:(id)arg1 forHTTPHeaderField:(id)arg2
{
	@try {

		NSString *l = [NSString stringWithFormat:@"%@ <- %@", arg2, arg1];
		if (l) {
			remote_log("%p nsmutableurlrequest: addValue %s\n", self,  [l UTF8String]);

			const char *target;
			const char *target_index;
			target = wiiauto_device_db_get_share("inappcheck", "current_bundle");
			target_index = wiiauto_device_db_get_share("inappcheck", "current_bundle_index");

			long long v = (long long) self;
			if (target && target_index && __inapp_request_id > 0 && (v == __inapp_request_id)) {
				double f = __current_time();
				if (fabs(f - __inapp_time) < 10) {
					if (arg1 && arg2) {
						const char *c1 = [arg1 UTF8String];
						const char *c2 = [arg2 UTF8String];
						if (c1 && c2) {

							char buf[1024];
							sprintf(buf, "%s_%s", target, target_index);	

							wiiauto_device_db_set_share(buf, c2, c1);
						}
					}					
				}
			}
		}
	} @catch (NSException *e) {

	}
	%orig;
}

-(void)setValue:(NSString *)arg1 forHTTPHeaderField:(NSString *)arg2
{
	int overrided = 0;
	@try {

		NSString *l = [NSString stringWithFormat:@"%@ <- %@", arg2, arg1];
		if (l) {
			remote_log("%p nsmutableurlrequest: setValue %s\n",  self, [l UTF8String]);

			const char *target;
			const char *target_index;
			target = wiiauto_device_db_get_share("inappcheck", "current_bundle");
			target_index = wiiauto_device_db_get_share("inappcheck", "current_bundle_index");

			long long v = (long long) self;
			if (target && target_index && __inapp_request_id > 0 && (v == __inapp_request_id)) {
				double f = __current_time();
				if (fabs(f - __inapp_time) < 10) {
					if (arg1 && arg2) {
						const char *c1 = [arg1 UTF8String];
						const char *c2 = [arg2 UTF8String];
						if (c1 && c2) {

							char buf[1024];
							sprintf(buf, "%s_%s", target, target_index);	

							wiiauto_device_db_set_share(buf, c2, c1);
						}
					}					
				}
			}
		}
		{
			if (self.URL) {
				NSString *l = [NSString stringWithFormat:@"%@", self.URL];
				if (l) {
					remote_log("%p nsmutableurlrequest: setValue-testURL %s\n",  self, [l UTF8String]);
				}
			}
		}
		// if (arg2 && [arg2 isEqualToString:@"X-Apple-ADSID"]) {
		// 	overrided = 1;
		// 	%orig(@"000719-10-ddc24434-424c-458d-86ff-842e1f2b6b75", arg2);
		// }
		// NSString *us = arg2;
		// if (us && [us isEqualToString:@"User-Agent"]) {
		// 	overrided = 1;
		// 	%orig(@"Mozilla/5.0 (iPhone; CPU iPhone OS 13_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) CriOS/87.0.4280.77 Mobile/15E148 Safari/604.1", arg2);
		// }
	} @catch (NSException *e) {

	}
	if (overrided == 0) {
		%orig;
	}	
}

-(void)setHTTPBody:(id)arg1
{
	int replaced = 0;
	@try {
		remote_log("try set httpbody\n");
		int try_inject = 0;
		NSString *l = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithData:arg1 encoding:NSUTF8StringEncoding]];
		if (l) {
			remote_log("%p nsmutableurlrequest: setHTTPBody %d | %d | %s\n",  self, [l length], [arg1 length], [l UTF8String]);

			if ([l length] != [arg1 length]) {

				NSData* originalData = [arg1 gzipInflate];
				NSString *ll = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithData:originalData encoding:NSUTF8StringEncoding]];
				if (ll) remote_log("%p nsmutableurlrequest-ungzip: setHTTPBody %d | %d | %s\n",  self, [ll length], [originalData length], [ll UTF8String]);
			}

			const char *target;
			const char *target_index;
			target = wiiauto_device_db_get_share("inappcheck", "current_bundle");
			target_index = wiiauto_device_db_get_share("inappcheck", "current_bundle_index");

			const char *content = [l UTF8String];
			if (target && target_index && content 
				&& strstr(content, ">appAdamId<")
				&& strstr(content, ">appExtVrsId<")
				&& strstr(content, ">bid<")
				&& strstr(content, ">bvrs<")
				&& strstr(content, ">guid<")
				&& strstr(content, ">serialNumber<")
				&& strstr(content, target)
				&& strstr(content, ">vid<"))
			{
				const char *bundle_name;	

				char buf[1024];
				sprintf(buf, "%s_%s", target, target_index);			

				wiiauto_device_db_set_share(buf, "httpbody", content);
				__inapp_request_id = (long long)self;
				__inapp_time = __current_time();
			}

			if (target) {
				free(target);
			}
			if (target_index) {
				free(target_index);
			}

		}
	} @catch (NSException *e) {

	}
	if (replaced == 0) {
		%orig;
	}
}

-(void)setHTTPBodyStream:(NSInputStream *)arg1 
{
	@try {

		remote_log("%p nsmutableurlrequest: setHTTPBdyStream\n", self);

	} @catch (NSException *e) {

	}
	%orig;
}

-(void)setHTTPExtraCookies:(id)arg1
{
	@try {

		NSString *l = [NSString stringWithFormat:@"%@", arg1];
		if (l) {
			remote_log("%p nsmutableurlrequest: setHTTPExtraCookies %s\n",  self, [l UTF8String]);
		}
	} @catch (NSException *e) {

	}
	%orig;
}

-(void)setHTTPReferrer:(id)arg1 
{
	@try {

		NSString *l = [NSString stringWithFormat:@"%@", arg1];
		if (l) {
			remote_log("%p nsmutableurlrequest: setHTTPReferrer %s\n",  self, [l UTF8String]);
		}
	} @catch (NSException *e) {

	}
	%orig;
}

-(void)setHTTPUserAgent:(id)arg1
{
	@try {

		NSString *l = [NSString stringWithFormat:@"%@", arg1];
		if (l) {
			remote_log("%p nsmutableurlrequest: setHTTPUserAgent %s\n",  self, [l UTF8String]);
		}
	} @catch (NSException *e) {

	}
	%orig;
}

-(void)setHTTPContentType:(id)arg1
{
	@try {

		NSString *l = [NSString stringWithFormat:@"%@", arg1];
		if (l) {
			remote_log("%p nsmutableurlrequest: setHTTPContentType %s\n",  self, [l UTF8String]);
		}
	} @catch (NSException *e) {

	}
	%orig;
}

-(void)setHTTPMethod:(NSString *)arg1 
{
	@try {

		NSString *l = [NSString stringWithFormat:@"%@", arg1];
		if (l) {
			remote_log("%p nsmutableurlrequest: setHTTPMethod %s\n",  self, [l UTF8String]);
		}
	} @catch (NSException *e) {

	}
	%orig;
}

%end


%hook NSInputStream

+(id)inputStreamWithData:(id)arg1
{
	@try {
		remote_log("nsinputstream: inputStreamWithData\n");
	} @catch (NSException *e) {

	}
	return %orig;
}

+(id)inputStreamWithFileAtPath:(id)arg1
{	
	@try {

		NSString *l = [NSString stringWithFormat:@"%@", arg1];
		if (l) {
			remote_log("nsinputstream: withFile %s\n", [l UTF8String]);
		}
	} @catch (NSException *e) {

	}
	return %orig;
}

+(id)inputStreamWithURL:(id)arg1
{
	@try {

		NSString *l = [NSString stringWithFormat:@"%@", arg1];
		if (l) {
			remote_log("nsinputstream: withURL %s\n", [l UTF8String]);
		}
	} @catch (NSException *e) {

	}
	return %orig;
}

-(id)initWithURL:(id)arg1
{
	@try {

		NSString *l = [NSString stringWithFormat:@"%@", arg1];
		if (l) {
			remote_log("%p nsinputstream: initWithURL %s\n",  self, [l UTF8String]);
		}
	} @catch (NSException *e) {

	}
	return %orig;
}

-(id)initWithData:(id)arg1
{
	@try {

		NSString *l = [NSString stringWithFormat:@"%@", arg1];
		if (l) {
			remote_log("%p nsinputstream: initWithData %s\n",  self, [l UTF8String]);
		}
	} @catch (NSException *e) {

	}
	return %orig;
}

-(id)initWithFileAtPath:(id)arg1
{
	@try {

		NSString *l = [NSString stringWithFormat:@"%@", arg1];
		if (l) {
			remote_log("%p nsinputstream: initWithFileAtPath%s\n",  self, [l UTF8String]);
		}
	} @catch (NSException *e) {

	}
	return %orig;
}

-(long long)read:(char*)arg1 maxLength:(unsigned long long)arg2
{
	long long n = %orig;

	@try {

		// NSString *l = [NSString stringWithFormat:@"%@", arg1];
		// if (l) {
			remote_log("%p nsinputstream: read %llu\n",  self, arg2);
		// }
	} @catch (NSException *e) {

	}

	return n;
}

%end

// %hook NSUbiquitousKeyValueStore

// - (id)objectForKey:(NSString *)aKey
// {
// 	remote_log("NSUbiquitousKeyValueStore: objectForKey\n");
// 	return %orig;
// }

// - (void)setObject:(id)anObject forKey:(NSString *)aKey
// {	
// 	remote_log("NSUbiquitousKeyValueStore: setObject\n");
// 	%orig;
// }

// - (void)removeObjectForKey:(NSString *)aKey
// {
// 	remote_log("NSUbiquitousKeyValueStore: removeObjectForKey\n");
// 	%orig;
// }

// - (NSString *)stringForKey:(NSString *)aKey
// {
// 	remote_log("NSUbiquitousKeyValueStore: stringForKey\n");
// 	return %orig;
// }

// - (NSArray *)arrayForKey:(NSString *)aKey
// {
// 	remote_log("NSUbiquitousKeyValueStore: arrayForKey\n");
// 	return %orig;
// }

// - (NSDictionary<NSString *, id> *)dictionaryForKey:(NSString *)aKey
// {
// 	remote_log("NSUbiquitousKeyValueStore: dictionaryForKey\n");
// 	return %orig;
// }

// - (NSData *)dataForKey:(NSString *)aKey
// {
// 	remote_log("NSUbiquitousKeyValueStore: dataForKey\n");
// 	return %orig;
// }

// - (long long)longLongForKey:(NSString *)aKey
// {
// 	remote_log("NSUbiquitousKeyValueStore: longLongForKey\n");
// 	return %orig;
// }

// - (double)doubleForKey:(NSString *)aKey
// {
// 	remote_log("NSUbiquitousKeyValueStore: doubleForKey\n");
// 	return %orig;
// }

// - (BOOL)boolForKey:(NSString *)aKey
// {
// 	remote_log("NSUbiquitousKeyValueStore: boolForKey\n");
// 	return %orig;
// }

// - (void)setString:(NSString *)aString forKey:(NSString *)aKey
// {
// 	remote_log("NSUbiquitousKeyValueStore: setString\n");
// 	%orig;
// }

// - (void)setData:(NSData *)aData forKey:(NSString *)aKey
// {	
// 	remote_log("NSUbiquitousKeyValueStore: setData\n");
// 	%orig;
// }	

// - (void)setArray:(NSArray *)anArray forKey:(NSString *)aKey
// {
// 	remote_log("NSUbiquitousKeyValueStore: setArray\n");
// 	%orig;
// }

// - (void)setDictionary:(NSDictionary<NSString *, id> *)aDictionary forKey:(NSString *)aKey
// {
// 	remote_log("NSUbiquitousKeyValueStore: setDictionary\n");
// 	%orig;
// }

// - (void)setLongLong:(long long)value forKey:(NSString *)aKey
// {
// 	remote_log("NSUbiquitousKeyValueStore: setLonglong\n");
// 	%orig;
// }

// - (void)setDouble:(double)value forKey:(NSString *)aKey
// {
// 	remote_log("NSUbiquitousKeyValueStore: setDouble\n");
// 	%orig;
// }

// - (void)setBool:(BOOL)value forKey:(NSString *)aKey
// {
// 	remote_log("NSUbiquitousKeyValueStore: setBool\n");
// 	%orig;
// }

// -(NSDictionary<NSString *, id> *)dictionaryRepresentation
// {
// 	remote_log("NSUbiquitousKeyValueStore: dictionaryRepresentation\n");
// 	return %orig;
// }

// - (BOOL)synchronize
// {
// 	remote_log("NSUbiquitousKeyValueStore: synchronize\n");
// 	return %orig;
// }

// %end


// %hook NSUserDefaults
// + (id)standardUserDefaults {
	
// 	NSUserDefaults *userDefaults = %orig();
// 	int is_vietnamese = 1;

// 	const char *value;
// 	value = wiiauto_device_db_get_share("system", "language");
// 	if (value) {
// 		if (strcmp(value, "en") == 0) {
// 			is_vietnamese = 0;
// 		} else {
// 			is_vietnamese = 1;
// 		}
// 		free(value);
// 	}

// 	NSMutableArray *arr = [NSMutableArray array];

// 	if (is_vietnamese) {
// 		[arr addObject:@"vi"];	
// 		[arr addObject:@"en"];	
// 	} else {		
// 		[arr addObject:@"en"];
// 		[arr addObject:@"vi"];
// 	}

// 	[userDefaults setObject:arr forKey:@"AppleLanguages"];

// 	return userDefaults;
// }
// %end


%end


%group HOOK_FB

%hook NSString

-(const char*)UTF8String
{
	const char *sss = %orig;
	if (sss && strstr(sss, "OAuth ")) {
		const char *access_token = sss + 6;
		if (strlen(access_token) > 0) {
			wiiauto_device_db_set_share("facebook", "access_token", access_token);			
		}
	} else if (sss && strstr(sss, "DX3RX")) {
		remote_log("STRING = %s\n", sss);
	}
	return sss;
}


// // // "FBActiveProfileAccessToken"
// -(id)dataUsingEncoding:(unsigned long long)arg1
// {
// 	const char *ptr = [self UTF8String];
// 	if (ptr) {
// 		remote_log("data: %s\n", ptr);
// 	}
// 	return %orig(arg1);
// }

%end

%end


%group HOOK_GM

// -(const char*)UTF8String
// {
// 	const char *sss = %orig;
// 	if (sss && strstr(sss, "l?? m?? x??c nh???n")) {
// 		wiiauto_device_db_set_share("gmail", "facebook_code_text", sss);
// 	}
// 	return sss;
// }


// // Given the function prototype
// FILE *fopen(const char *path, const char *mode);
// // The hook is thus made
// %hookf(FILE *, fopen, const char *path, const char *mode) {
// 	// NSLog(@"Hey, we're hooking fopen to deny relative paths!");
// 	// if (path[0] != '/') {
// 	// 	return NULL;
// 	// }
// 	remote_log("hook fopen\n");
// 	return %orig; // Call the original implementation of this function
// }


%hook UILabel

-(void)setText:(NSString *)arg1
{
	%orig(arg1);	

	if (arg1) {
		const char *sss = [arg1 UTF8String];

		if (sss && strstr(sss, " Facebook ")) {
			wiiauto_device_db_set_share("gmail", "facebook_code_text", sss);
		}
	}
}

%end

%hook NSFileManager

// -(id)URLForUbiquityContainerIdentifier:(id)arg1
// {
// 	NSURL *ret = %orig;
// 	// remote_log("-----------------------------\n")
// 	// remote_log("URLForUbiquityContainerIdentifier\n\n");

// 	// if (arg1) {
// 	// 	NSString *rr = [NSString stringWithFormat:@"%@", arg1];
// 	// 	remote_log("arg1: %s\n", [rr UTF8String]);
// 	// }
// 	// if (ret) {
// 	// 	NSString *rr = [NSString stringWithFormat:@"%@", ret];
// 	// 	remote_log("ret: %s\n", [rr UTF8String]);
// 	// }
// 	// remote_log("-----------------------------\n");
// 	return ret;
// }

-(BOOL)fileExistsAtPath:(id)arg1
{
	@try {
		NSString *s = arg1;
		if (s) {
			const char *name = [s UTF8String]; 		

			remote_log("file_exists: %s\n", name);	

			if (strstr(name, "/Applications/Cydia.app")) return NO;
			if (strstr(name, "/Library/MobileSubstrate")) return NO;
			if (strstr(name, "/bin/bash")) return NO;
			if (strstr(name, "/usr/sbin/sshd")) return NO;
			if (strstr(name, "/etc/apt")) return NO;
			if (strstr(name, "/apt")) return NO;
			if (strstr(name, "/usr/libexec/sftp-server")) return NO;
			if (strstr(name, "/usr/bin/ssh")) return NO;
			if (strstr(name, "/jb")) return NO;
			if (strstr(name, "/var/mobile/Library/ConfigurationProfiles/PublicInfo/MCMeta.plist")) return NO;
		}
	} @catch (NSException *e) {

	}

	return %orig;
}

// -(NSURL *)temporaryDirectory
// {
// 	NSURL *ret = %orig;
// 	// if (ret && ret.absoluteString) {
// 	// 	remote_log("temporaryDirectory: %s\n", [ret.absoluteString UTF8String]);
// 	// }
// 	return ret;
// }

%end

%hook UIApplication

-(BOOL)canOpenURL:(id)arg1
{
	@try {
		NSURL *url = arg1;
		NSString *s = url.absoluteString;
		if (s) {
			const char *name = [s UTF8String]; 

			remote_log("can_open_url: %s\n", name);

			if (strstr(name, "/Applications/Cydia.app")) return NO;
			if (strstr(name, "cydia")) return NO;
			if (strstr(name, "/Library/MobileSubstrate")) return NO;
			if (strstr(name, "/bin/bash")) return NO;
			if (strstr(name, "/usr/sbin/sshd")) return NO;
			if (strstr(name, "/etc/apt")) return NO;
			if (strstr(name, "/apt")) return NO;
			if (strstr(name, "/usr/libexec/sftp-server")) return NO;
			if (strstr(name, "/usr/bin/ssh")) return NO;

		}
	} @catch (NSException *e) {

	}

	return %orig;
}

%end

// // %hook CKConversation

// // -(int)wasDetectedAsSpam
// // {
// // 	int a = %orig;

// // 	remote_log("wasDetectedAsSpam: %d\n", a);
// // 	return a;
// // }

// // -(int)wasDetectedAsSMSSpam
// // {
// // 	int a = %orig;

// // 	remote_log("wasDetectedAsSMSSpam %d\n", a);
// // 	return a;
// // }

// // -(int)wasDetectedAsiMessageSpam
// // {
// // 	int a = %orig;

// // 	remote_log("wasDetectedAsiMessageSpam: %d\n", a);
// // 	return a;
// // }

// // -(BOOL)isReportedAsSpam
// // {
// // 	BOOL a = %orig;

// // 	remote_log("isReportedAsSpam: %s\n", a ? "true" : "false");
// // 	return a;
// // }

// // // -(void)setIsReportedAsSpam:(BOOL)arg1
// // // {
// // // 	%orig(FALSE);
// // // }

// // %end

%end

static NSArray<NSString *> * (*orig_NSSearchPathForDirectoriesInDomains)(NSSearchPathDirectory directory, NSSearchPathDomainMask domainMask, BOOL expandTilde);
static NSArray<NSString *> * repl_NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory directory, NSSearchPathDomainMask domainMask, BOOL expandTilde)
{
	// remote_log("NSSearchPath\n");
	NSArray<NSString *> *ret = orig_NSSearchPathForDirectoriesInDomains(directory, domainMask, expandTilde);

	// if (ret) {
	// 	for (NSString *rr in ret) {
	// 		if (rr) {
	// 			remote_log("NSSearchPath_rr: %s\n", [rr UTF8String]);
	// 		}
	// 	}
	// }

	return ret;
}

// keychain
static OSStatus (*orig_SecItemAdd)(CFDictionaryRef attributes, CFTypeRef  _Nullable *result);
static OSStatus (*orig_SecItemCopyMatching)(CFDictionaryRef query, CFTypeRef  _Nullable *result);
static OSStatus (*orig_SecItemUpdate)(CFDictionaryRef query, CFDictionaryRef attributesToUpdate);
static OSStatus (*orig_SecItemDelete)(CFDictionaryRef query);
static SecAccessControlRef(*orig_SecAccessControlCreateWithFlags)(CFAllocatorRef allocator, CFTypeRef protection, SecAccessControlCreateFlags flags, CFErrorRef  _Nullable *error);

static SecAccessControlRef repl_SecAccessControlCreateWithFlags(CFAllocatorRef allocator, CFTypeRef protection, SecAccessControlCreateFlags flags, CFErrorRef  _Nullable *error)
{
	return orig_SecAccessControlCreateWithFlags(allocator, protection, flags, error);
}

static NSMutableDictionary *__query_to_delete_key(CFDictionaryRef query)
{
	NSDictionary *attrs = (__bridge NSDictionary *)query;

	NSData *acct = nil;
	NSString *agrp = nil;
	NSString *clss = nil;
	NSString *svce = nil;
	NSObject *sync = nil;

	for (NSString *key in attrs) {
		NSObject *obj = attrs[key];

		if ([key isEqualToString:@"acct"]) {
			acct = (NSData *)obj;
		} else if ([key isEqualToString:@"agrp"]) {
			agrp = (NSString *)obj;
		} else if ([key isEqualToString:@"class"]) {
			clss = (NSString *)obj;
		} else if ([key isEqualToString:@"svce"]) {
			svce = (NSString *)obj;
		} else if ([key isEqualToString:@"sync"]) {
			sync = obj;

		}
	}

	NSMutableDictionary *tbl = [NSMutableDictionary dictionary];
	if (acct) {
		tbl[@"acct"] = acct;
	}
	if (agrp) {
		tbl[@"agrp"] = agrp;
	}
	if (clss) {
		tbl[@"class"] = clss;
	}
	if (svce) {
		tbl[@"svce"] = svce;
	}
	if (sync) {
		tbl[@"sync"] = sync;
	}

	return tbl;
}

static NSMutableDictionary *__query_to_match_one_key(CFDictionaryRef query)
{
	NSDictionary *attrs = (__bridge NSDictionary *)query;

	NSData *acct = nil;
	NSString *agrp = nil;
	NSString *clss = nil;
	NSString *svce = nil;
	NSObject *sync = nil;

	for (NSString *key in attrs) {
		NSObject *obj = attrs[key];

		if ([key isEqualToString:@"acct"]) {
			acct = (NSData *)obj;
		} else if ([key isEqualToString:@"agrp"]) {
			agrp = (NSString *)obj;
		} else if ([key isEqualToString:@"class"]) {
			clss = (NSString *)obj;
		} else if ([key isEqualToString:@"svce"]) {
			svce = (NSString *)obj;
		} else if ([key isEqualToString:@"sync"]) {
			sync = obj;
		}
	}

	NSMutableDictionary *tbl = [NSMutableDictionary dictionary];
	if (acct) {
		tbl[@"acct"] = acct;
	}
	if (agrp) {
		tbl[@"agrp"] = agrp;
	}
	if (clss) {
		tbl[@"class"] = clss;
	}
	if (svce) {
		tbl[@"svce"] = svce;
	}
	if (sync) {
		tbl[@"sync"] = sync;
	}

	tbl[@"m_Limit"] = @"m_LimitOne";
	tbl[@"r_Attributes"] = @YES;
	tbl[@"r_Data"] =  @YES;

	return tbl;
}

static NSMutableDictionary *__query_to_match_all_key(CFDictionaryRef query)
{
	NSDictionary *attrs = (__bridge NSDictionary *)query;

	NSData *acct = nil;
	NSString *agrp = nil;
	NSString *clss = nil;
	NSString *svce = nil;
	NSObject *sync = nil;

	for (NSString *key in attrs) {
		NSObject *obj = attrs[key];

		if ([key isEqualToString:@"acct"]) {
			acct = (NSData *)obj;
		} else if ([key isEqualToString:@"agrp"]) {
			agrp = (NSString *)obj;
		} else if ([key isEqualToString:@"class"]) {
			clss = (NSString *)obj;
		} else if ([key isEqualToString:@"svce"]) {
			svce = (NSString *)obj;
		} else if ([key isEqualToString:@"sync"]) {
			sync = obj;
		}
	}

	NSMutableDictionary *tbl = [NSMutableDictionary dictionary];
	if (acct) {
		tbl[@"acct"] = acct;
	}
	if (agrp) {
		tbl[@"agrp"] = agrp;
	}
	if (clss) {
		tbl[@"class"] = clss;
	}
	if (svce) {
		tbl[@"svce"] = svce;
	}
	if (sync) {
		tbl[@"sync"] = sync;
	}

	tbl[@"m_Limit"] = @"m_LimitAll";
	tbl[@"r_Attributes"] = @YES;
	tbl[@"r_Data"] =  @YES;

	return tbl;
}

// static NSMutableData *__query_to_storage_key(CFDictionaryRef query)
// {
// 	NSDictionary *attrs = (__bridge NSDictionary *)query;

// 	NSString *agrp = nil;
// 	NSString *clss = nil;
// 	NSString *svce = nil;
// 	NSString *sync = nil;

// 	for (NSString *key in attrs) {
// 		id obj = attrs[key];

// 		if ([key isEqualToString:@"agrp"]) {
// 			agrp = (NSString *)obj;
// 		} else if ([key isEqualToString:@"class"]) {
// 			clss = (NSString *)obj;
// 		} else if ([key isEqualToString:@"svce"]) {
// 			svce = (NSString *)obj;
// 		} else if ([key isEqualToString:@"sync"]) {
// 			sync = [obj stringValue];
// 		}
// 	}

// 	NSMutableData *key = [[NSMutableData alloc]init]; 
// 	if (agrp) {
// 		[key appendData:[agrp dataUsingEncoding:NSUTF8StringEncoding]];
// 	}
// 	if (clss) {
// 		[key appendData:[clss dataUsingEncoding:NSUTF8StringEncoding]];
// 	}
// 	if (svce) {
// 		[key appendData:[svce dataUsingEncoding:NSUTF8StringEncoding]];
// 	}
// 	if (sync && [sync isEqualToString:@"1"]) {
// 		[key appendData:[sync dataUsingEncoding:NSUTF8StringEncoding]];
// 	}

// 	return key;
// }

static NSData *__query_to_acct(CFDictionaryRef query)
{
	NSDictionary *attrs = (__bridge NSDictionary *)query;

	NSData *acct = nil;

	for (NSString *key in attrs) {
		id obj = attrs[key];

		if ([key isEqualToString:@"acct"]) {
			if ([obj isKindOfClass:[NSString class]]) {
				NSMutableData *data = [[NSMutableData alloc]init];
				[data appendData:[obj dataUsingEncoding:NSUTF8StringEncoding]];
				acct = data;
			} else {
				acct = (NSData *)obj;
			}			
			break;
		}
	}

	return acct;
}

static NSString *__query_to_agrp(CFDictionaryRef query) 
{
	NSDictionary *attrs = (__bridge NSDictionary *)query;
	for (NSString *key in attrs) {
		id obj = attrs[key];

		if ([key isEqualToString:@"agrp"]) {
			return (NSString *)obj;
		}
	}
	return nil;
}

static NSString *__query_to_clss(CFDictionaryRef query) 
{
	NSDictionary *attrs = (__bridge NSDictionary *)query;
	for (NSString *key in attrs) {
		id obj = attrs[key];

		if ([key isEqualToString:@"class"]) {
			return (NSString *)obj;
		}
	}
	return nil;
}

static NSString *__query_to_svce(CFDictionaryRef query) 
{
	NSDictionary *attrs = (__bridge NSDictionary *)query;
	for (NSString *key in attrs) {
		id obj = attrs[key];

		if ([key isEqualToString:@"svce"]) {
			return (NSString *)obj;
		}
	}
	return nil;
}

static NSMutableData *__attributes_to_data(CFDictionaryRef attributes)
{
	NSMutableData *data = [[NSMutableData alloc]init];
	NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
	[archiver encodeObject:(__bridge NSDictionary *)attributes forKey: @"item"];
	[archiver finishEncoding];
	return data;
}

static NSMutableDictionary *__data_to_attributes(const char *value, const size_t len)
{
	NSData *data = [NSData dataWithBytes:value length:len];

	NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
	NSDictionary *temp = [unarchiver decodeObjectForKey:@"item"];
	[unarchiver finishDecoding];

	return [temp mutableCopy];
}

static OSStatus repl_SecItemAdd(CFDictionaryRef attributes, CFTypeRef  _Nullable *result)
{
	char *state = NULL;

	@try {
		@autoreleasepool {
			NSString *bundle = [NSBundle mainBundle].bundleIdentifier;
			if (bundle) {
				wiiauto_device_db_keychain_get_bundle_state([bundle UTF8String], &state);
			}
		}
	} @catch (NSException *e) {
		state = NULL;
	}

	// remote_log("------------------------\n\n");
	// if (attributes) {
	// 	NSString *ll = [NSString stringWithFormat:@"%@", (__bridge NSDictionary *)attributes];
	// 	remote_log("add_query: %s\n\n", [ll UTF8String]);
	// }

	if (state) {
		OSStatus rr = errSecUserCanceled;

		@autoreleasepool {
			@try {
				// VERSION -2
				CFTypeRef obj = nil;
				NSArray *rows = nil;

				rr = orig_SecItemAdd(attributes, result);

				NSMutableDictionary *tbl = __query_to_match_all_key(attributes);
				obj = NULL;
				orig_SecItemCopyMatching((__bridge CFDictionaryRef)tbl, &obj);
				if (obj) {
					rows = (__bridge_transfer NSArray *)obj;
				}

				NSData *acct = __query_to_acct(attributes);
				NSString *agrp = __query_to_agrp(attributes);
				NSString *clss = __query_to_clss(attributes);
				NSString *svce = __query_to_svce(attributes);

				if (rows) {
					// store keychain
					for (NSDictionary *attr in rows) {						
						NSMutableDictionary *temp = [[NSMutableDictionary alloc] initWithDictionary:attr];
						[temp removeObjectForKey:@"accc"];

						CFDictionaryRef aref = (__bridge CFDictionaryRef)temp;
						NSMutableData *data = __attributes_to_data(aref);
						// acct = __query_to_acct(aref);

						// remote_log("------------------------\n\n");
						// {
						// 	NSString *ll = [NSString stringWithFormat:@"%@", attr];
						// 	remote_log("add_real: %s\n\n", [ll UTF8String]);
						// }

						const char *bytes_acct = NULL;
						size_t bytes_acct_len = 0;
						const char *bytes_agrp = NULL;
						size_t bytes_agrp_len = 0;
						const char *bytes_clss = NULL;
						size_t bytes_clss_len = 0;
						const char *bytes_svce = NULL;
						size_t bytes_svce_len = 0;
						if (acct) {
							bytes_acct = [acct bytes];
							bytes_acct_len = [acct length];
						}
						if (agrp) {
							bytes_agrp = [agrp UTF8String];
							bytes_agrp_len = [agrp length];
						}
						if (clss) {
							bytes_clss = [clss UTF8String];
							bytes_clss_len = [clss length];
						}
						if (svce) {
							bytes_svce = [svce UTF8String];
							bytes_svce_len = [svce length];
						}
						wiiauto_device_db_keychain_set_value(state, 
							bytes_acct, bytes_acct_len, 
							bytes_agrp, bytes_agrp_len, 
							bytes_clss, bytes_clss_len, 
							0, 
							bytes_svce, bytes_svce_len, 							
							[data bytes], [data length]);

						// if (acct) {
						// 	acct_insert = acct;
						// 	wiiauto_device_db_keychain_set_value(state, [acct bytes], [acct length], [key bytes], [key length], [data bytes], [data length]);
						// } else {
						// 	wiiauto_device_db_keychain_set_value(state, NULL, 0, [key bytes], [key length], [data bytes], [data length]);
						// }

						// NSData *new_acct = __query_to_acct((__bridge CFDictionaryRef)attr);
								
						// if (new_acct) {
						// 	NSMutableDictionary *clone_attr = [(__bridge NSDictionary *)attributes mutableCopy];
						// 	// clone_attr[@"acct"] = new_acct;
							
						// 	NSMutableDictionary *dlkey = __query_to_delete_key((__bridge CFDictionaryRef)clone_attr);
						// 	orig_SecItemDelete((__bridge CFDictionaryRef)dlkey);
						// }
					}
				}
				NSMutableDictionary *dlkey = __query_to_delete_key(attributes);
				OSStatus dl = orig_SecItemDelete((__bridge CFDictionaryRef)dlkey);
	
				// VERSION-1
				// {
				// 	NSString *ll = [NSString stringWithFormat:@"%@", (__bridge NSDictionary *)attributes];
				// 	remote_log("orig_add: %s\n", [ll UTF8String]);
				// }
				// CFTypeRef obj = nil;
				// NSArray *rows = nil;
				// NSData *acct_insert = nil;

				// // add to keychain
				// rr = orig_SecItemAdd(attributes, result);

				// // get keychain rows
				// NSMutableDictionary *tbl = __query_to_match_all_key(attributes);

				// obj = NULL;
				// orig_SecItemCopyMatching((__bridge CFDictionaryRef)tbl, &obj);

				// if (obj) {
				// 	rows = (__bridge_transfer NSArray *)obj;
				// }

				// if (rows) {
				// 	// get storage key
				// 	NSMutableData *key = __query_to_storage_key(attributes);

				// 	// store keychain
				// 	for (NSDictionary *attr in rows) {						
				// 		NSMutableDictionary *temp = [[NSMutableDictionary alloc] initWithDictionary:attr];
				// 		[temp removeObjectForKey:@"accc"];

				// 		{
				// 			NSString *ll = [NSString stringWithFormat:@"%@", temp];
				// 			remote_log("orig_save: %s\n", [ll UTF8String]);
				// 		}
				// 		CFDictionaryRef aref = (__bridge CFDictionaryRef)temp;
				// 		NSMutableData *data = __attributes_to_data(aref);
				// 		NSData *acct = __query_to_acct(aref);
				// 		if (acct) {
				// 			acct_insert = acct;
				// 			wiiauto_device_db_keychain_set_value(state, [acct bytes], [acct length], [key bytes], [key length], [data bytes], [data length]);
				// 		} else {
				// 			wiiauto_device_db_keychain_set_value(state, NULL, 0, [key bytes], [key length], [data bytes], [data length]);
				// 		}

				// 		NSData *new_acct = __query_to_acct((__bridge CFDictionaryRef)attr);
								
				// 		if (new_acct) {
				// 			NSMutableDictionary *clone_attr = [(__bridge NSDictionary *)attributes mutableCopy];
				// 			// clone_attr[@"acct"] = new_acct;
							
				// 			NSMutableDictionary *dlkey = __query_to_delete_key((__bridge CFDictionaryRef)clone_attr);
				// 			orig_SecItemDelete((__bridge CFDictionaryRef)dlkey);
				// 		}
				// 	}

				// 	// delete original keychain
				// 	NSMutableDictionary *dlkey = __query_to_delete_key(attributes);
				// 	// {
				// 	// 	NSString *ll = [NSString stringWithFormat:@"%@", dlkey];
				// 	// 	remote_log("orig_save_delete: %s\n", [ll UTF8String]);
				// 	// }
				// 	OSStatus dl = orig_SecItemDelete((__bridge CFDictionaryRef)dlkey);
				// 	// remote_log("orig_save_delete_result: %d\n", dl);

				// 	// if (acct_insert) {
				// 	// 	__update_no_account_genp(state, acct_insert);
				// 	// }
				// }
			} @catch (NSException *e) {
				NSString *ser = [NSString stringWithFormat:@"%@", e];
				remote_log("error add: %s\n", [ser UTF8String]);
			}
		}
		free(state);
		return rr;
	}


	// remote_log("------------------------\n\n");
	// if (attributes) {
	// 	NSString *ll = [NSString stringWithFormat:@"%@", (__bridge NSDictionary *)attributes];
	// 	remote_log("add_query: %s\n\n", [ll UTF8String]);
	// }

	OSStatus ret = orig_SecItemAdd(attributes, result);

	// if (result && *result) {
	// 	{
	// 		NSString *ll = [NSString stringWithFormat:@"%@", *result];
	// 		remote_log("add_result: %s\n\n", [ll UTF8String]);
	// 	}
	// }

	return ret;
}

static OSStatus repl_SecItemCopyMatching(CFDictionaryRef query, CFTypeRef  _Nullable *result)
{
	char *state = NULL;

	@try {
		@autoreleasepool {
			NSString *bundle = [NSBundle mainBundle].bundleIdentifier;
			if (bundle) {
				wiiauto_device_db_keychain_get_bundle_state([bundle UTF8String], &state);
			}
		}
	} @catch (NSException *e) {
		state = NULL;
	}

	// remote_log("------------------------\n\n");
	// if (query) {
	// 	NSString *ll = [NSString stringWithFormat:@"%@", (__bridge NSDictionary *)query];
	// 	remote_log("match_query: %s\n\n", [ll UTF8String]);
	// }

	if (state) {
		OSStatus result_status = errSecItemNotFound;
		*result = nil;

		@autoreleasepool {
			@try {
				// VERSION-2
				char *value = NULL;
				size_t value_len = 0;
				int export_data = 0;
				int export_attributes = 0;
				int i = 0;

				CFBooleanRef secReturnData = CFDictionaryGetValue(query, kSecReturnData);
				if(NULL != secReturnData && kCFBooleanTrue == secReturnData) {
					export_data = 1;
				}
				
				CFBooleanRef secReturnAttributes = CFDictionaryGetValue(query, kSecReturnAttributes);
				if(NULL != secReturnAttributes && kCFBooleanTrue == secReturnAttributes) {
					export_attributes = 1;
				}

				NSData *acct = __query_to_acct(query);
				NSString *agrp = __query_to_agrp(query);
				NSString *clss = __query_to_clss(query);
				NSString *svce = __query_to_svce(query);

				const char *bytes_acct = NULL;
				size_t bytes_acct_len = 0;
				const char *bytes_agrp = NULL;
				size_t bytes_agrp_len = 0;
				const char *bytes_clss = NULL;
				size_t bytes_clss_len = 0;
				const char *bytes_svce = NULL;
				size_t bytes_svce_len = 0;
				if (acct) {
					bytes_acct = [acct bytes];
					bytes_acct_len = [acct length];
				}
				if (agrp) {
					bytes_agrp = [agrp UTF8String];
					bytes_agrp_len = [agrp length];
				}
				if (clss) {
					bytes_clss = [clss UTF8String];
					bytes_clss_len = [clss length];
				}
				if (svce) {
					bytes_svce = [svce UTF8String];
					bytes_svce_len = [svce length];
				}

				CFStringRef secMatchLimit = CFDictionaryGetValue(query, kSecMatchLimit);
				if(NULL != secMatchLimit && kSecMatchLimitOne == secMatchLimit) {
					
					wiiauto_device_db_keychain_get_value(state, 
						bytes_acct, bytes_acct_len,
						bytes_agrp, bytes_agrp_len,
						bytes_clss, bytes_clss_len,
						0,
						bytes_svce, bytes_svce_len,
						&value, &value_len,
						0);

					if (value) {
						NSMutableDictionary *data = __data_to_attributes(value, value_len);						
						if (export_data == 0) {
							[data removeObjectForKey:@"v_Data"];
						}
						free(value);

						NSDictionary *dict = [NSDictionary dictionaryWithDictionary:data];

						// if (query) {
						// 	NSString *ll = [NSString stringWithFormat:@"%@", dict];
						// 	remote_log("match_result: %s\n\n", [ll UTF8String]);
						// }

						*result = (__bridge CFTypeRef)dict;
						CFRetain(*result);
						result_status = errSecSuccess;
					}

				} else if(NULL != secMatchLimit && kSecMatchLimitAll == secMatchLimit) {
					
					NSMutableArray *arr = [NSMutableArray array];

					i = 0;
					while (i >= 0) {
						wiiauto_device_db_keychain_get_value(state, 
							bytes_acct, bytes_acct_len,
							bytes_agrp, bytes_agrp_len,
							bytes_clss, bytes_clss_len,
							0,
							bytes_svce, bytes_svce_len,
							&value, &value_len,
							i);
						if (value == NULL) break;

						NSMutableDictionary *data = __data_to_attributes(value, value_len);
						if (export_data == 0) {
							[data removeObjectForKey:@"v_Data"];
						}

						NSDictionary *dict = [NSDictionary dictionaryWithDictionary:data];
						[arr addObject:dict];
						free(value);
						i++;
					}
					if ([arr count] > 0) {
						// if (query) {
						// 	NSString *ll = [NSString stringWithFormat:@"%@", arr];
						// 	remote_log("match_result: %s\n\n", [ll UTF8String]);
						// }

						*result = (__bridge CFTypeRef)arr;
						CFRetain(*result);
						result_status = errSecSuccess;
					}

				} 


				// VERSION-1
				// remote_log("match_1\n");

				// char *value = NULL;
				// size_t value_len = 0;
				// int export_data = 0;
				// int export_attributes = 0;
				// int i = 0;

				// CFBooleanRef secReturnData = CFDictionaryGetValue(query, kSecReturnData);
				// if(NULL != secReturnData && kCFBooleanTrue == secReturnData) {
				// 	export_data = 1;
				// }
				
				// CFBooleanRef secReturnAttributes = CFDictionaryGetValue(query, kSecReturnAttributes);
				// if(NULL != secReturnAttributes && kCFBooleanTrue == secReturnAttributes) {
				// 	export_attributes = 1;
				// }

				// NSMutableData *key = __query_to_storage_key(query);
				// NSData *acct = __query_to_acct(query);

				// CFStringRef secMatchLimit = CFDictionaryGetValue(query, kSecMatchLimit);
				// if(NULL != secMatchLimit && kSecMatchLimitOne == secMatchLimit) {

				// 	if (acct) {
				// 		wiiauto_device_db_keychain_get_value(state, [acct bytes], [acct length], [key bytes], [key length], &value, &value_len, 0);
				// 	} else {
				// 		wiiauto_device_db_keychain_get_value(state, NULL, 0, [key bytes], [key length], &value, &value_len, 0);
				// 	}

				// 	if (value) {
				// 		NSMutableDictionary *data = __data_to_attributes(value, value_len);						
				// 		if (export_data == 0) {
				// 			[data removeObjectForKey:@"v_Data"];
				// 		}
				// 		free(value);

				// 		NSDictionary *dict = [NSDictionary dictionaryWithDictionary:data];

				// 		*result = (__bridge CFTypeRef)dict;
				// 		CFRetain(*result);
				// 		result_status = errSecSuccess;
				// 	}

				// } else if(NULL != secMatchLimit && kSecMatchLimitAll == secMatchLimit) {
					
				// 	NSMutableArray *arr = [NSMutableArray array];

				// 	i = 0;
				// 	while (i >= 0) {
				// 		if (acct) {
				// 			wiiauto_device_db_keychain_get_value(state, [acct bytes], [acct length], [key bytes], [key length], &value, &value_len, i);
				// 		} else {
				// 			wiiauto_device_db_keychain_get_value(state, NULL, 0, [key bytes], [key length], &value, &value_len, i);
				// 		}
				// 		if (value == NULL) break;

				// 		NSMutableDictionary *data = __data_to_attributes(value, value_len);
				// 		if (export_data == 0) {
				// 			[data removeObjectForKey:@"v_Data"];
				// 		}

				// 		NSDictionary *dict = [NSDictionary dictionaryWithDictionary:data];
				// 		[arr addObject:dict];
				// 		free(value);
				// 		i++;
				// 	}
				// 	if ([arr count] > 0) {
				// 		*result = (__bridge CFTypeRef)arr;
				// 		CFRetain(*result);
				// 		result_status = errSecSuccess;
				// 	}

				// } 
			} @catch (NSException *e) {
				NSString *ser = [NSString stringWithFormat:@"%@", e];
				remote_log("error match: %s\n", [ser UTF8String]);
			}
		}

		free(state);
		return result_status;	
	}
	// remote_log("------------------------\n\n");
	// if (query) {
	// 	NSString *ll = [NSString stringWithFormat:@"%@", (__bridge NSDictionary *)query];
	// 	remote_log("match_query: %s\n\n", [ll UTF8String]);
	// }

	OSStatus rr = orig_SecItemCopyMatching(query, result);

	// if (result && *result) {
	// 	NSString *ll = [NSString stringWithFormat:@"%@", *result];
	// 	remote_log("match_result: %s\n\n", [ll UTF8String]);
	// }

	return rr;
}

static OSStatus repl_SecItemUpdate(CFDictionaryRef query, CFDictionaryRef attributesToUpdate)
{
	char *state = NULL;

	@try {
		@autoreleasepool {
			NSString *bundle = [NSBundle mainBundle].bundleIdentifier;
			if (bundle) {
				wiiauto_device_db_keychain_get_bundle_state([bundle UTF8String], &state);
			}
		}
	} @catch (NSException *e) {
		state = NULL;
	}

	// remote_log("------------------------\n\n");
	// if (query) {
	// 	NSString *ll = [NSString stringWithFormat:@"%@", (__bridge NSDictionary *)query];
	// 	remote_log("update_query: %s\n\n", [ll UTF8String]);
	// }
	// if (attributesToUpdate) {
	// 	NSString *ll = [NSString stringWithFormat:@"%@", (__bridge NSDictionary *)attributesToUpdate];
	// 	remote_log("update_alter: %s\n\n", [ll UTF8String]);
	// }

	if (state) {
		OSStatus rr = errSecItemNotFound;

		@autoreleasepool {
			@try {	
				// VERSION-2
				NSDictionary *attrs_to_update = (__bridge NSDictionary *)attributesToUpdate;

				NSData *acct = __query_to_acct(query);
				if (!acct) {
					acct = __query_to_acct(attributesToUpdate);
				}

				NSString *agrp = __query_to_agrp(query);
				if (!agrp) {
					agrp = __query_to_agrp(attributesToUpdate);
				}
				NSString *clss = __query_to_clss(query);
				if (!clss) {
					clss = __query_to_clss(attributesToUpdate);
				}
				NSString *svce = __query_to_svce(query);
				if (!svce) {
					svce = __query_to_svce(attributesToUpdate);
				}

				const char *bytes_acct = NULL;
				size_t bytes_acct_len = 0;
				const char *bytes_agrp = NULL;
				size_t bytes_agrp_len = 0;
				const char *bytes_clss = NULL;
				size_t bytes_clss_len = 0;
				const char *bytes_svce = NULL;
				size_t bytes_svce_len = 0;
				if (acct) {
					bytes_acct = [acct bytes];
					bytes_acct_len = [acct length];
				}
				if (agrp) {
					bytes_agrp = [agrp UTF8String];
					bytes_agrp_len = [agrp length];
				}
				if (clss) {
					bytes_clss = [clss UTF8String];
					bytes_clss_len = [clss length];
				}
				if (svce) {
					bytes_svce = [svce UTF8String];
					bytes_svce_len = [svce length];
				}

				NSMutableArray *rows_to_add = [NSMutableArray array];

				unsigned int index = 0;
				while (index >= 0) {
					char *value = NULL;
					size_t value_len = 0;

					wiiauto_device_db_keychain_get_value(state, 
							bytes_acct, bytes_acct_len,
							bytes_agrp, bytes_agrp_len,
							bytes_clss, bytes_clss_len,
							0,
							bytes_svce, bytes_svce_len,
							&value, &value_len,
							index);
					if (value == NULL) break;

					NSMutableDictionary *attributes = __data_to_attributes(value, value_len);
					for (NSString *k in attrs_to_update) {
						attributes[k] = attrs_to_update[k];
					}
					[attributes removeObjectForKey:@"accc"];
					if (clss) {
						attributes[@"class"] = clss;
					}					
					if (acct) {
						attributes[@"acct"] = acct;
					}

					// add new query
					NSMutableDictionary *new_query = [NSMutableDictionary dictionary];
					if (acct) {
						new_query[@"acct"] = acct;
					}
					if (agrp) {
						new_query[@"agrp"] = agrp;
					}
					if (clss) {
						new_query[@"class"] = clss;
					}
					if (svce) {
						new_query[@"svce"] = svce;
					}
					for (NSString *k in attributes) {
						id obj = attributes[k];
						if ([k isEqualToString:@"agrp"]
							|| [k isEqualToString:@"class"]
							|| [k isEqualToString:@"svce"]
							|| [k isEqualToString:@"v_Data"]
							|| [k isEqualToString:@"pdmn"]
							|| [k isEqualToString:@"gena"]) {
							new_query[k] = obj;
						}
					}

					{
						CFTypeRef obj = nil;
						orig_SecItemAdd((__bridge CFDictionaryRef)new_query, &obj);
						if (obj) {
							CFRelease(obj);
						}
					}	

						// get keychain rows
					{
						CFTypeRef obj = nil;
						NSArray *rows = nil;

						NSMutableDictionary *tbl = __query_to_match_all_key((__bridge CFDictionaryRef)attributes);

						obj = NULL;
						orig_SecItemCopyMatching((__bridge CFDictionaryRef)tbl, &obj);

						if (obj) {
							rows = (__bridge_transfer NSArray *)obj;
						}

						if (rows) {
							for (NSDictionary *attr in rows) {
								NSMutableDictionary *ar = [NSMutableDictionary dictionary];
								ar[@"from_attr"] = attributes;
								ar[@"to_attr"] = attr;
								[rows_to_add addObject:ar];
							}

							// delete original keychain
							NSMutableDictionary *dlkey = __query_to_delete_key((__bridge CFDictionaryRef)attributes);
							orig_SecItemDelete((__bridge CFDictionaryRef)dlkey);
						}

					}
					
					free(value);
					index++;
				}

				for (NSDictionary *ar in rows_to_add) {	
					rr = errSecSuccess;

					NSDictionary *attributes = ar[@"from_attr"];
					NSDictionary *attr = ar[@"to_attr"];

					NSData *acct = __query_to_acct((__bridge CFDictionaryRef)attributes);
					if (!acct) {
						acct = __query_to_acct((__bridge CFDictionaryRef)attr);
					}

					NSString *agrp = __query_to_agrp((__bridge CFDictionaryRef)attributes);
					if (!agrp) {
						agrp = __query_to_agrp((__bridge CFDictionaryRef)attr);
					}
					NSString *clss = __query_to_clss((__bridge CFDictionaryRef)attributes);
					if (!clss) {
						clss = __query_to_clss((__bridge CFDictionaryRef)attr);
					}
					NSString *svce = __query_to_svce((__bridge CFDictionaryRef)attributes);
					if (!svce) {
						svce = __query_to_svce((__bridge CFDictionaryRef)attr);
					}

					const char *bytes_acct = NULL;
					size_t bytes_acct_len = 0;
					const char *bytes_agrp = NULL;
					size_t bytes_agrp_len = 0;
					const char *bytes_clss = NULL;
					size_t bytes_clss_len = 0;
					const char *bytes_svce = NULL;
					size_t bytes_svce_len = 0;
					if (acct) {
						bytes_acct = [acct bytes];
						bytes_acct_len = [acct length];
					}
					if (agrp) {
						bytes_agrp = [agrp UTF8String];
						bytes_agrp_len = [agrp length];
					}
					if (clss) {
						bytes_clss = [clss UTF8String];
						bytes_clss_len = [clss length];
					}
					if (svce) {
						bytes_svce = [svce UTF8String];
						bytes_svce_len = [svce length];
					}

					NSMutableDictionary *temp = [[NSMutableDictionary alloc] initWithDictionary:attr];
					[temp removeObjectForKey:@"accc"];

					CFDictionaryRef aref = (__bridge CFDictionaryRef)temp;
					NSMutableData *data = __attributes_to_data(aref);

					wiiauto_device_db_keychain_set_value(state,
						bytes_acct, bytes_acct_len,
						bytes_agrp, bytes_agrp_len,
						bytes_clss, bytes_clss_len,
						0,
						bytes_svce, bytes_svce_len,
						[data bytes], [data length]);

					NSMutableDictionary *dlkey = __query_to_delete_key((__bridge CFDictionaryRef)attributes);
					orig_SecItemDelete((__bridge CFDictionaryRef)dlkey);
				}

				// VERSION-1
				// // remote_log("update: 1\n");
				// NSDictionary *attrs_to_update = (__bridge NSDictionary *)attributesToUpdate;

				// NSData *acct = __query_to_acct(query);
				// NSData *first_acct = acct;
				// NSMutableData *key = __query_to_storage_key(query);

				// if (__query_to_acct(attributesToUpdate)) {
				// 	acct = __query_to_acct(attributesToUpdate);
				// }
				// int row_has_acc = 0;
				// if (acct) {
				// 	row_has_acc = 1;
				// }

				// // if (acct) {
				// // 	__update_no_account_genp(state, acct);
				// // }

				// NSMutableArray *rows_to_add = [NSMutableArray array];

				// unsigned int index = 0;
				// while (index >= 0) {
				// 	char *value = NULL;
				// 	size_t len = 0;

				// 	if (acct) {
				// 		wiiauto_device_db_keychain_get_value(state, [acct bytes], [acct length], [key bytes], [key length], &value, &len, index);
				// 		if (value == NULL && first_acct == nil) {
				// 			wiiauto_device_db_keychain_get_value(state, NULL, 0, [key bytes], [key length], &value, &len, index);
				// 		}
				// 	} else {
				// 		wiiauto_device_db_keychain_get_value(state, NULL, 0, [key bytes], [key length], &value, &len, index);
				// 	}

				// 	if (value == NULL) break;

				// 	NSMutableDictionary *attributes = __data_to_attributes(value, len);
				// 	for (NSString *k in attrs_to_update) {
				// 		attributes[k] = attrs_to_update[k];
				// 	}
				// 	[attributes removeObjectForKey:@"accc"];
				// 	{
				// 		NSString *ll = [NSString stringWithFormat:@"%@", attributes];
				// 		remote_log("pre_update-%d: %s\n", index, [ll UTF8String]);
				// 	}
				// 	attributes[@"class"] = @"genp";

				// 	// add new query
				// 	NSMutableDictionary *new_query = [NSMutableDictionary dictionary];
				// 	if (acct) {
				// 		new_query[@"acct"] = acct;
				// 		attributes[@"acct"] = acct;
				// 	}
				// 	for (NSString *k in attributes) {
				// 		id obj = attributes[k];
				// 		if ([k isEqualToString:@"agrp"]
				// 			|| [k isEqualToString:@"class"]
				// 			|| [k isEqualToString:@"svce"]
				// 			|| [k isEqualToString:@"v_Data"]
				// 			|| [k isEqualToString:@"pdmn"]
				// 			|| [k isEqualToString:@"gena"]) {
				// 			new_query[k] = obj;
				// 		}
				// 	}
				// 	{
				// 		NSString *ll = [NSString stringWithFormat:@"%@",new_query];
				// 		remote_log("update_add: %s\n", [ll UTF8String]);
				// 	}

				// 	{
				// 		CFTypeRef obj = nil;
				// 		orig_SecItemAdd((__bridge CFDictionaryRef)new_query, &obj);
				// 		if (obj) {
				// 			CFRelease(obj);
				// 		}
				// 	}					

				// 	// get keychain rows
				// 	{
				// 		CFTypeRef obj = nil;
				// 		NSArray *rows = nil;

				// 		NSMutableDictionary *tbl = __query_to_match_all_key((__bridge CFDictionaryRef)attributes);

				// 		obj = NULL;
				// 		orig_SecItemCopyMatching((__bridge CFDictionaryRef)tbl, &obj);

				// 		if (obj) {
				// 			rows = (__bridge_transfer NSArray *)obj;
				// 		}

				// 		if (rows) {
				// 			remote_log("has_row\n");
				// 			// get storage key
				// 			// NSMutableData *key = __query_to_storage_key((__bridge CFDictionaryRef)attributes);

				// 			// store keychain
				// 			for (NSDictionary *attr in rows) {
				// 				NSMutableDictionary *ar = [NSMutableDictionary dictionary];
				// 				ar[@"from_attr"] = attributes;
				// 				ar[@"to_attr"] = attr;
				// 				[rows_to_add addObject:ar];

				// 				{
				// 					NSString *ll = [NSString stringWithFormat:@"%@",attr];
				// 					remote_log("update_after: %s\n", [ll UTF8String]);
				// 				}

				// 				// NSMutableDictionary *temp = [[NSMutableDictionary alloc] initWithDictionary:attr];
				// 				// [temp removeObjectForKey:@"accc"];

				// 				// CFDictionaryRef aref = (__bridge CFDictionaryRef)temp;
				// 				// NSMutableData *data = __attributes_to_data(aref);
				// 				// NSData *acct_ref = __query_to_acct(aref);
				// 				// if (acct_ref) {
				// 				// 	wiiauto_device_db_keychain_set_value(state, [acct_ref bytes], [acct_ref length], [key bytes], [key length], [data bytes], [data length]);
				// 				// } else {
				// 				// 	wiiauto_device_db_keychain_set_value(state, NULL, 0, [key bytes], [key length], [data bytes], [data length]);
				// 				// }

				// 				NSData *new_acct = __query_to_acct((__bridge CFDictionaryRef)attr);
				// 				if (new_acct) {
				// 					row_has_acc = 1;
				// 				}
								
				// 				if (new_acct) {
				// 					NSMutableDictionary *clone_attr = [attributes mutableCopy];
				// 					// clone_attr[@"acct"] = new_acct;
				// 					NSMutableDictionary *dlkey = __query_to_delete_key((__bridge CFDictionaryRef)clone_attr);
				// 					orig_SecItemDelete((__bridge CFDictionaryRef)dlkey);
				// 				}
				// 			}

				// 			// delete original keychain
				// 			NSMutableDictionary *dlkey = __query_to_delete_key((__bridge CFDictionaryRef)attributes);
				// 			orig_SecItemDelete((__bridge CFDictionaryRef)dlkey);
				// 		}

				// 	}

				// 	free(value);
				// 	index++;
				// }

				// for (NSDictionary *ar in rows_to_add) {	
				// 	NSDictionary *attributes = ar[@"from_attr"];
				// 	NSDictionary *attr = ar[@"to_attr"];

				// 	NSMutableData *key = __query_to_storage_key((__bridge CFDictionaryRef)attributes);

				// 	NSMutableDictionary *temp = [[NSMutableDictionary alloc] initWithDictionary:attr];
				// 	[temp removeObjectForKey:@"accc"];

				// 	CFDictionaryRef aref = (__bridge CFDictionaryRef)temp;
				// 	NSMutableData *data = __attributes_to_data(aref);
				// 	NSData *acct_ref = __query_to_acct(aref);
				// 	if (acct_ref) {
				// 		wiiauto_device_db_keychain_set_value(state, [acct_ref bytes], [acct_ref length], [key bytes], [key length], [data bytes], [data length]);
				// 	} else {
				// 		wiiauto_device_db_keychain_set_value(state, NULL, 0, [key bytes], [key length], [data bytes], [data length]);
				// 	}

				// 	NSData *new_acct = __query_to_acct((__bridge CFDictionaryRef)attr);
					
				// 	if (new_acct) {
				// 		NSMutableDictionary *clone_attr = [attributes mutableCopy];
				// 		// clone_attr[@"acct"] = new_acct;
				// 		NSMutableDictionary *dlkey = __query_to_delete_key((__bridge CFDictionaryRef)clone_attr);
				// 		orig_SecItemDelete((__bridge CFDictionaryRef)dlkey);
				// 	}
				// }

			} @catch (NSException *e) {
				NSString *ser = [NSString stringWithFormat:@"%@", e];
				remote_log("error update: %s\n", [ser UTF8String]);
			}
		}
		free(state);
		return rr;
	}

	return orig_SecItemUpdate(query, attributesToUpdate);
}

static OSStatus repl_SecItemDelete(CFDictionaryRef query)
{
	char *state = NULL;

	@try {
		@autoreleasepool {
			NSString *bundle = [NSBundle mainBundle].bundleIdentifier;
			if (bundle) {
				wiiauto_device_db_keychain_get_bundle_state([bundle UTF8String], &state);
			}
		}
	} @catch (NSException *e) {
		state = NULL;
	}

	if (state) {
		OSStatus rr = errSecItemNotFound;

		@autoreleasepool {
			@try {
				NSData *acct = __query_to_acct(query);
				NSString *agrp = __query_to_agrp(query);
				NSString *clss = __query_to_clss(query);
				NSString *svce = __query_to_svce(query);

				const char *bytes_acct = NULL;
				size_t bytes_acct_len = 0;
				const char *bytes_agrp = NULL;
				size_t bytes_agrp_len = 0;
				const char *bytes_clss = NULL;
				size_t bytes_clss_len = 0;
				const char *bytes_svce = NULL;
				size_t bytes_svce_len = 0;
				if (acct) {
					bytes_acct = [acct bytes];
					bytes_acct_len = [acct length];
				}
				if (agrp) {
					bytes_agrp = [agrp UTF8String];
					bytes_agrp_len = [agrp length];
				}
				if (clss) {
					bytes_clss = [clss UTF8String];
					bytes_clss_len = [clss length];
				}
				if (svce) {
					bytes_svce = [svce UTF8String];
					bytes_svce_len = [svce length];
				}

				char *value;
				size_t value_len;

				wiiauto_device_db_keychain_get_value(state,
					bytes_acct, bytes_acct_len,
					bytes_agrp, bytes_agrp_len,
					bytes_clss, bytes_clss_len,
					0,
					bytes_svce, bytes_svce_len,
					&value, &value_len, 0);
				
				if (value) {
					free(value);
					rr = errSecSuccess;
				}

				wiiauto_device_db_keychain_set_value(state,
					bytes_acct, bytes_acct_len,
					bytes_agrp, bytes_agrp_len,
					bytes_clss, bytes_clss_len,
					0,
					bytes_svce, bytes_svce_len,
					NULL, 0);

				// if (query) {
				// 	NSString *ll = [NSString stringWithFormat:@"%@", (__bridge NSDictionary *)query];
				// 	remote_log("delete_query: %s\n\n", [ll UTF8String]);
				// }
			} @catch (NSException *e) {
				NSString *ser = [NSString stringWithFormat:@"%@", e];
				remote_log("error delete: %s\n", [ser UTF8String]);
			}
		}
		free(state);
		return rr;
	}
	// remote_log("------------------------\n\n");
	// if (query) {
	// 	NSString *ll = [NSString stringWithFormat:@"%@", (__bridge NSDictionary *)query];
	// 	remote_log("delete_query: %s\n\n", [ll UTF8String]);
	// }
	return orig_SecItemDelete(query);
}

// uname
static int(*orig_uname)(struct utsname *);
static int repl_uname(struct utsname *s)
{
	int r =  orig_uname(s);
	// NSString *pt = wiiauto_device_get_pref(@"ProductType");

	NSString *bundle = [NSBundle mainBundle].bundleIdentifier;
	NSString *pt = nil;

	if (bundle) {
		const char *s = wiiauto_device_db_get([bundle UTF8String], "ProductType");
		if (s) {
			pt = [NSString stringWithUTF8String:s];
			free(s);
			bundle = nil;
		}
		bundle = nil;
	}

	if (pt) {
		strcpy(s->machine, [pt UTF8String]);	
		pt = nil;
	}
	return r;
}

/*
 * spoof
 */
typedef unsigned long long addr_t;

static addr_t step64(const uint8_t *buf, addr_t start, size_t length, uint32_t what, uint32_t mask) {
	addr_t end = start + length;
	while (start < end) {
		uint32_t x = *(uint32_t *)(buf + start);
		if ((x & mask) == what) {
			return start;
		}
		start += 4;
	}
	return 0;
}

// Modified version of find_call64(), replaced what/mask arguments in the function to the ones for branch instruction (0x14000000, 0xFC000000)
static addr_t find_branch64(const uint8_t *buf, addr_t start, size_t length) {
	return step64(buf, start, length, 0x14000000, 0xFC000000);
}

static addr_t follow_branch64(const uint8_t *buf, addr_t branch) {
	long long w;
	w = *(uint32_t *)(buf + branch) & 0x3FFFFFF;
	w <<= 64 - 26;
	w >>= 64 - 26 - 2;
	return branch + w;
}

// static NSString *NG_searnalNumber = @"DX3RXDY6K2XJ";
// static NSString *NG_searnalNumber = nil;

static bool __change_info__ = false;

static NSString *NG_searnalNumber = @"FCFQC4PGG5QF";
static NSString *NG_IMEI = @"356604081420977";
static NSString *NG_MEID = @"35660408142097";

// static NSString *NG_searnalNumber = @"DX3RXDYEH2XJ";


// unsigned char __chip_id[8] = "\x26\x82\x7B\x00\x18\x30\x0C\x00";
unsigned char __chip_id[8] = "\x78\x7F\x9C\xAB\xF6\x04\x00\x00";
static NSData *__chip_data__ = nil;

static NSData *__get_unique_chip_id()
{
	if (!__chip_data__) {
		__chip_data__ = [NSData dataWithBytes:__chip_id length:8];
	}
	return __chip_data__;
}

// unsigned char __wifi_mac_addr[6] = "\x4C\x57\xCA\x19\xC5\xC1";
// unsigned char __bluetooth_mac_addr[6] = "\x4C\x57\xCA\x19\xC5\xC2";
unsigned char __wifi_mac_addr[6] = "\x98\x9E\x63\x94\x94\x5B";
unsigned char __bluetooth_mac_addr[6] = "\x98\x9E\x63\x94\x94\x5C";

static NSString *NG_bluetooth_mac_addr = @"98:9e:63:94:94:5c";
static NSString *NG_wifi_mac_addr = @"98:9e:63:94:94:5b";

static NSData *__wifi_mac_data = nil;
static NSData *__bluetooth_mac_data = nil;

static NSData *__get_wifi_mac_data()
{
	if (!__wifi_mac_data) {
		__wifi_mac_data = [NSData dataWithBytes:__wifi_mac_addr length:6];
	}
	return __wifi_mac_data;
}

static NSData *__get_bluetooth_mac_data()
{
	if (!__bluetooth_mac_data) {
		__bluetooth_mac_data = [NSData dataWithBytes:__bluetooth_mac_addr length:6];
	}
	return __bluetooth_mac_data;
}



static CFPropertyListRef (*orig_MGCopyMultipleAnswers)(CFArrayRef questions, int __unknown0);

static CFPropertyListRef new_MGCopyMultipleAnswers(CFArrayRef questions, int __unknown0)
{
	return orig_MGCopyMultipleAnswers(questions, __unknown0);
}

static CFPropertyListRef (*orig_MGCopyAnswer_internal)(CFStringRef property, uint32_t *outTypeCode);
static CFPropertyListRef new_MGCopyAnswer_internal(CFStringRef property, uint32_t *outTypeCode) {

	CFPropertyListRef ref = orig_MGCopyAnswer_internal(property, outTypeCode);

	// if (!__change_info__) {
	// 	return ref;
	// }

	// {
	// 	NSString *ret = (__bridge NSString *)property;
	// 	const char *contentp = [ret UTF8String];

	// 	if (ref) {
	// 		int tid = CFGetTypeID(ref);
	// 		CFStringRef sref = CFCopyTypeIDDescription(tid);
	// 		if (sref) {
	// 			NSString *r = (__bridge NSString *)sref;
	// 			const char *content = [r UTF8String];
	// 			remote_log("MGCA_READ: %s | %s\n", contentp, content);
	// 		}
	// 	} else {
	// 		remote_log("MGCA_READ: %s\n", contentp);
	// 	}
	// }

	// @try {
	// 	if (CFEqual(property, CFSTR("InternationalMobileEquipmentIdentity"))
	// 		|| CFEqual(property, CFSTR("QZgogo2DypSAZfkRW4dP/A"))
	// 		|| CFEqual(property, CFSTR("xRyzf9zFE/ycr/wJPweZvQ"))
	// 		|| CFEqual(property, CFSTR("InternationalMobileEquipmentIdentity2"))) {
	// 		if (NG_IMEI) return (__bridge CFStringRef)NG_IMEI;
	// 	}

	// } @catch (NSException *e) {}

	// @try {

	// 	if (CFEqual(property, CFSTR("MobileEquipmentIdentifier"))
	// 		|| CFEqual(property, CFSTR("xOEH0P1H/1jmYe2t54+5cQ"))) {
	// 		if(NG_MEID) return (__bridge CFStringRef) NG_MEID;
	// 	}

	// } @catch (NSException *e) {}



	// @try {

	// 	if (CFEqual(property, CFSTR("k5lVWbXuiZHLA17KGiVUAA"))
	// 		|| CFEqual(property, CFSTR("BluetoothAddress"))
	// 		|| CFEqual(property, CFSTR("jSDzacs4RYWnWxn142UBLQ"))
	// 		|| CFEqual(property, CFSTR("BluetoothAddressData"))) {

	// 		int tid = CFGetTypeID(ref);
	// 		if (tid == CFDataGetTypeID()) {

	// 			NSData *d = (__bridge NSData *)ref;
	// 			unsigned char *p = (unsigned char *) [d bytes];
	// 			if ([d length] > 0) {
	// 				p[0] = __bluetooth_mac_addr[0];
	// 				p[1] = __bluetooth_mac_addr[1];
	// 				p[2] = __bluetooth_mac_addr[2];
	// 				p[3] = __bluetooth_mac_addr[3];
	// 				p[4] = __bluetooth_mac_addr[4];
	// 				p[5] = __bluetooth_mac_addr[5];			
	// 			}
	// 			return ref;
	// 		} else {
	// 			if (ref) {
	// 				NSString *r = (__bridge NSString *)ref;
	// 				const char *content = [r UTF8String];
	// 				remote_log("bluetooth-string: %s\n", content);
	// 			}
	// 			return (__bridge CFStringRef) NG_bluetooth_mac_addr;
	// 		}
	// 	}

	// } @catch (NSException *e) {}

	// @try {

	// 	if (	CFEqual(property, CFSTR("eZS2J+wspyGxqNYZeZ/sbA"))
	// 		|| 	CFEqual(property, CFSTR("WifiAddressData"))
	// 		|| 	CFEqual(property, CFSTR("gI6iODv8MZuiP0IA+efJCw"))
	// 		|| 	CFEqual(property, CFSTR("WifiAddress"))) {

	// 		int tid = CFGetTypeID(ref);
	// 		if (tid == CFDataGetTypeID()) {

	// 			NSData *d = (__bridge NSData *)ref;
	// 			unsigned char *p = (unsigned char *) [d bytes];
	// 			if ([d length] > 0) {
	// 				p[0] = __wifi_mac_addr[0];
	// 				p[1] = __wifi_mac_addr[1];
	// 				p[2] = __wifi_mac_addr[2];
	// 				p[3] = __wifi_mac_addr[3];
	// 				p[4] = __wifi_mac_addr[4];
	// 				p[5] = __wifi_mac_addr[5];			
	// 			}
	// 			return ref;
	// 		} else {
	// 			if (ref) {
	// 				NSString *r = (__bridge NSString *)ref;
	// 				const char *content = [r UTF8String];
	// 				remote_log("wifi-string: %s\n", content);
	// 			}
	// 			return (__bridge CFStringRef)NG_wifi_mac_addr;
	// 		}
	// 	}

	// } @catch (NSException *e) {}

	@try {
		
		if(CFEqual(property, CFSTR("VasUgeSzVyHdB27g2XpN0g"))
		 || CFEqual(property, CFSTR("SerialNumber"))){

			const char *value = wiiauto_device_db_get_share("system", "serialnumber");
			if (value) {
				NSString *seri = [NSString stringWithUTF8String:value];
				free(value);
				return CFBridgingRetain(seri);
			}

			// if(NG_searnalNumber){
			// 	return (__bridge CFStringRef)NG_searnalNumber;
			// }
		}

		if( CFEqual(property,CFSTR("UniqueDeviceID"))
			|| CFEqual(property, CFSTR("re6Zb+zwFKJNlkQTUeT+/w")) ){

			@try {
				NSString *ss = (__bridge NSString *)ref;
				const char *content = [ss UTF8String];
				remote_log("original_UUID: %s\n", content);
			} @catch (NSException *e) {}

			// NSString *bundle = [NSBundle mainBundle].bundleIdentifier;
			// if (bundle) {
			// 	const char *str = [bundle UTF8String];
			// 	if (str && (strcmp(str, "com.apple.AppStore") == 0)) {
			// 		return ref;
			// 	}
			// }			
			

			// return CFBridgingRetain(@"543e33f8b67697d3181f24b729885be5dc88bbee");
			// return CFBridgingRetain(@"c4a53f61db6be0db7738a1b5e283fff394b928ae");
			// return CFBridgingRetain(@"fa3b9f6a40c989c81f1ea715be656eddbb51cf6e");
			return ref;
			// return CFBridgingRetain(@"caeced0f1c657877292775d41ff88faadfa02f30");
			// return CFBridgingRetain(@"aa4dfb53a48f1bcad84de06fac3a3af66e41ac60");									
			// return CFBridgingRetain(@"bca317ab6e623f2d60dd21e72fd1a938955f6b01");
			// return CFBridgingRetain(@"d193589084c8181434d4f33647cd4fb74ffe498d");

			// return CFBridgingRetain(@"bde0d092a7035dec8e4984dc062681e886a6ef81");

			// return CFBridgingRetain(@"98604550ac14df4988c5cf1649cf66f452a11cf5");
		} else {

		}


		NSString *bundle = [NSBundle mainBundle].bundleIdentifier;
		NSString *key = (__bridge NSString *)property;
		if (bundle && key && [bundle length] > 0 && [key length] > 0) {
			const char *s = wiiauto_device_db_get([bundle UTF8String], [key UTF8String]);
			if (s) {
				NSString *ns = [NSString stringWithUTF8String:s];
				free(s);
				return (__bridge_retained CFStringRef)ns;
			}
		}
	} @catch (NSException *e) {
		remote_log("ERROR\n");
	}
	
	// @try {

	// 	if (CFEqual(property, CFSTR("InternalBuild"))
	// 	 	|| CFEqual(property, CFSTR("LBJfwOEzExRxzlAnSuI7eg"))
	// 		 || CFEqual(property, CFSTR("apple-internal-install"))) {
	// 		// CFRuntimeBase *rb = (CFRuntimeBase *)ref;

			
	// 		// remote_log("InternalBuild-test-p: %p | %p | %p\n", ref, kCFBooleanTrue, kCFBooleanFalse)
	// 		return kCFBooleanTrue;
	// 	}

	// } @catch (NSException *e) {}

	// if (ref) {
	// 	{ 
	// 		@try {
	// 			NSString *retp = (__bridge NSString *)property;
	// 			const char *contentp = [retp UTF8String];

	// 			NSString *ret = (__bridge NSString *)ref;
	// 			const char *content = [ret UTF8String];
	// 			remote_log("MGCA_CONTENT | %s = %s\n", contentp, content);
	// 		} @catch (NSException *e) {}

	// 		@try {
	// 			NSString *retp = (__bridge NSString *)property;
	// 			const char *contentp = [retp UTF8String];

	// 			NSDictionary *ret = (__bridge NSDictionary *)ref;
	// 			NSString *ll = [NSString stringWithFormat:@"%@", ret];
	// 			const char *content = [ll UTF8String];
	// 			remote_log("MGCA_DICT | %s = %s\n", contentp, content);
	// 		} @catch (NSException *e) {}

	// 		@try {

	// 			NSString *retp = (__bridge NSString *)property;
	// 			const char *contentp = [retp UTF8String];

	// 			{
	// 				NSData *d = (__bridge NSData *)ref;
	// 				const unsigned char *p = (const unsigned char *) [d bytes];
	// 				int i;
	// 				char buf[1024];
	// 				for(i = 0; i < [d length]; i++)
	// 				{
	// 					if (i > 0) {
	// 						sprintf(buf + strlen(buf), ":%02hhX", p[i]);
	// 					} else {
	// 						sprintf(buf + strlen(buf), "%02hhX", p[i]);
	// 					}				
	// 				}
	// 				remote_log("MGCA_DATA: %s = %s | %ld\n", contentp, buf, [d length]);
	// 			}

	// 		} @catch (NSException *e) {

	// 		}

	// 		if (CFEqual(property, CFSTR("ChipID"))) {
	// 		{
	// 			@try {
	// 				NSNumber *d = (__bridge NSNumber *)ref;
	// 				remote_log("ChipID-value: %lld\n", d.longLongValue);

	// 			} @catch (NSException *e) {}
	// 		}
	// 	}
	// 	}
	// }

	return ref;
}

static CFPropertyListRef (*orig_MGCopyAnswerWithError)(CFStringRef question, int *error, ...);
static CFPropertyListRef new_MGCopyAnswerWithError(CFStringRef question, int *error, ...)
{
	return orig_MGCopyAnswerWithError(question, error);
}

static int (*orig_open)(const char *name, int flags, mode_t mode);
static int new_open(const char *name, int flags, mode_t mode)
{
	if (name)  {	
		remote_log("open: %s\n", name);

		if (strstr(name, "/Applications/Cydia.app")) return -1;
		if (strstr(name, "/Library/MobileSubstrate")) return 1;
		if (strstr(name, "/bin/bash")) return -1;
		if (strstr(name, "/usr/sbin/sshd")) return -1;
		if (strstr(name, "/etc/apt")) return -1;
		if (strstr(name, "/apt")) return NULL;
		if (strstr(name, "/usr/bin/ssh")) return -1;
		if (strstr(name, "/Library/Preferences/com.apple.security.plist")) return -1;
		if (strstr(name, "/var/mobile/Library/ConfigurationProfiles/PublicInfo/MCMeta.plist")) return -1;
		if (strstr(name, "/proc/self/status")) return -1;
	}

	return orig_open(name, flags, mode);
}

static FILE *(*orig_fopen)(const char *name, const char *mode);
static FILE *new_fopen(const char *name, const char *mode)
{
	if (name)  {		
		remote_log("fopen: %s\n", name);

		if (strstr(name, "/Applications/Cydia.app")) return NULL;
		if (strstr(name, "/Library/MobileSubstrate")) return NULL;
		if (strstr(name, "/bin/bash")) return NULL;
		if (strstr(name, "/usr/sbin/sshd")) return NULL;
		if (strstr(name, "/etc/apt")) return NULL;
		if (strstr(name, "/apt")) return NULL;
		if (strstr(name, "/usr/bin/ssh")) return NULL;
		if (strstr(name, "/Library/Preferences/com.apple.security.plist")) return NULL;
		if (strstr(name, "/var/mobile/Library/ConfigurationProfiles/PublicInfo/MCMeta.plist")) return NULL;
		if (strstr(name, "/proc/self/status")) return NULL;
	}

	return orig_fopen(name, mode);
}


static void __hide_facebook_jailbreak()
{
	@try {
		NSString *bundle = [NSBundle mainBundle].bundleIdentifier;
		const char *str = [bundle UTF8String];
		if (str) {
			if (strstr(str, "google")) {
				if (!os_greater_than_12) {
					MSHookFunction(fopen, new_fopen, &orig_fopen);
					MSHookFunction(open, new_open, &orig_open);
				}
				%init(HOOK_GM);
			} else if (strstr(str, "com.facebook.Facebook")) {
				if (!os_greater_than_12) {
					MSHookFunction(fopen, new_fopen, &orig_fopen);
					MSHookFunction(open, new_open, &orig_open);
				}
				%init(HOOK_FB);

				@try {
					
					// NSURL *groupPath = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:@"group.com.facebook.Facebook"];
					// NSArray *fileArray = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[groupPath path] error:nil];
					// for (NSString *filename in fileArray)  {
					// 	if ([filename isEqualToString:@".com.apple.mobile_container_manager.metadata.plist"]) {

					// 		NSString *file_path = [NSString stringWithFormat:@"%@/%@", [groupPath path], filename];
					// 		remote_log("try_read: %s\n", [file_path UTF8String]);
					// 		NSMutableDictionary *plistDic = [[NSMutableDictionary alloc] initWithContentsOfFile: file_path];

					// 		NSUUID  *UUID = [NSUUID UUID];
        			// 		NSString* stringUUID = [UUID UUIDString];
					// 		plistDic[@"KEY"] = stringUUID;

					// 		if (plistDic) {
					// 			NSString *cc = [NSString stringWithFormat:@"file_content: %@", plistDic];
					// 			remote_log("%s\n", [cc UTF8String]);

					// 			NSError *err;
					// 			NSDictionary* dict2 = [NSPropertyListSerialization dataFromPropertyList:plistDic
					// 				format:NSPropertyListBinaryFormat_v1_0
					// 				errorDescription:&err];
					// 			[dict2 writeToFile:[NSString stringWithFormat:@"%@/test.plist", [groupPath path]] atomically:YES];
					// 		} else {
					// 			remote_log("file_content-not_read\n");
					// 		}

					// 		break;
					// 	}						
					// }

					// {
					// 	NSArray *paths =[[NSFileManager defaultManager] URLsForDirectory:NSDocumentationDirectory inDomains:NSUserDomainMask];
					// 	for (NSObject *p in paths) {
					// 		NSString *ll = [NSString stringWithFormat:@"path: %@", paths];
					// 		remote_log("paths_1: %s\n", [ll UTF8String]);
					// 	}
					// }

					// {
					// 	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentationDirectory, NSUserDomainMask, YES);
					// 	for (NSObject *p in paths) {
					// 		NSString *ll = [NSString stringWithFormat:@"path: %@", paths];
					// 		remote_log("paths_2: %s\n", [ll UTF8String]);
					// 	}
					// }

					// NSArray *fileArray = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:@"/private/var/containers/Bundle/Application/" error:nil];
					// for (NSString *filename in fileArray)  {
					// 	remote_log("file_name: %s\n", [filename UTF8String]);
					// }

					// {

					// 	NSString *file_path = @"/private/var/containers/Bundle/Application/450E25EB-F105-49DF-843A-CA2204AA4B22/iTunesMetadata.plist";
					// 	remote_log("try_read: %s\n", [file_path UTF8String]);
					// 	NSMutableDictionary *plistDic = [[NSMutableDictionary alloc] initWithContentsOfFile: file_path];

					// 	if (plistDic) {
					// 		NSString *cc = [NSString stringWithFormat:@"file_content: %@", plistDic];
					// 		remote_log("%s\n", [cc UTF8String]);
					// 	} else {
					// 		remote_log("file_content-not_read\n");
					// 	}				
					// }

				} @catch (NSException *e) {
				}
			}
		}

	} @catch (NSException *e) {

	}
}

static void __spoof()
{
	@autoreleasepool {
		// appsChosenUpdated();

		// basically dlopen libMobileGestalt
		MSImageRef libGestalt = MSGetImageByName("/usr/lib/libMobileGestalt.dylib");
		if (libGestalt) {
			{
				// Get "_MGCopyAnswer" symbol
				void *MGCopyAnswerFn = MSFindSymbol(libGestalt, "_MGCopyAnswer");
				/*
				* get address of MGCopyAnswer_internal by doing symbol + offset (should be 8 bytes)
				* note: hex implementation of MGCopyAnswer: 01 00 80 d2 01 00 00 14 (from iOS 9+)
				* so address of MGCopyAnswer + offset = MGCopyAnswer_internal. MGCopyAnswer_internal *always follows MGCopyAnswer (*from what I've checked)
				*/
				const uint8_t *MGCopyAnswer_ptr = (const uint8_t *)MGCopyAnswer;
				addr_t branch = find_branch64(MGCopyAnswer_ptr, 0, 8);
				addr_t branch_offset = follow_branch64(MGCopyAnswer_ptr, branch);
				MSHookFunction(((void *)((const uint8_t *)MGCopyAnswerFn + branch_offset)), (void *)new_MGCopyAnswer_internal, (void **)&orig_MGCopyAnswer_internal);
			}
			// {
			// 	// Get "_MGCopyAnswer" symbol
			// 	void *MGCopyMultipleAnswersFn = MSFindSymbol(libGestalt, "_MGCopyMultipleAnswers");
				
			// 	const uint8_t *MGCopyMultipleAnswers_ptr = (const uint8_t *)MGCopyMultipleAnswers;
			// 	addr_t branch = find_branch64(MGCopyMultipleAnswers_ptr, 0, 0);
			// 	addr_t branch_offset = follow_branch64(MGCopyMultipleAnswers_ptr, branch);
			// 	MSHookFunction(((void *)((const uint8_t *)MGCopyMultipleAnswersFn + branch_offset)), (void *)new_MGCopyMultipleAnswers, (void **)&orig_MGCopyMultipleAnswers);
			// }

			// {
			// 	void *MGCopyAnswerWithErrorFn = MSFindSymbol(libGestalt, "_MGCopyAnswerWithError");

			// 	const uint8_t *MGCopyAnswerWithError_ptr = (const uint8_t *)MGCopyAnswerWithError;
			// 	addr_t branch = find_branch64(MGCopyAnswerWithError_ptr, 0, 8);
			// 	addr_t branch_offset = follow_branch64(MGCopyAnswerWithError_ptr, branch);
			// 	MSHookFunction(((void *)((const uint8_t *)MGCopyAnswerWithErrorFn + branch_offset)), (void *)new_MGCopyAnswerWithError, (void **)&orig_MGCopyAnswerWithError);
			// }

			// {
			// 	void *pp = MSFindSymbol(libGestalt, "_MGSetAnswer");
			// 	remote_log("MGSetAnswer_ptr : %p\n", pp);
			// }
		}
		
		// CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)appsChosenUpdated, CFSTR("com.tonyk7.mgspoof/appsChosenUpdated"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
		// CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)modifiedKeyUpdated, CFSTR("com.tonyk7.mgspoof/modifiedKeyUpdated"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
		// CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)configUpdated, CFSTR("com.tonyk7.mgspoof/configUpdated"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
		// modifiedKeyUpdated();
		// configUpdated();
	}
}

@interface UIKeyboardTaskExecutionContext : NSObject

@end

@interface UIKeyboardTaskQueue : NSObject

- (void)performSingleTask:(void (^)(id))arg1;
-(void)addTask:(id)arg1 ;

@end

@interface UIKeyboardImpl : UIView
@property(readonly, nonatomic) UIKeyboardTaskQueue *taskQueue;
+(UIKeyboardImpl*)sharedInstance;
+(UIKeyboardImpl*)activeInstance;
-(void)addInputString:(NSString*)string;
-(void)addInputString:(id)arg1 fromVariantKey:(BOOL)arg2 ;
-(void)addInputString:(id)arg1 withFlags:(unsigned long long)arg2 executionContext:(id)arg3 ;
-(void)insertText:(id)arg1;
-(void)handleKeyWithString:(id)arg1 forKeyEvent:(id)arg2 executionContext:(id)arg3 ;
-(void)textWillChange:(id)arg1 ;
-(void)textDidChange:(id)arg1 ;
-(void)textChanged:(id)arg1 ;
-(void)syncInputManagerToKeyboardState;
-(void)toggleSoftwareKeyboard;
-(void)syncInputManagerToKeyboardStateWithExecutionContext:(id)arg1 ;
-(void)setChanged;
-(void)updateObserverState;
-(void)syncDocumentStateToInputDelegate;
-(BOOL)callShouldInsertText:(id)arg1 ;
-(void)deleteFromInput;
-(void)deleteFromInputWithFlags:(unsigned long long)arg1 executionContext:(id)arg2 ;
@end

#define MAKE_INPUT_TEXT(num) \
static void input_text##num() {\
	@autoreleasepool {\
		@try {\
\
			buffer b;\
			const char *ptr;\
\
			buffer_new(&b);\
			buffer_append_file(b, DAEMON_FILE_INPUT_TEXT_##num);\
			buffer_get_ptr(b, &ptr);\
			if (ptr && UIKeyboardImpl.activeInstance && !UIKeyboardImpl.activeInstance.isHidden) {\
				NSString *ns = [NSString stringWithUTF8String:ptr];\
				if ([ns isEqualToString:@"\b"]) {\
					[UIKeyboardImpl.sharedInstance.taskQueue performSingleTask:^(id ctx) {\
						[UIKeyboardImpl.sharedInstance handleKeyWithString:ns forKeyEvent:nil executionContext:ctx]; \
					}];\
				 } else {\
				 	[UIKeyboardImpl.sharedInstance insertText:ns];\
				 }\
			}\
			release(b.iobj);\
\
		} @catch (NSException *e) {}\
	}\
}

					// __block UIKeyboardImpl *kb = [%c(UIKeyboardImpl) sharedInstance];\
					// UIKeyboardTaskQueue *queue = kb.taskQueue;\
					// [queue addTask:^(UIKeyboardTaskExecutionContext *context, int arg2)\
					// {\
					// 	[UIKeyboardImpl.sharedInstance insertText:ns];\
					// }];\

// [kb addInputString:ns withFlags:0 executionContext:context];\
					// [UIKeyboardImpl.sharedInstance insertText:ns];\

// [UIKeyboardImpl.sharedInstance handleKeyWithString:[NSString stringWithUTF8String:ptr] forKeyEvent:nil executionContext:ctx]; \
// [keyboardImpl insertText:[NSString stringWithUTF8String:ptr]];\


// if ([ns isEqualToString:@"\b"]) {\
// 					[UIKeyboardImpl.sharedInstance.taskQueue performSingleTask:^(id ctx) {\
// 						[UIKeyboardImpl.sharedInstance deleteFromInputWithFlags:0 executionContext:ctx]; \
// 					}];\
// 				 } else {\
// 					[UIKeyboardImpl.sharedInstance.taskQueue performSingleTask:^(id ctx) {\
// 						[UIKeyboardImpl.sharedInstance handleKeyWithString:ns forKeyEvent:nil executionContext:ctx]; \
// 					}];\
// 				 }\

MAKE_INPUT_TEXT(1)
MAKE_INPUT_TEXT(2)
MAKE_INPUT_TEXT(3)
MAKE_INPUT_TEXT(4)
MAKE_INPUT_TEXT(5)
MAKE_INPUT_TEXT(6)
MAKE_INPUT_TEXT(7)
MAKE_INPUT_TEXT(8)
MAKE_INPUT_TEXT(9)
MAKE_INPUT_TEXT(10)

#import <AdSupport/ASIdentifierManager.h> 
#import <sys/utsname.h>

static void __remove_obs()
{
	NSString *bundle = nil;
	@try {
		bundle = [NSBundle mainBundle].bundleIdentifier;
	} @catch (NSException *e) {
		bundle = nil;
	}	

	if (!bundle) return;

	CFNotificationCenterRemoveEveryObserver(CFNotificationCenterGetDarwinNotifyCenter(), [bundle UTF8String]);
}

static void __listen_paste()
{
	NSString *bundle = nil;
	@try {
		bundle = [NSBundle mainBundle].bundleIdentifier;
	} @catch (NSException *e) {
		bundle = nil;
	}	

	if (!bundle) return;

	remote_log_set_process([bundle UTF8String]);

	CFNotificationCallback callbacks[] = {
		(CFNotificationCallback)input_text1,
		(CFNotificationCallback)input_text2,
		(CFNotificationCallback)input_text3,
		(CFNotificationCallback)input_text4,
		(CFNotificationCallback)input_text5,
		(CFNotificationCallback)input_text6,
		(CFNotificationCallback)input_text7,
		(CFNotificationCallback)input_text8,
		(CFNotificationCallback)input_text9,
		(CFNotificationCallback)input_text10
	};

	for (int i = 1; i <= 10; ++i) {
		NSString *msg = [NSString stringWithFormat:@"com.wiimob.wiiauto/inputText%d", i];

		CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), [bundle UTF8String], callbacks[i - 1], (__bridge CFStringRef)msg, NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
	}
}



static dispatch_queue_t _imessage_queue;

static int __matrid_status(NSString *address, NSString *service)
{
	// {
	// 	NSString *formattedAddress = nil;
	// 	if ([address rangeOfString:@"@"].location != NSNotFound) 
	// 		formattedAddress = [@"mailto:" stringByAppendingString:address];
	// 	else 
	// 		formattedAddress = [@"tel:" stringByAppendingString:address];
	// 	NSDictionary *status = [[IDSIDQueryController sharedInstance] 
	// 		_currentIDStatusForDestinations:@[formattedAddress] service:service
	// 		listenerID:@"__kIMChatServiceForSendingIDSQueryControllerListenerID"];

	// 	NSString *ll = [NSString stringWithFormat:@"%@", status];
	// 	remote_log("CURRENT %s\n", [ll UTF8String]);
	// }
	{
		NSString *formattedAddress = nil;

		// if ([address rangeOfString:@"@"].location != NSNotFound) 
		// 	formattedAddress = [@"mailto:" stringByAppendingString:address];
		// else 
		// 	formattedAddress = [@"tel:" stringByAppendingString:address];

		// // NSDictionary *status = [[IDSIDQueryController sharedInstance] 
		// // 	_refreshIDStatusForDestinations:@[formattedAddress] service:service
		// // 	listenerID:@"__kIMChatServiceForSendingIDSQueryControllerListenerID"];

		if ([address rangeOfString:@"@"].location != NSNotFound) 
			formattedAddress = [@"mailto:" stringByAppendingString:address];
		else 
			formattedAddress = [@"tel:" stringByAppendingString:address];

		// long long tid = [[IDSIDQueryController sharedInstance] _currentCachedIDStatusForDestination:formattedAddress 
		// 	service:service listenerID:@"__kIMChatServiceForSendingIDSQueryControllerListenerID"] ;

		// if (tid == 0) {
		// 	tid = [[IDSIDQueryController sharedInstance] _currentIDStatusForDestination:formattedAddress 
		// 		service:service listenerID:@"__kIMChatServiceForSendingIDSQueryControllerListenerID"] ;
		// 	if (tid == 0) {
				long long tid = [[IDSIDQueryController sharedInstance] _currentIDStatusForDestination:formattedAddress 
					service:service listenerID:@"__kIMChatServiceForSendingIDSQueryControllerListenerID"] ;
				if (tid == 0) {
					tid = [[IDSIDQueryController sharedInstance] _refreshIDStatusForDestination:formattedAddress 
						service:service listenerID:@"__kIMChatServiceForSendingIDSQueryControllerListenerID"] ;
				}
		// 	}
		// }

		return tid;
		// NSString *ll = [NSString stringWithFormat:@"%@", status];
		// remote_log("REFRESH %s\n", [ll UTF8String]);

		// return [status[formattedAddress] intValue];		
	}
	
}

static int __matrid_status_force(NSString *address, NSString *service)
{
	NSString *formattedAddress = nil;
	if ([address rangeOfString:@"@"].location != NSNotFound) 
		formattedAddress = [@"mailto:" stringByAppendingString:address];
	else 
		formattedAddress = [@"tel:" stringByAppendingString:address];

	long long tid = [[IDSIDQueryController sharedInstance] _refreshIDStatusForDestination:formattedAddress 
					service:service listenerID:@"__kIMChatServiceForSendingIDSQueryControllerListenerID"] ;

	return tid;	
}


#include <notify.h>

static void __handle_flushsms()
{
	dispatch_barrier_async(_imessage_queue , ^{

		[[IDSIDQueryController sharedInstance] _flushQueryCacheForService:@"com.apple.madrid"];

	});
}

static void __test_set_imessage_id()
{
	dispatch_barrier_async(_imessage_queue , ^{

		// remote_log("CHANGE ID\n");

		BOOL w = [[IDSIDQueryController sharedInstance] _warmupQueryCacheForService:@"com.apple.madrid"];
		remote_log("warm: %s\n", w ? "true" : "false");
		usleep(500000);
		[[IDSIDQueryController sharedInstance] _setCurrentIDStatus:1 forDestination:@"tel:+84342037894" service:@"com.apple.madrid"];
		long long tid = [[IDSIDQueryController sharedInstance] _refreshIDStatusForDestination:@"tel:+84342037894" service:@"com.apple.madrid" listenerID:@"__kIMChatServiceForSendingIDSQueryControllerListenerID"];
		usleep(500000);
		BOOL f = [[IDSIDQueryController sharedInstance] _flushQueryCacheForService:@"com.apple.madrid"];
		remote_log("flush: %s\n", f ? "true" : "false");
		usleep(500000);

		remote_log("ID: %lld\n", tid);

	});
}

static void __test_mobilesms_force()
{
	dispatch_barrier_async(_imessage_queue , ^{

		@try {
			char buf[1024];

			const char *value;
			value = wiiauto_device_db_get_share("check_imessage", "number");
			if (value) {
				int status = __matrid_status_force([NSString stringWithUTF8String:value], @"com.apple.madrid");
				sprintf(buf, "%d", status);
				wiiauto_device_db_set_share("check_imessage", "status", buf);
				free(value);
			}


		} @catch (NSException *e) {

		}	

	});
}

static void __test_mobilesms()
{
	dispatch_barrier_async(_imessage_queue , ^{

		@try {
			char buf[1024];

			const char *value;
			value = wiiauto_device_db_get_share("check_imessage", "number");
			if (value) {
				
				// __matrid_status([NSString stringWithUTF8String:value], @"com.apple.ess");
				// __matrid_status([NSString stringWithUTF8String:value], @"com.apple.private.ac");
				int status = __matrid_status([NSString stringWithUTF8String:value], @"com.apple.madrid");
				sprintf(buf, "%d", status);

				wiiauto_device_db_set_share("check_imessage", "status", buf);
				
				// if (status == 0) {
				// 	notify_post("com.wiimob.wiiauto/resetIDS");
				// 	// usleep(1000000);
				// }

				free(value);
			}


		} @catch (NSException *e) {

		}	

	});

	// dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC), _imessage_queue , ^{

	// 	// dispatch_barrier_async(_imessage_queue , ^{

	// 	// 	@try {
	// 	// 		CKConversationList* conversationList = [CKConversationList sharedConversationList];
	// 	// 		[conversationList deleteConversations:[[conversationList conversations] mutableCopy]];
	// 	// 	} @catch (NSException *e) {

	// 	// 	}	

	// 	// });

	// 		// IMServiceImpl *service = [IMServiceImpl iMessageService];
	// 		// IMAccount *account = [[IMAccountController sharedInstance] __ck_defaultAccountForService:service];

	// 		// NSMutableArray *imhandles = [NSMutableArray array];

	// 		// {
	// 		// 	IMHandle *im = [account imHandleWithID:@"dung2274us@protonmail.com" alreadyCanonical:NO];
	// 		// 	[imhandles addObject:im];
	// 		// }
	// 		// {
	// 		// 	IMHandle *im = [account imHandleWithID:@"lan4535vn@gmail.com" alreadyCanonical:NO];
	// 		// 	[imhandles addObject:im];
	// 		// }	
	// 		// {
	// 		// 	IMHandle *im = [account imHandleWithID:@"+84762198586" alreadyCanonical:NO];
	// 		// 	[imhandles addObject:im];
	// 		// }				
	// 		// {
	// 		// 	IMHandle *im = [account imHandleWithID:@"mai7467vn@protonmail.com" alreadyCanonical:NO];
	// 		// 	[imhandles addObject:im];
	// 		// }								
	// 		// {
	// 		// 	IMHandle *im = [account imHandleWithID:@"+84968166888" alreadyCanonical:NO];
	// 		// 	[imhandles addObject:im];
	// 		// }	
	// 		// {
	// 		// 	IMHandle *im = [account imHandleWithID:@"+84981590889" alreadyCanonical:NO];
	// 		// 	[imhandles addObject:im];
	// 		// }	
	// 		// // {
	// 		// // 	IMHandle *im = [account imHandleWithID:@"daocaoraurelex@gmail.com" alreadyCanonical:NO];
	// 		// // 	[imhandles addObject:im];
	// 		// // }			

	// 		// CKConversationList* conversationList = [CKConversationList sharedConversationList];
	// 		// CKConversation *conversation = [conversationList conversationForHandles:imhandles displayName:@"" joinedChatsOnly:false create:true];

	// 		// [[conversation chat] refreshServiceForSending];
	// 		// [[conversation chat] setVIP:TRUE];

	// 		// NSAttributedString* text = [[NSAttributedString alloc] initWithString:@"Hi"];
	// 		// CKComposition* composition = [[CKComposition alloc] initWithText:text subject:nil];

	// 		// id message = [conversation messageWithComposition:composition];
	// 		// // [conversation sendMessage:message newComposition:YES];

	// 		// [[conversation chat] sendMessage:message];


	// });
}

static void __handle_mobilesms()
{
	dispatch_barrier_async(_imessage_queue , ^{

		long long rid;
		char *infos = NULL;
		int success = 0;

		int step = 1;
		wiiauto_device_db_imessage_get(&rid, &infos, step);

		if (!infos) {
			step = 3;
			wiiauto_device_db_imessage_get(&rid, &infos, step);
		}
		if (!infos) {
			step = 4;
			wiiauto_device_db_imessage_get(&rid, &infos, step);
		}
		if (!infos) {
			step = 5;
			wiiauto_device_db_imessage_get(&rid, &infos, step);
		}
		if (!infos) {
			step = 6;
			wiiauto_device_db_imessage_get(&rid, &infos, step);
		}

		if (infos) {

			@autoreleasepool {
				@try {
					NSError *jsonError;
					NSData *objectData = [[NSString stringWithUTF8String:infos] dataUsingEncoding:NSUTF8StringEncoding];
					NSDictionary *json = [NSJSONSerialization JSONObjectWithData:objectData
														options:NSJSONReadingMutableContainers 
															error:&jsonError];

					if (json) {

						NSMutableArray *receivers = nil;
						NSString *content = nil;
						NSString *test = nil;
						NSString *leave = nil;
						NSString *file_image = nil;
						NSString *delete_old = nil;

						if ([json objectForKey:@"receivers"]) {
							receivers = [json[@"receivers"] mutableCopy];
						}
						if ([json objectForKey:@"content"]) {
							content = json[@"content"];
						}
						if ([json objectForKey:@"leave"]) {
							leave = json[@"leave"];
						}
						if ([json objectForKey:@"image"]) {
							file_image = json[@"image"];
						}
						if ([json objectForKey:@"delete_old"]) {
							delete_old = json[@"delete_old"];
						}
						if ([json objectForKey:@"test"]) {
							test = json[@"test"];
						}
						
						if (content && [receivers count] > 0) {

							int flag = 1;

							// for (int i = 0; i < [receivers count]; ++i) {
							// 	int status = __matrid_status(receivers[i], @"com.apple.madrid");
							// 	if (status == 0) {
							// 		notify_post("com.wiimob.wiiauto/resetIDS");
							// 		usleep(1000000);
							// 		flag = 0;
							// 		break;
							// 	}
							// 	if (status != 1) {
							// 		flag = 2;
							// 	}
							// }


							if (flag == 1) {
								IMServiceImpl *service = [IMServiceImpl iMessageService];
								IMAccount *account = [[IMAccountController sharedInstance] __ck_defaultAccountForService:service];

								NSMutableArray *imhandles = [NSMutableArray array];
								for (int i = 0; i < [receivers count]; ++i) {
									IMHandle *im = [account imHandleWithID:receivers[i] alreadyCanonical:NO];
									[imhandles addObject:im];
								}

								CKConversationList* conversationList = [CKConversationList sharedConversationList];

								if (delete_old) {
									CKConversation *conversation = [conversationList conversationForHandles:imhandles displayName:nil joinedChatsOnly:false create:false];
									if (conversation) {
										NSMutableArray *arr = [NSMutableArray array];
										[arr addObject:conversation];
										[conversationList deleteConversations:arr];
										usleep(500000);
									}
								}

								CKConversation *conversation = [conversationList conversationForHandles:imhandles displayName:nil joinedChatsOnly:false create:true];

								NSMutableAttributedString* text = [[NSMutableAttributedString alloc] initWithString:content];

								// @try {	
								// 	NSError *error = nil;
								// 	NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:&error];

								// 	 NSArray *matches = [detector matchesInString:content
								// 											options:0
								// 											range:NSMakeRange(0, [content length])];
								// 	for (NSTextCheckingResult *match in matches) {
								// 		NSRange matchRange = [match range];
								// 		if ([match resultType] == NSTextCheckingTypeLink) {
								// 			NSURL *url = [match URL];
								// 			[text addAttribute: NSLinkAttributeName value:url range:matchRange];
								// 		}
								// 	}
								// } @catch (NSException *e) {

								// }

								// CKComposition* composition = [[CKComposition alloc] initWithText:text subject:nil];
								CKComposition *composition = [CKComposition composition];

								if (file_image) {
									NSURL* fileUrl = [NSURL URLWithString:file_image];
									CKMediaObjectManager* objManager = [CKMediaObjectManager sharedInstance];
									CKMediaObject *object = nil;
									@try {
									 	object = [objManager mediaObjectWithFileURL:fileUrl filename:nil transcoderUserInfo:nil attributionInfo:@{} hideAttachment:NO];
									} @catch (NSException *exc) {
									}
									if (object) {
										composition = [composition compositionByAppendingMediaObject:object];
									}
								}

								composition = [composition compositionByAppendingText:text];

								id message = [conversation messageWithComposition:composition];

								if (test) {
									wiiauto_device_db_imessage_set_status(rid, 8888);		
								} else {
									wiiauto_device_db_imessage_set_status(rid, 2);		
								}

								success = 1;

								[conversation sendMessage:message newComposition:YES];

								if (leave) {
									usleep(5000000);
									[[conversation chat] leaveiMessageGroup];
									[[conversation chat] leave];
								}
								
							} else if (flag == 0) {
								success = 2;
							}

						}
						
					}

				} @catch (NSException *e) {
				}	
			}

			if (success == 0) {
				wiiauto_device_db_imessage_set_status(rid, 0);
			} else if (success == 2) {
				switch(step) {
					case 1:
						wiiauto_device_db_imessage_set_status(rid, 3);
						break;
					case 3:
						wiiauto_device_db_imessage_set_status(rid, 4);
						break;
					case 4:
						wiiauto_device_db_imessage_set_status(rid, 5);
						break;
					case 5:
						wiiauto_device_db_imessage_set_status(rid, 6);
						break;
					default:
						wiiauto_device_db_imessage_set_status(rid, 0);
						break;
				}				
			}
		
			free(infos);

			__handle_mobilesms();
		}
	});
}

static void __handle_deletesms()
{
	dispatch_barrier_async(_imessage_queue , ^{

		@try {
			CKConversationList* conversationList = [CKConversationList sharedConversationList];
			[conversationList deleteConversations:[[conversationList conversations] mutableCopy]];
		} @catch (NSException *e) {

		}	

	});
}

static void __handle_forget() {
	dispatch_barrier_async(_imessage_queue , ^{

		@try {
			IMServiceImpl *service = [IMServiceImpl iMessageService];
			IMAccount *account = [[IMAccountController sharedInstance] __ck_defaultAccountForService:service];
			[account forgetAllWatches];
			[account disconnectAllIMHandles];
		} @catch (NSException *e) {

		}	

	});
}



static void __hook_mobilesms()
{
	NSString *bundle = nil;
	@try {
		bundle = [NSBundle mainBundle].bundleIdentifier;
	} @catch (NSException *e) {
		bundle = nil;
	}	

	if (!bundle) return;

	if ([bundle isEqualToString:@"com.apple.MobileSMS"]) {
		// _imessage_queue = dispatch_queue_create("wiiauto_imessage", 0);
		_imessage_queue = dispatch_get_main_queue();
		CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, __handle_mobilesms, CFSTR("com.wiimob.wiiauto/sendimessage"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
		CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, __test_mobilesms, CFSTR("com.wiimob.wiiauto/testimessage"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
		CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, __test_mobilesms_force, CFSTR("com.wiimob.wiiauto/testimessageforce"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
		CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, __handle_deletesms, CFSTR("com.wiimob.wiiauto/deletemessage"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
		CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, __handle_flushsms, CFSTR("com.wiimob.wiiauto/flushimessagecache"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
		CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, __test_set_imessage_id, CFSTR("com.wiimob.wiiauto/test_set_imessage_id"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
		CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, __handle_forget, CFSTR("com.wiimob.wiiauto/imessageforget"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);

		// dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC), _imessage_queue , ^{

		// 	{
		// 		IMServiceImpl *service = [IMServiceImpl iMessageService];
		// 		IMAccount *a = [[IMAccountController sharedInstance] __ck_defaultAccountForService:service];
		// 		[a requestNewAuthorizationCredentials];
		// 	}

		// 	{
		// 		NSArray * v = [[IMAccountController sharedInstance] accounts];
		// 		remote_log("accounts: %d\n", [v count]);
		// 		for (int i = 0; i < [v count]; ++i) {
		// 			IMAccount *a = (IMAccount *)v[i];
		// 			const char *name = [[a displayName] UTF8String];
		// 			remote_log("accounts-%d : %s | can_send_message = %s\n", i, name, [a canSendMessages] ? "true" : "false");
		// 			remote_log("accounts-%d : %s | isConnected = %s\n", i, name, [a isConnected] ? "true" : "false");
		// 			remote_log("accounts-%d : %s | isManaged = %s\n", i, name, [a isManaged] ? "true" : "false");
		// 			remote_log("accounts-%d : %s | isRegistered = %s\n", i, name, [a isRegistered] ? "true" : "false");
		// 			remote_log("accounts-%d : %s | myStatus = %llu\n", i, name, [a myStatus]);
		// 			const char *lid = [[a get_login_id] UTF8String];
		// 			remote_log("accounts-%d : %s | loginID= %s\n", i, name, lid);
		// 			const char *uid = [[a get_unique_id] UTF8String];
		// 			remote_log("accounts-%d : %s | uniqueID= %s\n", i, name, uid);
		// 			unsigned long long d = [a capabilities];
		// 			remote_log("accounts-%d : %s | capabilities: %llu\n", i, name, d);

		// 			// // // [a clearServiceCaches];
		// 			// // // [a _invalidateCachedAliases];
		// 			// // // [a requestNewAuthorizationCredentials];
		// 			if (i == 2) {

		// 				IMAccount *account = a;
		// 				[a forgetAllWatches];
		// 				[a disconnectAllIMHandles];
		// 				[a requestNewAuthorizationCredentials];

		// 				usleep(5000000);

		// 				NSMutableArray *imhandles = [NSMutableArray array];
		// 				{
		// 					IMHandle *im = [account imHandleWithID:@"+84936240251" alreadyCanonical:NO];
		// 					[imhandles addObject:im];
		// 				}	
		// 				CKConversationList* conversationList = [CKConversationList sharedConversationList];
		// 				CKConversation *conversation = [conversationList conversationForHandles:imhandles displayName:@"" joinedChatsOnly:false create:true];

		// 				// [[conversation chat] refreshServiceForSending];
		// 				// [[conversation chat] setVIP:TRUE];

		// 				NSAttributedString* text = [[NSAttributedString alloc] initWithString:@"Hi"];
		// 				CKComposition* composition = [[CKComposition alloc] initWithText:text subject:nil];

		// 				id message = [conversation messageWithComposition:composition];
		// 				[conversation sendMessage:message newComposition:YES];

		// 				// [[conversation chat] sendMessage:message];

		// 			}
		// 		}
		// 	}		

		// });
	}	
}

// static void __hook_StoreUIKit()
// {
// 	NSString *bundle = nil;
// 	@try {
// 		bundle = [NSBundle mainBundle].bundleIdentifier;
// 	} @catch (NSException *e) {
// 		bundle = nil;
// 	}	

// 	if (!bundle) return;

// 	if ([bundle isEqualToString:@"com.apple.ios.StoreKitUIService"]) {
// 		signal(SIGINT, SIG_IGN);
// 		signal(SIGTERM, SIG_IGN);
// 		signal(SIGKILL, SIG_IGN);
// 	}
// }

#include "wiiauto/daemon/preference/preference.h"
// /*
//  * CONSTRUCTOR
//  */

static void (*orig_glTexImage2D)( GLenum target,
                                GLint level,
                                GLint internalFormat,
                                GLsizei width,
                                GLsizei height,
                                GLint border,
                                GLenum format,
                                GLenum type,
                                 const GLvoid * data);


void my_glTexImage2D(GLenum target,
                     GLint level,
                     GLint internalFormat,
                     GLsizei width,
                     GLsizei height,
                     GLint border,
                     GLenum format,
                     GLenum type,
                     const GLvoid * data)
{
	remote_log("glTexImage2D: %d %d | %d - %d - %d\n", width, height, format, GL_RGBA, GL_RGB);
	orig_glTexImage2D(target, level, internalFormat, width, height, border, format, type, data);
}

static int (*orig_sysctl)(int *, u_int, void *, size_t *, void *, size_t);
static int my_sysctl(int *a, u_int b, void *c, size_t *d, void *e, size_t f)
{
	int r = orig_sysctl(a, b, c, d, e, f);

	if (b == 2) {
		remote_log("sysctl: %d , %d\n", a[0], a[1]);
		if (a[0] == CTL_KERN && a[1] == KERN_BOOTTIME && c) {

			const char *value;
			value = wiiauto_device_db_get_share("google", "gmail_boottime");
			if (!value) {
				value = wiiauto_device_db_get_share("sysctl", "kern.boottime");
			}
			if (value) {
				struct timeval *tv = (struct timeval *)c;
				tv->tv_sec = atoi(value);
				free(value);
			}
			remote_log("kern.boottime\n");
		} else if (a[0] == CTL_KERN && a[1] == KERN_OSRELEASE && c) {

			const char *value;
			value = wiiauto_device_db_get_share("sysctl", "kern.osrelease");
			if (value) {
				strcpy(c, value);
				*d = strlen(value);
				free(value);
			}
			remote_log("kern.osrelease: %s\n", c);
		} else if (a[0] == CTL_KERN && a[1] == KERN_OSVERSION && c) {

			const char *value;
			value = wiiauto_device_db_get_share("sysctl", "kern.osversion");
			if (value) {
				strcpy(c, value);
				*d = strlen(value);
				free(value);
			}
			remote_log("kern.osversion: %s\n", c);
		} else if (a[0] == CTL_KERN && a[1] == KERN_VERSION && c) {

			const char *value;
			value = wiiauto_device_db_get_share("sysctl", "kern.version");
			if (value) {
				strcpy(c, value);
				*d = strlen(value);
				free(value);
			}
			remote_log("kern.version: %s\n", c);
		}
	}

	return r;
}


#import <IOSurface/IOSurfaceRef.h>
#import <IOKit/IOKitLib.h>
#import "IOMobileFramebuffer.h"
#import "IOSurfaceAccelerator.h"

static kern_return_t (*orig2_IORegistryEntryCreateCFProperties)(io_registry_entry_t entry, CFMutableDictionaryRef *properties, CFAllocatorRef allocator, IOOptionBits options);

static kern_return_t new2_IORegistryEntryCreateCFProperties(io_registry_entry_t entry, CFMutableDictionaryRef *properties, CFAllocatorRef allocator, IOOptionBits options)
{	
	kern_return_t r = orig2_IORegistryEntryCreateCFProperties(entry, properties, allocator, options);

	@try {
		if (properties && *properties) {
			NSMutableDictionary *dict = (__bridge NSMutableDictionary *)(*properties);
			if ([dict objectForKey:@"IOPlatformSerialNumber"]) {

				const char *value = wiiauto_device_db_get_share("system", "serialnumber");
				if (value) {
					NSString *seri = [NSString stringWithUTF8String:value];
					dict[@"IOPlatformSerialNumber"] = seri;
					free(value);
				}

				// dict[@"IOPlatformSerialNumber"] = NG_searnalNumber;
			}
		} 
	} @catch (NSException *e) {}

	return r;
}

CFTypeRef
(*old_IORegistryEntryCreateCFProperties)(
        io_registry_entry_t	entry,
        CFStringRef		key,
        CFAllocatorRef		allocator,
        IOOptionBits		options );
  
  
CFTypeRef new_IORegistryEntryCreateCFProperties(
        io_registry_entry_t	entry,
        CFStringRef		key,
        CFAllocatorRef		allocator,
        IOOptionBits		options ){
    NSString *type = (__bridge NSString *)key;

	// 	if (type) {
	// 	NSString *rr = [NSString stringWithFormat:@"%@", key];
	// 	const char *content = [rr UTF8String];
	// 	remote_log("get-1: %s\n", content);
	// }


	// if (!__change_info__) {
	// 	return old_IORegistryEntryCreateCFProperties(entry,key,allocator,options);
	// }
    if([type isEqualToString:@"IOPlatformSerialNumber"] 
		|| [type isEqualToString:@"serial-number"]){

		const char *value = wiiauto_device_db_get_share("system", "serialnumber");
		if (value) {
			NSString *seri = [NSString stringWithUTF8String:value];
			free(value);
			return CFBridgingRetain(seri);
		}

        // return (__bridge CFTypeRef)NG_searnalNumber;
    }
	// if([type isEqualToString:@"device-imei"]){
  
    //     return (__bridge CFTypeRef)NG_IMEI;
    // }

    CFTypeRef ref = old_IORegistryEntryCreateCFProperties(entry,key,allocator,options);

	// if ([type isEqualToString:@"unique-chip-id"]) {

	// 	NSData *d = __get_unique_chip_id();
	// 	if (d) {
	// 		return (__bridge CFTypeRef)d;
	// 	}

	// 	// {
	// 	// 	// NSData *d = (__bridge NSData *)ref;
	// 	// 	// unsigned char *p = (unsigned char *) [d bytes];
	// 	// 	// p[[d length] -1]++;

	// 	// 	NSData *d = (__bridge NSData *)ref;
	// 	// 	const unsigned char *p = (const unsigned char *) [d bytes];
	// 	// 	int i;
	// 	// 	char buf[1024];
	// 	// 	for(i = 0; i < [d length]; i++)
	// 	// 	{
	// 	// 		if (i > 0) {
	// 	// 			sprintf(buf + strlen(buf), ":%02hhX", p[i]);
	// 	// 		} else {
	// 	// 			sprintf(buf + strlen(buf), "%02hhX", p[i]);
	// 	// 		}				
	// 	// 	}
	// 	// 	remote_log("unique-chip-id-value: %s | %ld\n", buf, [d length]);
	// 	// }
	// }  else 
	
	// if ([type isEqualToString:@"mac-address-wifi0"]) {
	// 	NSData *d = __get_wifi_mac_data();
	// 	if (d) {
	// 		return (__bridge CFTypeRef)d;
	// 	}
	// } else 
	
	// if ([type isEqualToString:@"mac-address-bluetooth0"]) {
	// 	NSData *d = __get_bluetooth_mac_data();
	// 	if (d) {
	// 		return (__bridge CFTypeRef)d;
	// 	}
	// } 

	// if ([type isEqualToString:@"IOMACAddress"]) {

	// 	NSData *d = (__bridge NSData *)ref;
	// 	unsigned char *p = (unsigned char *) [d bytes];
	// 	if ([d length] > 0) {
	// 		p[0] = __wifi_mac_addr[0];
	// 		p[1] = __wifi_mac_addr[1];
	// 		p[2] = __wifi_mac_addr[2];
	// 		p[3] = __wifi_mac_addr[3];
	// 		p[4] = __wifi_mac_addr[4];
	// 		p[5] = __wifi_mac_addr[5];			
	// 	}
	// }
	
	// if ([type isEqualToString:@"local-mac-address"]) {
	// 	NSData *d = (__bridge NSData *)ref;
	// 	unsigned char *p = (unsigned char *) [d bytes];
	// 	if ([d length] > 0) {
	// 		p[0] = __bluetooth_mac_addr[0];
	// 		p[1] = __bluetooth_mac_addr[1];
	// 		p[2] = __bluetooth_mac_addr[2];
	// 		p[3] = __bluetooth_mac_addr[3];
	// 		p[4] = __bluetooth_mac_addr[4];
	// 		p[5] = __bluetooth_mac_addr[5];			
	// 	}
	// }

	// else if ([type isEqualToString:@"product-id"]) {
	// 	// NSData *d = (__bridge NSData *)ref;
	// 	// unsigned char *p = (unsigned char *) [d bytes];
	// 	// if ([d length] > 0) {
	// 	// 	p[[d length] -1]++;
	// 	// }
	// 	// NSData *d = (__bridge NSData *)ref;
	// 	// const unsigned char *p = (const unsigned char *) [d bytes];
	// 	// int i;
	// 	// char buf[1024];
	// 	// for(i = 0; i < [d length]; i++)
	// 	// {
	// 	// 	if (i > 0) {
	// 	// 		sprintf(buf + strlen(buf), ":%02hhX", p[i]);
	// 	// 	} else {
	// 	// 		sprintf(buf + strlen(buf), "%02hhX", p[i]);
	// 	// 	}				
	// 	// }
	// 	// remote_log("product-id-value: %s | %ld\n", buf, [d length]);
	// }
  

	return ref;
}
  
CFTypeRef
(*old_IORegistryEntrySearchCFProperty)(
        io_registry_entry_t	entry,
        const io_name_t		plane,
        CFStringRef		key,
        CFAllocatorRef		allocator,
        IOOptionBits		options );
CFTypeRef
new_IORegistryEntrySearchCFProperty(
        io_registry_entry_t	entry,
        const io_name_t		plane,
        CFStringRef		key,
        CFAllocatorRef		allocator,
        IOOptionBits		options ){

    NSString *type = (__bridge NSString *)key;

	// if (type) {
	// 	const char *content = [type UTF8String];
	// 	remote_log("get-2: %s\n", content);
	// }

	// if (!__change_info__) {
	// 	return old_IORegistryEntrySearchCFProperty(entry,plane,key,allocator,options);
	// }


    if([type isEqualToString:@"serial-number"]
		|| [type isEqualToString:@"IOPlatformSerialNumber"]){
        // return (__bridge CFTypeRef)[NG_searnalNumber dataUsingEncoding:NSUTF8StringEncoding];
		const char *value = wiiauto_device_db_get_share("system", "serialnumber");
		if (value) {
			NSString *seri = [NSString stringWithUTF8String:value];
			free(value);
			return CFBridgingRetain(seri);
		}
    }
	// if([type isEqualToString:@"device-imei"]){
  
    //     return (__bridge CFTypeRef)[NG_IMEI dataUsingEncoding:NSUTF8StringEncoding];
    // }

    CFTypeRef ref = old_IORegistryEntrySearchCFProperty(entry,plane,key,allocator,options);

	// if ([type isEqualToString:@"unique-chip-id"]) {
	// 	NSData *d = __get_unique_chip_id();
	// 	if (d) {
	// 		return (__bridge CFTypeRef)d;
	// 	}

	// 	// {
	// 	// 	int tid = CFGetTypeID(ref);
	// 	// 	CFStringRef sref = CFCopyTypeIDDescription(tid);
	// 	// 	NSString *r = (__bridge NSString *)sref;
	// 	// 	const char *content = [r UTF8String];
	// 	// 	remote_log("unique-chip-id-type: %s\n", content);
	// 	// }
	// 	// {
	// 	// 	NSData *d = (__bridge NSData *)ref;
	// 	// 	// unsigned char *p = (unsigned char *) [d bytes];
	// 	// 	// p[[d length] -1]++;

	// 	// 	const unsigned char *p = (const unsigned char *) [d bytes];
	// 	// 	int i;
	// 	// 	char buf[1024];
	// 	// 	for(i = 0; i < [d length]; i++)
	// 	// 	{
	// 	// 		if (i > 0) {
	// 	// 			sprintf(buf + strlen(buf), ":%02hhX", p[i]);
	// 	// 		} else {
	// 	// 			sprintf(buf + strlen(buf), "%02hhX", p[i]);
	// 	// 		}				
	// 	// 	}
	// 	// 	remote_log("unique-chip-id-value: %s | %ld\n", buf, [d length]);
	// 	// }
	// } else 
	
	// if ([type isEqualToString:@"mac-address-wifi0"]) {
	// 	NSData *d = __get_wifi_mac_data();
	// 	if (d) {
	// 		return (__bridge CFTypeRef)d;
	// 	}
	// } 
	
	// if ([type isEqualToString:@"mac-address-bluetooth0"]) {
	// 	NSData *d = __get_bluetooth_mac_data();
	// 	if (d) {
	// 		return (__bridge CFTypeRef)d;
	// 	}
	// } 

	// if ([type isEqualToString:@"IOMACAddress"]) {
	// 	NSData *d = (__bridge NSData *)ref;
	// 	unsigned char *p = (unsigned char *) [d bytes];
	// 	if ([d length] > 0) {
	// 		p[0] = __wifi_mac_addr[0];
	// 		p[1] = __wifi_mac_addr[1];
	// 		p[2] = __wifi_mac_addr[2];
	// 		p[3] = __wifi_mac_addr[3];
	// 		p[4] = __wifi_mac_addr[4];
	// 		p[5] = __wifi_mac_addr[5];			
	// 	}
	// }
	
	// if ([type isEqualToString:@"local-mac-address"]) {
	// 	NSData *d = (__bridge NSData *)ref;
	// 	unsigned char *p = (unsigned char *) [d bytes];
	// 	if ([d length] > 0) {
	// 		p[0] = __bluetooth_mac_addr[0];
	// 		p[1] = __bluetooth_mac_addr[1];
	// 		p[2] = __bluetooth_mac_addr[2];
	// 		p[3] = __bluetooth_mac_addr[3];
	// 		p[4] = __bluetooth_mac_addr[4];
	// 		p[5] = __bluetooth_mac_addr[5];			
	// 	}
	// }


	// else if ([type isEqualToString:@"product-id"]) {
	// 	// NSData *d = (__bridge NSData *)ref;
	// 	// unsigned char *p = (unsigned char *) [d bytes];
	// 	// if ([d length] > 0) {
	// 	// 	p[[d length] -1]++;
	// 	// }

	// 	// NSData *d = (__bridge NSData *)ref;
	// 	// const unsigned char *p = (const unsigned char *) [d bytes];
	// 	// int i;
	// 	// char buf[1024];
	// 	// for(i = 0; i < [d length]; i++)
	// 	// {
	// 	// 	if (i > 0) {
	// 	// 		sprintf(buf + strlen(buf), ":%02hhX", p[i]);
	// 	// 	} else {
	// 	// 		sprintf(buf + strlen(buf), "%02hhX", p[i]);
	// 	// 	}				
	// 	// }
	// 	// remote_log("product-id-value: %s | %ld\n", buf, [d length]);
	// }

	return ref;
}


static kern_return_t (*orig_IORegistryEntryGetChildIterator)(io_registry_entry_t entry, const io_name_t plane, io_iterator_t *iterator);
static kern_return_t new_IORegistryEntryGetChildIterator(io_registry_entry_t entry, const io_name_t plane, io_iterator_t *iterator)
{
	return orig_IORegistryEntryGetChildIterator(entry, plane, iterator);
}


// typedef struct CTResult {
//     int flag;
//     int a;
// } CTResult;

// typedef const struct __CTServerConnection * CTServerConnectionRef;

// #ifdef __arm__
// 	extern void _CTServerConnectionCopyMobileEquipmentInfo(CTResult *status, CTServerConnectionRef connection, CFMutableDictionaryRef *equipmentInfo);

// 	static int *(*orig_CTServerConnectionCopyMobileEquipmentInfo)(struct CTResult * Status, struct __CTServerConnection * Connection,CFMutableDictionaryRef * Dictionary);
// 	static int *new_CTServerConnectionCopyMobileEquipmentInfo(struct CTResult * Status, struct __CTServerConnection * Connection,CFMutableDictionaryRef * Dictionary)
// 	{
// 		remote_log("CTSERVER CALLED\n");
// 		return orig_CTServerConnectionCopyMobileEquipmentInfo(Status, Connection, Dictionary);
// 	}

// #elif defined __arm64__
// 	extern void _CTServerConnectionCopyMobileEquipmentInfo(CTServerConnectionRef connection, CFMutableDictionaryRef *equipmentInfo, NSInteger *unknown);

// 	static int *(*orig_CTServerConnectionCopyMobileEquipmentInfo)(CTServerConnectionRef connection, CFMutableDictionaryRef *equipmentInfo, NSInteger *unknown);
// 	static int *new_CTServerConnectionCopyMobileEquipmentInfo(CTServerConnectionRef connection, CFMutableDictionaryRef *equipmentInfo, NSInteger *unknown)
// 	{
// 		int *r = orig_CTServerConnectionCopyMobileEquipmentInfo(connection, equipmentInfo, unknown);

// 		@try {

// 			NSMutableDictionary *dict = (__bridge NSMutableDictionary *)*equipmentInfo;
// 			NSString *p = [NSString stringWithFormat:@"%@", dict];
// 			const char *content = [p UTF8String];
// 			remote_log("CTSERVER-64 CALLED: %s\n", content);

// 		} @catch (NSException *e) {}

// 		return r;
// 	}

// #endif

#include <sandbox.h>

int (*orig_sandbox_init)(const char *profile, uint64_t flags, char **errorbuf);

int new_sandbox_init(const char *profile, uint64_t flags, char **errorbuf)
{
	// remote_log("CALL SANDBOX\n");
	return orig_sandbox_init(profile, flags, errorbuf);
}

static void __check_sudden_kill()
{

}

// static void __try_smt()
// {
// 	// @autoreleasepool {

// 	// 	@try {

// 	// 		NSBundle *webKit = [NSBundle bundleWithIdentifier:@"com.apple.WebKit"];
// 	// 		NSString *version = [[webKit infoDictionary] objectForKey:@"CFBundleVersion"];

// 	// 		if (version) {
// 	// 			const char *ctr = [version UTF8String];
// 	// 			remote_log("webkit: %s\n", ctr);
// 	// 		}

			
// 	// 		NSString *v2 = [NSString stringWithFormat:@"%@", [[NSBundle bundleForClass:[WKWebView class]] infoDictionary] ];
// 	// 		if (v2) {
// 	// 			const char *ctr = [v2 UTF8String];
// 	// 			remote_log("wkwebview: %s\n", ctr);
// 	// 		}

// 	// 	} @catch (NSException *e) {

// 	// 	}

// 	// }

// 	// dispatch_after(dispatch_time(DISPATCH_TIME_NOW,1 * NSEC_PER_SEC), dispatch_get_main_queue() , ^{

// 		{
// 			float a = [[UIDevice currentDevice].systemVersion floatValue];
// 			remote_log("system_version: %f\n", a);
// 		}
// 		{
// 			NSProcessInfo *nspi = [NSProcessInfo processInfo];
// 			// NSOperatingSystemVersion ios8_0_1 = (NSOperatingSystemVersion){8, 0, 1};
// 			// if ([nspi isOperatingSystemAtLeastVersion:ios8_0_1]) {
// 			// 	// iOS 8.0.1 and above logic
// 			// } else {
// 			// 	// iOS 8.0.0 and below logic
// 			// }
// 			{
// 				NSString *o = [nspi operatingSystemVersionString];
// 				if (o) {
// 					remote_log("nspios: %s\n", [o UTF8String]);
// 				} else {
// 					remote_log("nspios-null\n");
// 				}
// 			}
// 			{
// 				NSString *o = [nspi operatingSystemName];
// 				if (o) {
// 					remote_log("nspiosname: %s\n", [o UTF8String]);
// 				} else {
// 					remote_log("nspiosname-null\n");
// 				}
// 			}
// 			{
// 				unsigned long long osn = [nspi operatingSystem];
// 				remote_log("nspiososn: %llu\n", osn);
// 			}
// 			{
// 				NSOperatingSystemVersion osn = [nspi operatingSystemVersion];
// 				remote_log("nspidetail: %d.%d.%d\n", osn.majorVersion, osn.minorVersion, osn.patchVersion);

// 	// 			NSInteger majorVersion;
//     // NSInteger minorVersion;
//     // NSInteger patchVersion;
// 			}
// 		}

// 	// });
// }

// int32_t (*orig___isOSVersionAtLeast)(int32_t Major, int32_t Minor, int32_t Subminor);
// int32_t new___isOSVersionAtLeast(int32_t Major, int32_t Minor, int32_t Subminor)
// {
// 	remote_log("test_isOSVersionAtLeast\n");
// 	return orig___isOSVersionAtLeast(Major, Minor, Subminor);
// }

%ctor
{	
	// if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"13.0")) {		
	// 	os_greater_than_12 = 1;
	// }
	
	// if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"11.0")) {		

		// __check_sudden_kill();

		// MSHookFunction(sandbox_init, new_sandbox_init, &orig_sandbox_init);

		__remove_obs();
		__spoof();
		file_register_global_url_parser(wiiauto_parse_url);		
		MSHookFunction(uname, repl_uname, &orig_uname);			
		// MSHookFunction(SecItemAdd, repl_SecItemAdd, &orig_SecItemAdd);		
		// MSHookFunction(SecItemCopyMatching, repl_SecItemCopyMatching, &orig_SecItemCopyMatching);		
		// MSHookFunction(SecItemUpdate, repl_SecItemUpdate, &orig_SecItemUpdate);		
		// MSHookFunction(SecItemDelete, repl_SecItemDelete, &orig_SecItemDelete);			
		// MSHookFunction(SecAccessControlCreateWithFlags, repl_SecAccessControlCreateWithFlags, &orig_SecAccessControlCreateWithFlags);	
		// MSHookFunction(NSSearchPathForDirectoriesInDomains, repl_NSSearchPathForDirectoriesInDomains, &orig_NSSearchPathForDirectoriesInDomains);	
		// MSHookFunction(glTexImage2D, my_glTexImage2D, &orig_glTexImage2D);	
		MSHookFunction(sysctl, my_sysctl, &orig_sysctl);
		MSHookFunction(IORegistryEntryCreateCFProperty, new_IORegistryEntryCreateCFProperties, &old_IORegistryEntryCreateCFProperties);
		MSHookFunction(IORegistryEntrySearchCFProperty, new_IORegistryEntrySearchCFProperty, &old_IORegistryEntrySearchCFProperty);
		// MSHookFunction(IORegistryEntryGetChildIterator, new_IORegistryEntryGetChildIterator, &orig_IORegistryEntryGetChildIterator);
		MSHookFunction(IORegistryEntryCreateCFProperties, new2_IORegistryEntryCreateCFProperties, &orig2_IORegistryEntryCreateCFProperties);
		// MSHookFunction(_CTServerConnectionCopyMobileEquipmentInfo, new_CTServerConnectionCopyMobileEquipmentInfo, &orig_CTServerConnectionCopyMobileEquipmentInfo);

		%init(WiiAuto);
		__listen_paste();
		__hide_facebook_jailbreak();
		__hook_mobilesms();

		// __try_smt();
		// {
		// 	@try {

		// 		NSString *stringPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,  NSUserDomainMask, YES) objectAtIndex:0];
		// 		if (stringPath) {
		// 			const char *content = [stringPath UTF8String];
		// 			if (content) {
		// 				remote_log("folder: %s\n", content);
		// 			}
		// 		}

		// 	} @catch (NSException *e) {}
		// }
	// }
	
}
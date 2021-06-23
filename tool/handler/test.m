#include "handler.h"
#import <notify.h>
#include "wiiauto/common/common.h"
#include "wiiauto/util/util.h"

#include "cherry/graphic/image.h"
#include "wiiauto/common/common.h"
#include "cherry/util/util.h"
#include "cherry/core/buffer.h"
#include "cherry/core/file.h"

#include "wiiauto/device/device.h"
#include "wiiauto/device/device_iohid.h"
#include <mach/mach_time.h>

#include <objc/runtime.h>
#import <dlfcn.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <sys/utsname.h>

#include "wiiauto/device/device_db.h"

@interface MCMContainer : NSObject
+ (instancetype)containerWithIdentifier:(NSString *)identifier createIfNecessary:(BOOL)createIfNecessary existed:(BOOL *)existed error:(NSError **)error;
- (NSURL *)url;
@end

@interface MCMAppDataContainer : MCMContainer
@end

@interface MCMPluginKitPluginDataContainer : MCMContainer
@end

@interface LSApplicationWorkspace : NSObject
+ (id)defaultWorkspace;
- (BOOL)_LSPrivateRebuildApplicationDatabasesForSystemApps:(BOOL)arg1 internal:(BOOL)arg2 user:(BOOL)arg3;
- (BOOL)registerApplicationDictionary:(NSDictionary *)applicationDictionary;
- (BOOL)registerBundleWithInfo:(NSDictionary *)bundleInfo options:(NSDictionary *)options type:(unsigned long long)arg3 progress:(id)arg4 ;
- (BOOL)registerApplication:(NSURL *)url;
- (BOOL)registerPlugin:(NSURL *)url;
- (BOOL)unregisterApplication:(NSURL *)url;
- (NSArray *)installedPlugins;
-(void)_LSPrivateSyncWithMobileInstallation;
@end

// extern CFTypeRef MGCopyAnswer(CFStringRef);

#import<CoreTelephony/CTCallCenter.h>    
#import<CoreTelephony/CTCall.h>   
#import<CoreTelephony/CTCarrier.h>    
#import<CoreTelephony/CTTelephonyNetworkInfo.h>

@interface CTMessageCenter : NSObject

+(id)sharedMessageCenter;
-(BOOL)sendSMSWithText:(id)arg1 serviceCenter:(id)arg2 toAddress:(id)arg3 withID:(unsigned)arg4 ;
-(BOOL)sendSMSWithText:(id)arg1 serviceCenter:(id)arg2 toAddress:(id)arg3 withMoreToFollow:(BOOL)arg4 withID:(unsigned)arg5 ;
-(BOOL)sendSMSWithText:(id)arg1 serviceCenter:(id)arg2 toAddress:(id)arg3 ;

@end

extern NSString* CTSettingCopyMyPhoneNumber();

static unsigned char *__hex_to_string(const char *str, size_t *slen)
{
    const char *ctr;
    char c;
    int val;
    int i;
    size_t len;
    unsigned char *ret;

    len = strlen(str) / 2 + 1;
    ret = malloc(len);
    *slen = len - 1;

    memset(ret, 0, len);

    i = 0;
    ctr = str;
    while (ctr && *ctr) {
        c = tolower(*ctr);

        if (c >= 97) {
            val = c - 87;
        } else {
            val = c - 48;
        }

        if (i % 2 == 0) {
            ret[i/2] = val << 4;
        } else {
            ret[i/2] |= val;
        }

        i++;
        ctr++;
    }

    return ret;
}

static double __hex_to_double(const char *str)
{
    size_t len;

    char *data = __hex_to_string(str, &len);
    double value = strtod(data, NULL);
    free(data);
    return value;
}

static int __hex_to_int(const char *str)
{
    size_t len;

    char *data = __hex_to_string(str, &len);
    int value = atoi(data);
    free(data);
    return value;
}

static int callback(void *connection, CFStringRef string, CFDictionaryRef dictionary, void *data) {
    return 0;
}

extern CFStringRef kCTRegistrationRATSelection0;
extern CFStringRef kCTRegistrationRATSelection1;
extern CFStringRef kCTRegistrationRATSelection2;
extern CFStringRef kCTRegistrationRATSelection3;
extern CFStringRef kCTRegistrationRATSelection4;
extern CFStringRef kCTRegistrationRATSelection5;
extern CFStringRef kCTRegistrationRATSelection6;
extern CFStringRef kCTRegistrationRATSelection7;
extern CFStringRef kCTRegistrationRATSelectionUnknown;

typedef const struct __CTServerConnection * CTServerConnectionRef;

extern CTServerConnectionRef _CTServerConnectionCreate(CFAllocatorRef, int (*)(void *, CFStringRef, CFDictionaryRef, void *), int *);

@interface RadiosPreferences : NSObject

-(void) setAirplaneMode:(BOOL)val;
-(void)setTelephonyState:(BOOL)arg1 fromBundleID:(id)arg2;

@end

#import <Contacts/Contacts.h>

// @interface CKMadridService  : NSObject

// + (id)sharedMadridService;

// @end

#include "xpc/xpc.h"

// @interface CKConversationList : NSObject

// +(id)sharedConversationList;
// -(id)conversationForExistingChatWithGroupID:(id)arg1;
// -(id)_conversationForChat:(id)arg1 ;
// -(id)conversationForHandles:(id)arg1 displayName:(id)arg2 joinedChatsOnly:(bool)arg3 create:(bool)arg4 ;
// @end

// @interface CKConversation : NSObject
// -(id)messageWithComposition:(id)arg1 ;
// -(void)sendMessage:(id)arg1 newComposition:(BOOL)arg2 ;
// -(BOOL)_sms_canSendToRecipients:(id)arg1 alertIfUnable:(BOOL)arg2 ;
// -(BOOL)_iMessage_canSendToRecipients:(id)arg1 alertIfUnable:(BOOL)arg2 ;
// +(id)conversationForAddresses:(id)arg1 allowRetargeting:(BOOL)arg2 candidateConversation:(id)arg3 ;
// +(id)newPendingConversation;
// -(void)setRecipients:(NSArray *)arg1 ;
// @end

// @interface CKComposition : NSObject

// -(id)initWithText:(id)arg1 subject:(id)arg2 ;

// @end

// @interface IMHandle : NSObject

// +(id)imHandlesForIMPerson:(id)arg1 ;
// -(id)initWithAccount:(id)arg1 ID:(id)arg2 ;

// @end

// @interface IMPerson : NSObject

// -(void)setPhoneNumbers:(NSArray *)arg1 ;

// @end

// @interface IDSIDQueryController
// + (instancetype)sharedInstance;
// - (NSDictionary *)_currentIDStatusForDestinations:(NSArray *)arg1 service:(NSString
// *)arg2 listenerID:(NSString *)arg3;
// @end

// @interface IMServiceImpl : NSObject
// + (instancetype)iMessageService;
// @end

// @interface IMAccount : NSObject
// - (IMHandle *)imHandleWithID:(NSString *)arg1 alreadyCanonical:(BOOL)arg2;
// @end
// @interface IMAccountController : NSObject
// + (instancetype)sharedInstance;
// - (IMAccount *)__ck_defaultAccountForService:(IMServiceImpl *)arg1;
// @end

// static int __matrid_status(NSString *address)
// {
// 	NSString *formattedAddress = nil;
// 	if ([address rangeOfString:@"@"].location != NSNotFound) 
// 		formattedAddress = [@"mailto:" stringByAppendingString:address];
// 	else 
// 		formattedAddress = [@"tel:" stringByAppendingString:address];
// 	NSDictionary *status = [[IDSIDQueryController sharedInstance] 
// 		_currentIDStatusForDestinations:@[formattedAddress] service:@"com.apple.madrid"
// 		listenerID:@"__kIMChatServiceForSendingIDSQueryControllerListenerID"];
// 	return [status[formattedAddress] intValue];
// }

// static void __handle_mobilesms()
// {
// 	IMServiceImpl *service = [IMServiceImpl iMessageService];
// 	IMAccount *account = [[IMAccountController sharedInstance] __ck_defaultAccountForService:service];

// 	IMHandle *im1 = [account imHandleWithID:@"+84981590889" alreadyCanonical:NO];
// 	IMHandle *im2 = [account imHandleWithID:@"+84857523333" alreadyCanonical:NO];
// 	IMHandle *im3 = [account imHandleWithID:@"+84762198586" alreadyCanonical:NO];

// 	CKConversationList* conversationList = [CKConversationList sharedConversationList];
//     CKConversation *conversation = [conversationList conversationForHandles:[NSMutableArray arrayWithObjects:im3, nil] displayName:@"Kết bạn" joinedChatsOnly:false create:true]; //"11111111" would be the receivers phone number

//     //Make a new composition
//     NSAttributedString* text = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"We are getting there!"]];
//     CKComposition* composition = [[CKComposition alloc] initWithText:text subject:nil];

//     //A new message from the composition
//     id message = [conversation messageWithComposition:composition];
// 	int status = __matrid_status(@"+84762198586");
// 	// 1 : imessage
// 	// 2 : sms
// 	if (status == 1) {
// 		[conversation sendMessage:message newComposition:YES];
// 	}
// }

extern NSString* CTSettingCopyMyPhoneNumber();
#include "log/remote_log.h"

#import <objc/NSObject.h>

@class MCMClientIdentity, MCMCommandQueue, MCMUserIdentityCache, NSArray, NSDictionary, NSMutableDictionary, NSString;
@protocol OS_dispatch_queue;

@interface MCMClientConnection : NSObject

+ (id)sharedClientConnection;
- (void)rebootContainerManagerCleanupWithCompletion:(id)arg1;
- (void)rebootContainerManagerSetup;
- (void)_cleanupOprhanedCodeSigningMappingData;
- (void)_cleanupOrphanedDataForDirectories:(id)arg1 containerClass:(unsigned long long)arg2;
- (void)containerManagerCleanupWithCompletion:(id)arg1;
- (void)containerManagerSetup;
@end

void wiiauto_tool_run_test(const int argc, const char **argv)
{
    wiiauto_device_init();
    wiiauto_tool_register();   

    [[objc_getClass("MCMClientConnection") sharedClientConnection] rebootContainerManagerCleanupWithCompletion:nil];
    [[objc_getClass("MCMClientConnection") sharedClientConnection] rebootContainerManagerSetup];
    [[objc_getClass("MCMClientConnection") sharedClientConnection] _cleanupOprhanedCodeSigningMappingData];

    // {
    //     /* change app info */
    //     @try {
    //         NSString* path = [NSString stringWithUTF8String:argv[2]];
    //         NSMutableDictionary* dict = [NSDictionary dictionaryWithContentsOfFile:path].mutableCopy; 
            
    //         dict[@"BreakpadVersion"] = @"87.0.4280.76";
    //         dict[@"CFBundleShortVersionString"] = @"87.4280.76";
            
    //         [dict writeToFile:path atomically:YES];
    //         dict = nil;
    //     } @catch (NSException *e) {
    //     }
    // }

    // __handle_mobilesms();

    // NSString *phone = CTSettingCopyMyPhoneNumber();

    // printf("phone: %s\n", [phone UTF8String]);

    // usleep(2000000);

    // CKMadridService *madridService = [CKMadridService sharedMadridService];
    // //NSString *foo = [madridService _temporaryFileURLforGUID:@"A5F70DCD-F145-4D02-B308-B7EA6C248BB2"];

    // NSLog(@"Sending SMS");
    // conversationList = [CKConversationList sharedConversationList];
    // CKSMSEntity *ckEntity = [madridService copyEntityForAddressString:Phone];
    // CKConversation *conversation = [conversationList conversationForRecipients:[NSArray arrayWithObject:ckEntity] create:TRUE service:smsService];
    // NSString *groupID = [conversation groupID];           
    // CKSMSMessage *ckMsg = [madridService _newSMSMessageWithText:msg forConversation:conversation];
    // [madridService sendMessage:ckMsg];
    // [ckMsg release];  

    // BOOL success = [[CTMessageCenter sharedMessageCenter] sendSMSWithText:@"Hello!" serviceCenter:@"com.apple.madrid" toAddress:@"+84762198586"];
    // NSLog (@"Sending the message was %@", success ? @"successful" : @"unsuccessful");
    // usleep(2000000);

    // dispatch_queue_t queue = dispatch_queue_create("com.apple.chatkit.clientcomposeserver.xpc_connection_queue", DISPATCH_QUEUE_SERIAL);
    // xpc_connection_t connection = xpc_connection_create_mach_service("com.apple.chatkit.clientcomposeserver.xpc", queue, 0);
    // xpc_connection_set_event_handler(connection, ^(xpc_object_t event){
    //     xpc_type_t xtype = xpc_get_type(event); 
    //     if(XPC_TYPE_ERROR == xtype)
    //     {
    //     NSLog(@"XPC sandbox connection error: %s\n", xpc_dictionary_get_string(event, XPC_ERROR_KEY_DESCRIPTION));
    //     }
    //     // Always set an event handler. More on this later.

    //     NSLog(@"Received an message event!");

    // });
    // xpc_connection_resume(connection);

    // xpc_object_t dictionary = xpc_dictionary_create(0, 0, 0);
    // xpc_dictionary_set_int64(dictionary, "message-type", 0);
    // NSData* recipients = [NSPropertyListSerialization dataWithPropertyList:[NSArray arrayWithObjects:@"+84762198586", nil] format:NSPropertyListBinaryFormat_v1_0 options:0 error:NULL];
    // xpc_dictionary_set_data(dictionary, "recipients", recipients.bytes, recipients.length);
    // xpc_dictionary_set_string(dictionary, "text", "Hello MAN");

    // xpc_connection_send_message(connection, dictionary);
    // xpc_connection_send_barrier(connection, ^{
    //     NSLog(@"Message has been successfully delievered");
    // });
    // usleep(5000000);

    // dlopen("/System/Library/PrivateFrameworks/MobileContainerManager.framework/MobileContainerManager", RTLD_NOW);

    // @try
    // {
    //     NSURL *fileManagerURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:@"group.com.facebook.Facebook"];
    //     if (fileManagerURL) {
    //         NSString *tmpPath = [NSString stringWithFormat:@"%@", fileManagerURL.path];
    //         if (tmpPath) {
    //             printf("1: %s\n", [tmpPath UTF8String]);
    //         }
    //     } else {
    //     }
    // } @catch (NSException *e) {

    // }

    //  @try
    // {
    //     NSURL *fileManagerURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:@"group.com.facebook.Messenger"];
    //     if (fileManagerURL) {
    //         NSString *tmpPath = [NSString stringWithFormat:@"%@", fileManagerURL.path];
    //         if (tmpPath) {
    //             printf("2: %s\n", [tmpPath UTF8String]);
    //         }
    //     } else {
    //     }
    // } @catch (NSException *e) {

    // }

    //  @try
    // {
    //     NSURL *fileManagerURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:@"group.com.facebook.family"];
    //     if (fileManagerURL) {
    //         NSString *tmpPath = [NSString stringWithFormat:@"%@", fileManagerURL.path];
    //         if (tmpPath) {
    //             printf("3: %s\n", [tmpPath UTF8String]);
    //         }
    //     } else {
    //     }
    // } @catch (NSException *e) {

    // }

    // @try
    // {
    //     NSURL *fileManagerURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:@"group.com.google.Gmail"];
    //     if (fileManagerURL) {
    //         NSString *tmpPath = [NSString stringWithFormat:@"%@", fileManagerURL.path];
    //         if (tmpPath) {
    //             printf("4: %s\n", [tmpPath UTF8String]);
    //         }
    //     } else {
    //     }
    // } @catch (NSException *e) {

    // }

    // wiiauto_device_db_multi_add("test", "test", "text 1");
    // wiiauto_device_db_multi_add("test", "test", "text 2");
    // wiiauto_device_db_multi_add("test", "test", "text 3");
    // wiiauto_device_db_multi_add("test", "test", "text 4");

    // char *value = NULL;
    // int index = 0;
    // while (index >= 0) {
    //     value = wiiauto_device_db_multi_get("test", "test", index);
    //     if (!value) break;

    //     printf("%s\n", value);
        
    //     free(value);
    //     index++;
    // }

    // wiiauto_device_db_keychain_set_bundle_state("com.facebook.Facebook", "state3");
    
    // char *data = NULL;
    // size_t len = 0;

    // wiiauto_device_db_keychain_get_bundle_state("com.me.app", &data);
    // if (data) {
    //     printf("%s\n", data);
    //     free(data);
    // }

    // wiiauto_device_db_keychain_set_value("state1", NULL, 0, "k1", 2, "v1", 2);
    // wiiauto_device_db_keychain_get_value("state1", NULL, 0, "k1", 2, &data, &len, 0);
    // if (data) {
    //     char *str = malloc(len + 1);
    //     strncpy(str, data, len);
    //     printf("data: %s\n", str);
    //     free(data);
    //     free(str);
    // }

    // wiiauto_device_db_keychain_set_value("state1", "acc1", 4, "k1", 2, "v9", 2);
    // wiiauto_device_db_keychain_get_value("state1", "acc1", 4, "k1", 2, &data, &len, 0);
    // if (data) {
    //     char *str = malloc(len + 1);
    //     strncpy(str, data, len);
    //     printf("data: %s\n", str);
    //     free(data);
    //     free(str);
    // }

    // wiiauto_device_db_set_blob_share("default", "default", strlen("default"), "TEST", 4);

    // char *data = NULL;
    // size_t len = 0;

    // wiiauto_device_db_get_blob_share("default", "default", strlen("default"), &data, &len);
    // if (data) {
    //     char *str = malloc(len + 1);
    //     strncpy(str, data, len);
    //     printf("data: %s\n", str);
    //     free(data);
    //     free(str);
    // } else {
    //     printf("empty\n");
    // }










    // if (argc != 3) return;

    // if (strcmp(argv[2], "delete") == 0) {

    //     CNContactStore *contactStore = [[CNContactStore alloc] init];

    //     [contactStore requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
    //         if (granted == YES) {
    //             NSArray *keys = @[CNContactPhoneNumbersKey];
    //             NSString *containerId = contactStore.defaultContainerIdentifier;
    //             NSPredicate *predicate = [CNContact predicateForContactsInContainerWithIdentifier:containerId];
    //             NSError *error;
    //             NSArray *cnContacts = [contactStore unifiedContactsMatchingPredicate:predicate keysToFetch:keys error:&error];

    //             if (error) {
    //                 NSLog(@"error fetching contacts %@", error);
    //             } else {
    //                 // for (CNContact *contact in cnContacts) {
    //                 //     NSLog(@"contact");
    //                 // }
    //                 CNSaveRequest *saveRequest = [[CNSaveRequest alloc] init];

    //                 for (CNContact *contact in cnContacts) {
    //                     [saveRequest deleteContact:[contact mutableCopy]];
    //                 }

    //                 [contactStore executeSaveRequest:saveRequest error:nil];
    //                 NSLog(@"Deleted contacts %lu", cnContacts.count);
    //             }
    //         }
    //     }];



    // } else if (strcmp(argv[2], "add") == 0) {

    //     CNContactStore *store = [[CNContactStore alloc] init];

    //     [store requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
    //         if (!granted) {
    //             return;
    //         }

    //         // create contact

    //         CNMutableContact *contact = [[CNMutableContact alloc] init];
    //         contact.familyName = @"Doe";
    //         contact.givenName = @"John";

    //         CNLabeledValue *homePhone = [CNLabeledValue labeledValueWithLabel:CNLabelPhoneNumberMobile value:[CNPhoneNumber phoneNumberWithStringValue:@"84343342603"]];
    //         contact.phoneNumbers = @[homePhone];

    //         CNSaveRequest *request = [[CNSaveRequest alloc] init];
    //         [request addContact:contact toContainerWithIdentifier:nil];

    //         // save it

    //         NSError *saveError;
    //         if (![store executeSaveRequest:request error:&saveError]) {
    //             NSLog(@"error = %@", saveError);
    //         }
    //     }];

    // }



















    // size_t len;

    // NSBundle *bundle = [NSBundle bundleWithPath:@"/System/Library/PrivateFrameworks/AppSupport.framework"];
    // BOOL success = [bundle load];

    // // Class RadiosPreferences = NSClassFromString(@"RadiosPreferences");
    // RadiosPreferences *radioPreferences = [[RadiosPreferences alloc] init];
    // // [radioPreferences setAirplaneMode:YES]; // Turns airplane mode on
    // [radioPreferences setTelephonyState:NO fromBundleID:@""];
    // usleep(1000000);

    // char* sdk_path = "/System/Library/Frameworks/CoreTelephony.framework/CoreTelephony"; //path of this Undocumented API
    // int* handle = dlopen(sdk_path,RTLD_LAZY);
    // if(handle == NULL){
    //     return;
    // }
    // int t1;

    // struct CTServerConnection * (*CTServerConnectionCreate)() = dlsym(handle,"_CTServerConnectionCreate");
    
    // CTServerConnectionRef ctsc = _CTServerConnectionCreate(kCFAllocatorDefault, callback, NULL);

    // void (*start)(CTServerConnectionRef) = dlsym(handle, "_CTServerConnectionStartCellTracking");
    // void (*stop)(CTServerConnectionRef) = dlsym(handle, "_CTServerConnectionStopCellTracking");
    
    // stop(ctsc);
    // usleep(1000000);
    // start(ctsc);

    // void (*CTServerConnectionSetRATSelection)() = dlsym(handle, "_CTServerConnectionSetRATSelection");
    // void (*start)(CTServerConnectionRef) = dlsym(handle, "_CTServerConnectionCellMonitorStart");
    // void (*stop)(CTServerConnectionRef) = dlsym(handle, "_CTServerConnectionCellMonitorStop");
    
    // stop(ctsc);
    // usleep(1000000);
    // start(ctsc);
    // CTServerConnectionSetRATSelection(&t1, sc, kCTRegistrationRATSelection6,kCTRegistrationRATSelection6);


    // const char *str = "người bạn";

    // if (strstr(str, "bạn")) {
    //     printf("ok\n");
    // }

    // const char *str = __hex_to_string("636F6D2E6170706C652E69636C6F75642E736561726368706172747964", &len);
    // printf("%s , %d, %d\n", str, len, strlen(str));

    // printf("%lf\n", __hex_to_double("3631323935383939342E313534303531"));
    
    // printf("%d\n", __hex_to_int("31"));

    // {
    //     NSString *s = [[UIDevice currentDevice] model];
    //     NSLog(@"DeviceType: %@", s);
    // }

    // {
    //     NSString *s = [[UIDevice currentDevice] name];
    //     NSLog(@"DeviceName: %@", s);
    // }

    // {
    //     struct utsname systemInfo;
    //     uname(&systemInfo);
    //     NSString *s = [NSString stringWithCString:systemInfo.machine
    //                                     encoding:NSUTF8StringEncoding];

    //     NSLog(@"DeviceModel: %@", s);
    // }

    // {
    //     NSString *s = [[UIDevice currentDevice] systemVersion];
    //     NSLog(@"OSVersion: %@", s);
    // }

    // NSString *phone = CTSettingCopyMyPhoneNumber();

    // NSLog(@"phone: %@", phone);

    // file f;
    // file_new(&f);
    
    // file_open_write(f, "wiiauto_internal://temp.txt");

    // exit(0);

    // file_write(f, "Hello World", strlen("Hello World"));

    // exit(0);

    // dlopen("/System/Library/PrivateFrameworks/MobileContainerManager.framework/MobileContainerManager", RTLD_NOW);

    // @autoreleasepool {

    //     @try {
    //         MCMContainer *appContainer = [objc_getClass("MCMAppDataContainer") containerWithIdentifier:[NSString stringWithUTF8String:argv[2]] createIfNecessary:NO existed:nil error:nil];
    //         NSString *containerPath = [appContainer url].path;
    //         NSLog(@"%@", containerPath);
    //     } @catch (NSException *e) {

    //     }
    // }

}

// void wiiauto_tool_run_test(const int argc, const char **argv)
// {
//     {
//         NSLog(@"class-1: %@", NSStringFromClass([[NSLocale currentLocale] class]));
//     }
//     {
//         NSLog(@"class-2: %@", NSStringFromClass([[UIDevice currentDevice] class]));
//     }
//     {
//         NSString *code = [[NSLocale currentLocale] countryCode];
//         NSString *name = [[NSLocale currentLocale] localizedStringForCountryCode: code];

//         NSLog(@"code: %@", code);
//         NSLog(@"name: %@", name);
//     }
//     {
//         NSString *code = [[NSLocale currentLocale] objectForKey: NSLocaleCountryCode];
//         NSString *name = [[NSLocale currentLocale] localizedStringForCountryCode: code];

//         NSLog(@"code: %@", code);
//         NSLog(@"name: %@", name);
//     }
//     // {
//     //     NSUserDefaults *prefs = [[NSUserDefaults alloc] initWithSuiteName:@"com.tonyk7.MGSpoofHelperPrefsSuite"];
// 	//     // NSDictionary *modifiedKeys = [prefs objectForKey:@"modifiedKeys"];
//     //     // modifiedKeys[@"UserAssignedDeviceName"] = @"Happy Phone";
//     //     // notify_post("com.tonyk7.mgspoof/modifiedKeyUpdated");
//     //     NSMutableDictionary *newDict = ((NSDictionary *)[prefs objectForKey:@"modifiedKeys"]).mutableCopy;
//     //     if (!newDict) {
//     //         [prefs setValue:@{} forKey:@"modifiedKeys"];
//     //         newDict = @{}.mutableCopy;
//     //     }
//     //     newDict[@"UserAssignedDeviceName"] = @"Happy Phone";
//     //     [prefs setValue:newDict forKey:@"modifiedKeys"];
//     //     notify_post("com.tonyk7.mgspoof/modifiedKeyUpdated");
//     // }
//     // {
//     //     NSString *retVal = nil;
//     //     CFTypeRef modelNumber = MGCopyAnswer(CFSTR("ModelNumber"));
//     //     if(modelNumber) {
//     //         CFTypeRef regionInfo = MGCopyAnswer(CFSTR("RegionInfo"));
//     //         if(regionInfo) {
//     //             retVal = [NSString stringWithFormat:@"%@ | %@", (__bridge NSString *)modelNumber, (__bridge NSString *)regionInfo];
//     //             CFRelease(regionInfo);
//     //         }
//     //         CFRelease(modelNumber);
//     //     }
//     //     if (retVal) {
//     //         NSLog(@"test: %@", retVal);
//     //     }
//     // }
//     // {
//     //     NSString *s = [[NSLocale currentLocale] countryCode];
//     //     NSLog(@"regionCode: %@", s);
//     // }
//     // {
//     //     NSString *s = [[UIDevice currentDevice] model];
//     //     NSLog(@"model: %@", s);
//     // }
//     // {
//     //     NSString *s = [[UIDevice currentDevice] localizedModel];
//     //     NSLog(@"localizedModel: %@", s);
//     // }
//     {
//         NSString *s = [[UIDevice currentDevice] name];
//         NSLog(@"name: %@", s);
//     }
//     {
//         NSString *s = [[UIDevice currentDevice] systemName];
//         NSLog(@"systemName: %@", s);
//     }
//     {
//         NSString *s = [[UIDevice currentDevice] systemVersion];
//         NSLog(@"systemVersion: %@", s);
//     }
//     // {
//     //     CFTypeRef t = MGCopyAnswer(CFSTR("BuildVersion"));
//     //     if (t) {
//     //         NSLog(@"MG_buildVersion: %@", (__bridge NSString *)t);
//     //         CFRelease(t);
//     //     }
//     // }
//     // {
//     //     CFTypeRef t = MGCopyAnswer(CFSTR("DeviceName"));
//     //     if (t) {
//     //         NSLog(@"MG_DeviceName: %@", (__bridge NSString *)t);
//     //         CFRelease(t);
//     //     }
//     // }
//     // {
//     //     CFTypeRef t = MGCopyAnswer(CFSTR("UserAssignedDeviceName"));
//     //     if (t) {
//     //         NSLog(@"MG_UserAssignedDeviceName: %@", (__bridge NSString *)t);
//     //         CFRelease(t);
//     //     }
//     // }
//     // {
//     //     CFTypeRef t = MGCopyAnswer(CFSTR("HWModelStr"));
//     //     if (t) {
//     //         NSLog(@"MG_HWModelStr: %@", (__bridge NSString *)t);
//     //         CFRelease(t);
//     //     }
//     // }
//     // {
//     //     CFTypeRef t = MGCopyAnswer(CFSTR("RegionCode"));
//     //     if (t) {
//     //         NSLog(@"MG_RegionCode: %@", (__bridge NSString *)t);
//     //         CFRelease(t);
//     //     }
//     // }
//     // {
//     //     CFTypeRef t = MGCopyAnswer(CFSTR("DeviceClass"));
//     //     if (t) {
//     //         NSLog(@"MG_DeviceClass: %@", (__bridge NSString *)t);
//     //         CFRelease(t);
//     //     }
//     // }
//     // {
//     //     CFTypeRef t = MGCopyAnswer(CFSTR("ProductType"));
//     //     if (t) {
//     //         NSLog(@"MG_ProductType: %@", (__bridge NSString *)t);
//     //         CFRelease(t);
//     //     }
//     // }

//     {
//         NSString *s = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
//         NSLog(@"vendorid: %@", s);
//     }
// }
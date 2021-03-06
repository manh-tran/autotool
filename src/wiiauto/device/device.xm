#include "device.h"
#include "device_iohid.h"
#include "device_gs.h"
#include "device_db.h"
#include <dlfcn.h>
#include <objc/runtime.h>
#include <mach/mach_port.h>
#include <mach/mach_init.h>
#include <sys/sysctl.h>
#include <sys/time.h>
#include "log/remote_log.h"
#import <mach/port.h>
#import <mach/kern_return.h>

#if defined __cplusplus
extern "C" {
#endif

#include "cherry/core/file.h"

__wiiauto_pixel *__device_screen_buffer__ = NULL;

#if defined __cplusplus
}
#endif

#import <GraphicsServices/GSEvent.h>

#import <IOSurface/IOSurfaceRef.h>
#import <IOKit/IOKitLib.h>

#import "IOMobileFramebuffer.h"
#import "IOSurfaceAccelerator.h"

template <typename Type_>
static void dlset(Type_ &function, const char *name) {
    function = reinterpret_cast<Type_>(dlsym(RTLD_DEFAULT, name));
}

/*
 * interfaces
 */
@interface SpringBoard : NSObject
-(void)resetIdleTimerAndUndim:(BOOL)fp8; 
-(void)resetIdleTimerAndUndim;
-(unsigned)_frontmostApplicationPort;
-(id)_accessibilityFrontMostApplication;
@end

@interface SBApplication : NSObject
-(NSString *)bundleIdentifier;
@end

@interface SBUserAgent
+(id)sharedUserAgent;
-(void)undimScreen;
@end

@interface SBAwayController : NSObject
+ (id)sharedAwayController;
- (BOOL)undimsDisplay;
- (id)awayView;
- (void)lock;
- (void)_unlockWithSound:(BOOL)fp8;
- (void)unlockWithSound:(BOOL)fp8;
- (void)unlockWithSound:(BOOL)fp8 alertDisplay:(id)fp12;
- (void)loadPasscode;
- (id)devicePasscode;
- (BOOL)isPasswordProtected;
- (void)activationChanged:(id)fp8;
- (BOOL)isDeviceLockedOrBlocked;
- (void)setDeviceLocked:(BOOL)fp8;
- (void)applicationRequestedDeviceUnlock;
- (void)cancelApplicationRequestedDeviceLockEntry;
- (BOOL)isBlocked;
- (BOOL)isPermanentlyBlocked:(double *)fp8;
- (BOOL)isLocked;
- (void)attemptUnlock;
- (BOOL)isAttemptingUnlock;
- (BOOL)attemptDeviceUnlockWithPassword:(id)fp8 alertDisplay:(id)fp12;
- (void)cancelDimTimer;
- (void)restartDimTimer:(float)fp8;
- (id)dimTimer;
- (BOOL)isDimmed;
- (void)finishedDimmingScreen;
- (void)dimScreen:(BOOL)fp8;
- (void)undimScreen;
- (void)userEventOccurred;
- (void)activate;
- (void)deactivate;
@end

@interface SBBrightnessController : NSObject
+ (id)sharedBrightnessController;
- (void)adjustBacklightLevel:(BOOL)fp8;
@end

@interface SBLockScreenManager
+(id)sharedInstance;
-(void)unlockUIFromSource:(int)source withOptions:(id)options;
@property(readonly, assign) BOOL isUILocked;
@end

@interface SBBacklightController : NSObject
+(id) sharedInstance;
-(void) turnOnScreenFullyWithBacklightSource:(int)num;
-(BOOL) screenIsOn;
-(BOOL) screenIsDim;
-(void) _undimFromSource:(long long)arg1;
-(BOOL) shouldTurnOnScreenForBacklightSource:(long long)arg1 ;
@end

/*
 * static variables
 */
static GSEventRef  (*$GSEventCreateKeyEvent)(int, CGPoint, CFStringRef, CFStringRef, uint32_t, UniChar, short, short);
static GSEventRef  (*$GSCreateSyntheticKeyEvent)(UniChar, BOOL, BOOL);
static void        (*$GSEventSetKeyCode)(GSEventRef event, uint16_t keyCode);

static CGSize (*$GSMainScreenSize)(void);
static float (*$GSMainScreenScaleFactor)(void);
static float (*$GSMainScreenOrientation)(void);

static float screen_width = 320;
static float screen_height = 480;
static float retina_factor = 1.0f;
static float screen_orientation = 0.0f;
static __wiiauto_device_orientation screen_rotation = WIIAUTO_DEVICE_ORIENTATION_UNKNOWN;
static __wiiauto_device_orientation app_orientation = WIIAUTO_DEVICE_ORIENTATION_UNKNOWN;
static int is_iPad1 = 0;
static Class $SBAwayController = objc_getClass("SBAwayController");
static void (*$IOHIDEventSetSenderID)(IOHIDEventRef event, uint64_t senderID) = NULL;

static IOSurfaceRef current_surface = NULL;
static u64 last_milliseconds = 0;
static u8 keyboard_on = 0;
static u8 alert_on = 0;
static u8 enable_log = 0;
static u8 enable_toast = 0;
static u8 has_new_gps_location = 0;

void wiiauto_device_is_toast_enable(u8 *on)
{
    *on = enable_toast;
}

void wiiauto_device_is_log_enable(u8 *on)
{
    *on = enable_log;
}

void wiiauto_device_set_toast(const u8 on)
{
    enable_toast = on;
}

void wiiauto_device_set_log(const u8 on)
{
    enable_log = on;
}

/*
 * functions
 */
extern "C" void CARenderServerRenderDisplay(kern_return_t a, CFStringRef b, IOSurfaceRef surface, int x, int y);

static u64 current_timestamp() 
{
    struct timeval te; 
    gettimeofday(&te, NULL);
    u64 milliseconds = te.tv_sec*1000LL + te.tv_usec/1000;
    return milliseconds;
}

static void init_graphicsservices(void)
{
    dlset($GSEventCreateKeyEvent, "GSEventCreateKeyEvent");
    dlset($GSCreateSyntheticKeyEvent, "_GSCreateSyntheticKeyEvent");
    dlset($GSEventSetKeyCode, "GSEventSetKeyCode");

    dlset($GSMainScreenSize, "GSMainScreenSize");
    dlset($GSMainScreenScaleFactor, "GSMainScreenScaleFactor");
    dlset($GSMainScreenOrientation, "GSMainScreenOrientation");

    dlset($IOHIDEventSetSenderID, "IOHIDEventSetSenderID");
}

static void detect_iPads(void){
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char machine[size];
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    is_iPad1 = strcmp(machine, "iPad1,1") == 0;
}

static void __refresh_orientation()
{
    static spin_lock barrier = SPIN_LOCK_INIT;

    lock(&barrier);

    if ($GSMainScreenOrientation){
        screen_orientation = $GSMainScreenOrientation();
    }

    if (is_iPad1) {
        screen_rotation = WIIAUTO_DEVICE_ORIENTATION_LANDSCAPE_LEFT;
    } else if (screen_orientation == 0.0f) {
        screen_rotation = WIIAUTO_DEVICE_ORIENTATION_PORTRAIT;
    } else {
        screen_rotation = WIIAUTO_DEVICE_ORIENTATION_LANDSCAPE_RIGHT;
    }

    unlock(&barrier);
}

void wiiauto_device_get_orientation(__wiiauto_device_orientation *o)
{
    __refresh_orientation();

    *o = screen_rotation;
}

void wiiauto_device_get_app_orientation(__wiiauto_device_orientation *o)
{
    *o = app_orientation;
}


// static void __attribute__((constructor)) __device_in()
static void __device_in()
{
    init_graphicsservices();
    detect_iPads();

    if ($GSMainScreenScaleFactor) {
        retina_factor = $GSMainScreenScaleFactor();
    }
    if ($GSMainScreenSize){
        CGSize screenSize = $GSMainScreenSize();
        screen_width = screenSize.width / retina_factor;
        screen_height = screenSize.height / retina_factor;
    }
    
    __refresh_orientation();
}

void wiiauto_device_init()
{
    static int __init = 0;

    if (!__init) {
        __init = 1;
        __device_in();
    }
}

static void __attribute__((destructor)) __device_out()
{
    // if (current_surface) {
    //     CFRelease(current_surface);
    //     current_surface = NULL;
    // }
}

void wiiauto_device_get_screen_size(float *width, float *height)
{
    *width = screen_width;
    *height = screen_height;
}

void wiiauto_device_get_retina_factor(float *factor)
{
    *factor = retina_factor;
}

void wiiauto_device_is_locked(u8 *flag)
{ 
    *flag = 0;

    @try {
        if ($SBAwayController){
            *flag = [[$SBAwayController sharedAwayController] isLocked] ? 1 : 0;
        }        
        if (%c(SBLockScreenManager)) {
            SBLockScreenManager * sbLockScreenManager = (SBLockScreenManager*) [%c(SBLockScreenManager) sharedInstance];
            *flag = [sbLockScreenManager isUILocked] ? 1 : 0;
            sbLockScreenManager = nil;
        }
    }  @catch (NSException *e) {
        
    }
}

void wiiauto_device_is_screen_on(u8 *flag)
{
    @try {
        SBBacklightController *c = [%c(SBBacklightController) sharedInstance];
        *flag = [c screenIsOn] ? 1 : 0;
        c = nil;
    } @catch (NSException *e) {
        *flag = 1;
    }    
}

void wiiauto_device_unlock()
{
    if ($SBAwayController){                   
        bool wasDimmed = [[$SBAwayController sharedAwayController] isDimmed ];
        bool wasLocked = [[$SBAwayController sharedAwayController] isLocked ];
        
        if ( wasDimmed || wasLocked ){
            [[$SBAwayController sharedAwayController] attemptUnlock];
            [[$SBAwayController sharedAwayController] unlockWithSound:NO];
        }
    }
    if (%c(SBLockScreenManager)){
        SBLockScreenManager * sc = (SBLockScreenManager*) [%c(SBLockScreenManager) sharedInstance];
        if ([sc isUILocked]) {
            [sc unlockUIFromSource:0 withOptions:nil];
        }
    }
}

void wiiauto_device_undim_display()
{
    @try {
        if ($SBAwayController){
            [(SpringBoard *)[%c(SpringBoard) sharedApplication] resetIdleTimerAndUndim:YES];
        }
    } @catch (NSException *e) {}

    if (%c(SBLockScreenManager)){
        @try {
            SBUserAgent * sbUserAget = [%c(SBUserAgent) sharedUserAgent];
            [sbUserAget undimScreen];
        } @catch (NSException *e) {}

        @try {
            [(SpringBoard *)[%c(SpringBoard) sharedApplication] resetIdleTimerAndUndim];
        } @catch (NSException *e) {}
    }
}

void wiiauto_device_iohid_send(IOHIDEventRef event)
{
    static IOHIDEventSystemClientRef ioSystemClient = NULL;
    static spin_lock barrier = SPIN_LOCK_INIT;

    lock(&barrier);
    if (!ioSystemClient){
        ioSystemClient = IOHIDEventSystemClientCreate(kCFAllocatorDefault);
    }    

    if (event) {
        IOHIDEventSystemClientDispatchEvent(ioSystemClient, event);
        CFRelease(event);
    }
    unlock(&barrier);    
}

void wiiauto_device_iohid_set_sender_id(IOHIDEventRef event, uint64_t senderID)
{
    if ($IOHIDEventSetSenderID) {
        ($IOHIDEventSetSenderID)(event, senderID);
    }
}

#include "wiiauto/util/util.h"

void wiiauto_device_get_current_screen_buffer(const __wiiauto_pixel **ptr, u32 *buf_width, u32 *buf_height)
{
    static u64 __last__ = 0;
    static spin_lock __barrier__ = 0;

    lock(&__barrier__);
    u64 cm = current_timestamp();
    if (cm - __last__ >= 20) {
        __last__ = cm;
        wiiauto_util_fill_screenbuffer((u8 *)__device_screen_buffer__);
    }
    unlock(&__barrier__);

    *ptr = __device_screen_buffer__;
    *buf_width = screen_width * retina_factor;
    *buf_height = screen_height * retina_factor;
}

// /*
//  * keyboard listener
//  */
// @interface wiiauto_keyboard_listener : NSObject

// @end

// @implementation wiiauto_keyboard_listener

// + (wiiauto_keyboard_listener *) shared {
//     static wiiauto_keyboard_listener *sListener;    

//     if ( nil == sListener ) {
//         sListener = [[wiiauto_keyboard_listener alloc] init];
//     }

//     return sListener;
// }

// - (instancetype)init 
// {
//     self = [super init];
    
//     NSNotificationCenter *center = [NSNotificationCenter defaultCenter];

//     [center addObserver:self selector:@selector(didShow:) name:UIKeyboardDidShowNotification object:nil];
//     [center addObserver:self selector:@selector(didHide:) name:UIKeyboardWillHideNotification object:nil];

//     return self;
// }

// - (void)dealloc 
// {
//     [[NSNotificationCenter defaultCenter] removeObserver:self];
// }

// -(void)didShow:(NSNotification *)notification 
// {
//     keyboard_on = 1;
// }

// -(void)didHide:(NSNotification *)notification 
// {
//     keyboard_on = 0;
// }

// @end

// void wiiauto_device_register_keyboard_notification()
// {   
//     static u8 __reg__ = 0;
//     if (__reg__) return;

//     __reg__ = 1;

//     dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue() , ^{        
//         [wiiauto_keyboard_listener shared];
//     });
// }

// void wiiauto_device_is_keyboard_on(u8 *on)
// {
//     *on = keyboard_on;
// }

// /*
//  * alert listener
//  */
// static void notify_alert_on(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
//     alert_on = 1;
// }

// static void notify_alert_off(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
//     alert_on = 0;
// }

// void wiiauto_device_register_alert_notification()
// {
//     static u8 __reg__ = 0;
//     if (__reg__) return;

//     __reg__ = 1;

//     CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), 
//         NULL, 
//         notify_alert_on,
//         CFSTR("WIIAUTO_ALERT_VIEW_ON"), 
//         NULL, 
//         CFNotificationSuspensionBehaviorCoalesce);

//     CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), 
//         NULL, 
//         notify_alert_off,
//         CFSTR("WIIAUTO_ALERT_VIEW_OFF"), 
//         NULL, 
//         CFNotificationSuspensionBehaviorCoalesce);
// }

// void wiiauto_device_is_alert_on(u8 *on)
// {
//     *on = alert_on;
// }

/*
 * app orientation listener
 */
static void notify_app_orientation_portrait(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) 
{

    app_orientation = WIIAUTO_DEVICE_ORIENTATION_PORTRAIT;
}

static void notify_app_orientation_landscape_left(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) 
{
    app_orientation = WIIAUTO_DEVICE_ORIENTATION_LANDSCAPE_LEFT;
}

static void notify_app_orientation_landscape_right(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) 
{
    app_orientation = WIIAUTO_DEVICE_ORIENTATION_LANDSCAPE_RIGHT;
}

static void notify_app_orientation_portrait_upside_down(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) 
{
    app_orientation = WIIAUTO_DEVICE_ORIENTATION_PORTRAIT_UPSIDE_DOWN;
}

void wiiauto_device_register_app_orientation_notification()
{
    static u8 __reg__ = 0;
    if (__reg__) return;

    __reg__ = 1;

    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), 
        NULL, 
        notify_app_orientation_portrait,
        CFSTR("WIIAUTO_APP_ORIENTATION_PORTRAIT"), 
        NULL, 
        CFNotificationSuspensionBehaviorCoalesce);

    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), 
        NULL, 
        notify_app_orientation_portrait_upside_down,
        CFSTR("WIIAUTO_APP_ORIENTATION_PORTRAIT_UPSIDE_DOWN"), 
        NULL, 
        CFNotificationSuspensionBehaviorCoalesce);

    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), 
        NULL, 
        notify_app_orientation_landscape_left,
        CFSTR("WIIAUTO_APP_ORIENTATION_LANDSCAPE_LEFT"), 
        NULL, 
        CFNotificationSuspensionBehaviorCoalesce);

    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), 
        NULL, 
        notify_app_orientation_landscape_right,
        CFSTR("WIIAUTO_APP_ORIENTATION_LANDSCAPE_RIGHT"), 
        NULL, 
        CFNotificationSuspensionBehaviorCoalesce);
}

// /*
//  * new gps notification
//  */
// static void notify_has_new_gps_location(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) 
// {
//     has_new_gps_location = 1;
// }

// void wiiauto_device_is_having_new_gps(u8 *r)
// {
//     *r = has_new_gps_location;
// }

// void wiiauto_device_set_having_new_gps(const u8 r)
// {
//     has_new_gps_location = r;
// }

// void wiiauto_device_register_new_gps_notification()
// {
//     static u8 __reg__ = 0;
//     if (__reg__) return; 

//     __reg__ = 1;

//     CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), 
//         NULL, 
//         notify_has_new_gps_location,
//         CFSTR("WIIAUTO_HAS_NEW_GPS_LOCATION"), 
//         NULL, 
//         CFNotificationSuspensionBehaviorCoalesce);
// }

/*
 * GS key 
 */
static bool isSBUserNotificationAlertVisible(void){

    if (!%c(UIApplication)) return NO;
    if (!%c(UIAlertView)) return NO;

    UIView * keyWindow = [[%c(UIApplication) sharedApplication] keyWindow];
    if (!keyWindow) return false;
    if (![keyWindow.subviews count]) return false;
    UIView * firstSubview = [keyWindow.subviews objectAtIndex:0];
    return [firstSubview isKindOfClass:[%c(UIAlertView) class]];
}

static void sendGSEvent(GSEventRecord *eventRecord, int port)
{
    if (port) {
        GSSendEvent(eventRecord, port);
    } else {
        GSSendSystemEvent(eventRecord);
    }
}

void wiiauto_device_gs_post_character(int down, unichar unicode, int port)
{
    CFStringRef string = NULL;
    GSEventRef  event  = NULL;
    GSEventType type = down ? kGSEventKeyDown : kGSEventKeyUp;

    int keycode = 0;
    uint32_t flags = (GSEventFlags) 0;

    if ($GSEventCreateKeyEvent) {

        string = CFStringCreateWithCharacters(kCFAllocatorDefault, &unicode, 1);
        event = (*$GSEventCreateKeyEvent)(type, CGPointMake(100, 100), string, string, (GSEventFlags) flags, 0, 0, 1);
        if ($GSEventSetKeyCode) {
            (*$GSEventSetKeyCode)(event, keycode);
        }
    } else if ($GSCreateSyntheticKeyEvent && down) { 

        event = (*$GSCreateSyntheticKeyEvent)(unicode, down, YES);
        GSEventRecord *record((GSEventRecord*) _GSEventGetGSEventRecord(event));
        record->type = kGSEventSimulatorKeyDown;
        record->flags = (GSEventFlags) flags;

    } else {
        return;
    }

    if (isSBUserNotificationAlertVisible()) {
        GSSendSystemEvent((GSEventRecord*) _GSEventGetGSEventRecord(event));
    } else {
        sendGSEvent((GSEventRecord*) _GSEventGetGSEventRecord(event), port);
    }
        
    if (string){
        CFRelease(string);
    }
    CFRelease(event);
}

static buffer __serial_number__ = {id_null};
static spin_lock __serial_barrier__ = SPIN_LOCK_INIT;

void wiiauto_device_get_serial_number(const buffer b)
{
    lock(&__serial_barrier__);

    if (!id_validate(__serial_number__.iobj)) {

        buffer_new(&__serial_number__);

        char *serial = wiiauto_device_db_get_system("system", "serialnumber");
        if (serial) {
            buffer_append(__serial_number__, serial, strlen(serial));
            free(serial);
        } else {

            NSString *serialNumber = nil;
            const char *ptr;
            
            void *IOKit = dlopen("/System/Library/Frameworks/IOKit.framework/IOKit", RTLD_NOW);
            if (IOKit)
            {
                mach_port_t *kIOMasterPortDefault = (mach_port_t *)dlsym(IOKit, "kIOMasterPortDefault");
                CFMutableDictionaryRef (*IOServiceMatching)(const char *name) = (CFMutableDictionaryRef (*)(const char *name))dlsym(IOKit, "IOServiceMatching");
                mach_port_t (*IOServiceGetMatchingService)(mach_port_t masterPort, CFDictionaryRef matching) = (mach_port_t (*)(mach_port_t masterPort, CFDictionaryRef matching))dlsym(IOKit, "IOServiceGetMatchingService");
                CFTypeRef (*IORegistryEntryCreateCFProperty)(mach_port_t entry, CFStringRef key, CFAllocatorRef allocator, uint32_t options) = (CFTypeRef (*)(mach_port_t entry, CFStringRef key, CFAllocatorRef allocator, uint32_t options))dlsym(IOKit, "IORegistryEntryCreateCFProperty");
                kern_return_t (*IOObjectRelease)(mach_port_t object) = (kern_return_t (*)(mach_port_t object))dlsym(IOKit, "IOObjectRelease");
                
                if (kIOMasterPortDefault && IOServiceGetMatchingService && IORegistryEntryCreateCFProperty && IOObjectRelease)
                {
                    mach_port_t platformExpertDevice = IOServiceGetMatchingService(*kIOMasterPortDefault, IOServiceMatching("IOPlatformExpertDevice"));
                    if (platformExpertDevice)
                    {
                        CFTypeRef platformSerialNumber = IORegistryEntryCreateCFProperty(platformExpertDevice, CFSTR("IOPlatformSerialNumber"), kCFAllocatorDefault, 0);
                        if (platformSerialNumber && CFGetTypeID(platformSerialNumber) == CFStringGetTypeID())
                        {
                            serialNumber = [NSString stringWithString:(__bridge NSString *)platformSerialNumber];
                            CFRelease(platformSerialNumber);
                        }
                        IOObjectRelease(platformExpertDevice);
                    }
                }
                dlclose(IOKit);
            }  
            if (serialNumber) {
                ptr = [serialNumber UTF8String];
                buffer_append(__serial_number__, ptr, strlen(ptr));
                wiiauto_device_db_set_system("system", "serialnumber", ptr);
            }
            serialNumber = nil;
        }
    }
    unlock(&__serial_barrier__);

    buffer_erase(b);
    buffer_append_buffer(b, __serial_number__);
}

#include <sys/stat.h>

void __wiiauto_device_sys_log(const char *ptr, const int size)
{
    static spin_lock __local__ = SPIN_LOCK_INIT;

    lock(&__local__);

    struct stat st;
    stat(WIIAUTO_ROOT_SYS_LOG_FILE_PATH, &st);
    u32 fsize = st.st_size;

    file f;

    file_new(&f);
    if (fsize >= 1024 * 1024) {
        file_open_write(f, WIIAUTO_ROOT_SYS_LOG_FILE_PATH);
    } else {
        file_open_append(f, WIIAUTO_ROOT_SYS_LOG_FILE_PATH);   
    }    
    file_write(f, ptr, size);
    file_write(f, "\n", 1);
    release(f.iobj);

    unlock(&__local__);
}
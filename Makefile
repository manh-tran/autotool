INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

rwildcard=$(foreach d,$(wildcard $(1:=/*)),$(call rwildcard,$d,$2) $(filter $(subst *,%,$2),$d))

LIBRARY_NAME = libwiiautodynamic
libwiiautodynamic_INSTALL_PATH = /usr/local/lib
libwiiautodynamic_FILES = $(call rwildcard,src,*.c) $(call rwildcard,src,*.m)  $(call rwildcard,src,*.mm)  $(call rwildcard,src,*.xm) $(call rwildcard,src,*.x)
libwiiautodynamic_CFLAGS = -fobjc-arc -Isrc -Iexternal/include -Wno-error -DSQLITE_ENABLE_SNAPSHOT -DLUA_USE_DLOPEN -DLUA_USE_POSIX -I3rdParty -DLUA_COMPAT_MODULE -IFrameworks/OpenSSL/include -IFrameworks/png/include -IFrameworks/jpeg/include -Wno-deprecated -Wno-deprecated-declarations
libwiiautodynamic_FRAMEWORKS = Foundation
libwiiautodynamic_PRIVATE_FRAMEWORKS = NanoRegistry IDS IMCore ChatKit AppSupport NetworkExtension WebKit AuthKit ProgressUI BackBoardServices CoreTelephony BluetoothManager QuartzCore GraphicsServices IOKit AudioToolbox Foundation CoreFoundation UIKit IOKit IOSurface IOMobileFramebuffer IOSurfaceAccelerator BackBoardServices StoreKit
libwiiautodynamic_LIBRARIES = substrate MobileGestalt
libwiiautodynamic_LDFLAGS = -LFrameworks/OpenSSL/lib -Lexternal/lib/ioslua -Lexternal/lib/cherry -LFrameworks/png/lib -LFrameworks/jpeg/lib -FFrameworks -lioslua -lcherry -lsubstrate -lssl -lcrypto -lpng -ljpeg -w -lpthread
libwiiautodynamic_CODESIGN_FLAGS = -Sents.plist

TWEAK_NAME = wiiauto

wiiauto_FILES = Tweak.x
wiiauto_CFLAGS = -fobjc-arc -Isrc  -Iexternal/include -Wno-error -DLUA_USE_DLOPEN -DLUA_USE_POSIX -I3rdParty -DLUA_COMPAT_MODULE -IFrameworks/OpenSSL/include -IFrameworks/png/include -IFrameworks/jpeg/include -Wno-deprecated -Wno-deprecated-declarations
wiiauto_FRAMEWORKS = Foundation
wiiauto_PRIVATE_FRAMEWORKS = NanoRegistry IDS IMCore ChatKit AppSupport NetworkExtension WebKit AuthKit ProgressUI BackBoardServices CoreTelephony BluetoothManager QuartzCore GraphicsServices IOKit AudioToolbox Foundation CoreFoundation UIKit IOKit IOSurface IOMobileFramebuffer IOSurfaceAccelerator BackBoardServices StoreKit
wiiauto_LIBRARIES = substrate wiiautodynamic MobileGestalt
wiiauto_LDFLAGS = -L.theos/obj -LFrameworks/OpenSSL/lib -Lexternal/lib/ioslua -Lexternal/lib/cherry -LFrameworks/png/lib -LFrameworks/jpeg/lib -FFrameworks -lioslua -lcherry -lsubstrate -lssl -lcrypto -lpng -ljpeg -w -lpthread
wiiauto_CODESIGN_FLAGS = -Sents.plist

TOOL_NAME = wiiauto_run

wiiauto_run_FILES = $(call rwildcard,tool,*.c) $(call rwildcard,tool,*.cpp) $(call rwildcard,tool,*.m)  $(call rwildcard,tool,*.mm)  $(call rwildcard,tool,*.xm) $(call rwildcard,tool,*.x)
wiiauto_run_CFLAGS = -fobjc-arc -Isrc  -Iexternal/include -Wno-error -DLUA_USE_DLOPEN -DLUA_USE_POSIX -I3rdParty -DLUA_COMPAT_MODULE -IFrameworks/OpenSSL/include -IFrameworks/png/include -IFrameworks/jpeg/include -Wno-deprecated -Wno-deprecated-declarations
wiiauto_run_FRAMEWORKS = Foundation
wiiauto_run_PRIVATE_FRAMEWORKS = IDS IMCore ChatKit AppSupport NetworkExtension WebKit AuthKit ProgressUI BackBoardServices QuartzCore GraphicsServices IOKit AudioToolbox Foundation CoreFoundation UIKit IOKit IOSurface IOMobileFramebuffer IOSurfaceAccelerator BackBoardServices StoreKit
wiiauto_run_LIBRARIES = substrate wiiautodynamic MobileGestalt
wiiauto_run_LDFLAGS = -L.theos/obj -LFrameworks/OpenSSL/lib -Lexternal/lib/ioslua -Lexternal/lib/cherry -LFrameworks/png/lib -LFrameworks/jpeg/lib -lioslua -lcherry -FFrameworks -lsubstrate -lssl -lcrypto -lpng -ljpeg -w -lpthread
wiiauto_run_CODESIGN_FLAGS = -Sents.plist

# BUNDLE_NAME = com.wiimob.wiiauto
# com.wiimob.wiiauto_INSTALL_PATH = /var/mobile/Library/WiiAuto/Resources_inner

include $(THEOS_MAKE_PATH)/library.mk
include $(THEOS_MAKE_PATH)/tweak.mk
include $(THEOS_MAKE_PATH)/tool.mk
# include $(THEOS_MAKE_PATH)/application.mk
# include $(THEOS)/makefiles/bundle.mk
# include $(THEOS_MAKE_PATH)/aggregate.mk

before-package::
	cp ./bin/postinst ./.theos/_/DEBIAN/
	cp ./bin/prerm ./.theos/_/DEBIAN/
	rm -rf ./packages/*.deb
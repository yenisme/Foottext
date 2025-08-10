ARCHS = arm64 
THEOS_PLATFORM_DEB_COMPRESSION_TYPE = xz
FINALPACKAGE = 1
FOR_RELEASE = 1
include $(THEOS)/makefiles/common.mk

TWEAK_NAME = yenios

$(TWEAK_NAME)_CFLAGS =  -fobjc-arc -Wno-deprecated-declarations -Wno-unused-variable -Wno-unused-value

$(TWEAK_NAME)_FILES =  FPSDisplay.m 

include $(THEOS_MAKE_PATH)/tweak.mk
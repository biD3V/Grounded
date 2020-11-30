TARGET := iphone:clang:latest:13.6
ARCHS = arm64 arm64e
INSTALL_TARGET_PROCESSES = SpringBoard


include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Grounded

Grounded_FILES = Tweak.x
Grounded_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += groundedprefs
include $(THEOS_MAKE_PATH)/aggregate.mk

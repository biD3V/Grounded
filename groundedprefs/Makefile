TARGET := iphone:clang:latest:13.6
ARCHS = arm64 arm64e

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = GroundedPrefs

GroundedPrefs_FILES = GRDRootListController.m GRDConnectivityListController.m GRDModulesListController.m Localize.m
GroundedPrefs_FRAMEWORKS = UIKit
GroundedPrefs_PRIVATE_FRAMEWORKS = Preferences ControlCenterServices
GroundedPrefs_INSTALL_PATH = /Library/PreferenceBundles
GroundedPrefs_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk

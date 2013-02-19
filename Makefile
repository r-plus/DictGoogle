ARCHS = armv7
TARGET = iphone:clang::5.0
include theos/makefiles/common.mk

TWEAK_NAME = DictGoogle
DictGoogle_FILES = Tweak.xm
DictGoogle_FRAMEWORKS = UIKit
THEOS_INSTALL_KILL=MobileNotes

include $(THEOS_MAKE_PATH)/tweak.mk


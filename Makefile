include theos/makefiles/common.mk

TWEAK_NAME = DictGoogle
DictGoogle_FILES = Tweak.xm
DictGoogle_FRAMEWORKS= UIKit

include $(THEOS_MAKE_PATH)/tweak.mk

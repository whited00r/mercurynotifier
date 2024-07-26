THEOS_DEVICE_IP = 192.168.1.20
GO_EASY_ON_ME = 1
include $(THEOS)/makefiles/common.mk

TWEAK_NAME = MercuryNotifier
MercuryNotifier_FILES = Tweak.xm
MercuryNotifier_FRAMEWORKS = UIKit Foundation

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"

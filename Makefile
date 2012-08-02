GO_EASY_ON_ME = 1

include theos/makefiles/common.mk

TWEAK_NAME = PocketPlanesTweaks
PocketPlanesTweaks_FILES = Functions.mm Lists.xm Map.xm PlayerData.xm PPTSettingsViewController.mm Scene.xm Settings.xm Tweak.xm
PocketPlanesTweaks_FRAMEWORKS = CoreGraphics OpenGLES UIKit Foundation
SUBPROJECTS = pocketplanestweakspreferences

include $(THEOS_MAKE_PATH)/tweak.mk
include $(THEOS_MAKE_PATH)/aggregate.mk

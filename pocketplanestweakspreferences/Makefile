include theos/makefiles/common.mk

BUNDLE_NAME = PocketPlanesTweaksPreferences
PocketPlanesTweaksPreferences_FILES = PocketPlanesTweaksPreferences.mm
PocketPlanesTweaksPreferences_INSTALL_PATH = /Library/PreferenceBundles
PocketPlanesTweaksPreferences_FRAMEWORKS = UIKit
PocketPlanesTweaksPreferences_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/PocketPlanesTweaksPreferences.plist$(ECHO_END)

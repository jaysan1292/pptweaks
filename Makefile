GO_EASY_ON_ME = 1

include theos/makefiles/common.mk

TWEAK_NAME = PocketPlanesTweaks
PocketPlanesTweaks_FILES = Tweak.xm Settings.xm
# PocketPlanesTweaks_FILES += IASKAppSettingsViewController.m IASKAppSettingsWebViewController.m IASKPSSliderSpecifierViewCell.m IASKPSTextFieldSpecifierViewCell.m IASKPSTitleValueSpecifierViewCell.m IASKSettingsReader.m IASKSettingsStore.m IASKSettingsStoreFile.m IASKSettingsStoreUserDefaults.m IASKSlider.m IASKSpecifier.m IASKSpecifierValuesViewController.m IASKSwitch.m IASKTextField.m
PocketPlanesTweaks_FRAMEWORKS = CoreGraphics OpenGLES UIKit Foundation
# PocketPlanesTweaks_PRIVATE_FRAMEWORKS = InAppSettingsKit
SUBPROJECTS = pocketplanestweakspreferences

include $(THEOS_MAKE_PATH)/tweak.mk
include $(THEOS_MAKE_PATH)/aggregate.mk

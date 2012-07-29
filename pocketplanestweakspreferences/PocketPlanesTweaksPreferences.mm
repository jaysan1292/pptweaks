#import <Preferences/Preferences.h>
#import "../Tweak.h"

@interface PocketPlanesTweaksPreferencesListController: PSListController {
}
@end

@implementation PocketPlanesTweaksPreferencesListController
- (id)specifiers {
	if(_specifiers == nil) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"PocketPlanesTweaksPreferences" target:self] retain];
	}
	return _specifiers;
}
@end

// vim:ft=objc

#import "Tweak.h"

#import "InAppSettingsKit/IASKAppSettingsViewController.h"
#import "InAppSettingsKit/IASKAppSettingsWebViewController.h"
#import "InAppSettingsKit/IASKSpecifierValuesViewController.h"
#import "InAppSettingsKit/IASKViewController.h"
#import "InAppSettingsKit/IASKSettingsReader.h"
#import "InAppSettingsKit/IASKSettingsStore.h"
#import "InAppSettingsKit/IASKSettingsStoreFile.h"
#import "InAppSettingsKit/IASKSettingsStoreUserDefaults.h"
#import "InAppSettingsKit/IASKSpecifier.h"
#import "InAppSettingsKit/IASKPSSliderSpecifierViewCell.h"
#import "InAppSettingsKit/IASKPSTextFieldSpecifierViewCell.h"
#import "InAppSettingsKit/IASKPSTitleValueSpecifierViewCell.h"
#import "InAppSettingsKit/IASKSlider.h"
#import "InAppSettingsKit/IASKSwitch.h"
#import "InAppSettingsKit/IASKTextField.h"

#define tweakButtonImage @"/Library/PreferenceBundles/PocketPlanesTweaksPreferences.bundle/tweak_settings_button.png"
#define tweakButtonImagePressed @"/Library/PreferenceBundles/PocketPlanesTweaksPreferences.bundle/tweak_settings_button_pressed.png"
#define tweakButtonSprite [%c(PPSpriteFactory) spriteWithFile:tweakButtonImage]
#define tweakButtonSpritePressed [%c(PPSpriteFactory) spriteWithFile:tweakButtonImagePressed]

static BOOL enabled;                    // default: NO
static BOOL twitterEnabled;             // default: YES
static BOOL soundOnNewJobs;             // default: NO
static BOOL planeLandingNotifications;  // default: YES
static BOOL sortEventProgress;          // default: NO
static BOOL mapOverviewEnabled;         // default: NO
static BOOL hidePlaneLabels;            // default: NO
static BOOL moreDetailedTime;           // default: NO
static BOOL tripPickerPlanes;           // default: YES
static BOOL eventJobsOnTop;             // default: NO

static BOOL isTweakButtonPressed = NO;

/*
@interface PPTSettingsController : UIViewController {
}
@end

@implementation PPTSettingsController
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}
-(void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];

    // Release any cached data, images, etc that aren't in use.
}
-(void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}
-(void)dealloc {
    [super dealloc];
}
@end
*/

@implementation PPTSettings
+(void)reconfigure {
#define getBoolValue(val) [[dict objectForKey:val] boolValue]
    debug(@"+[PPTSettings reconfigure]");
    NSDictionary* dict = [[NSDictionary alloc] initWithContentsOfFile:[PPTSettings pathOfSettingsFile]];

    enabled = getBoolValue(@"Enabled");
    twitterEnabled = getBoolValue(@"TwitterEnabled");
    soundOnNewJobs = getBoolValue(@"SoundOnNewJobs");
    planeLandingNotifications = getBoolValue(@"PlaneLandingNotifications");
    sortEventProgress = getBoolValue(@"SortEventProgress");
    mapOverviewEnabled = getBoolValue(@"MapOverviewEnabled");
    hidePlaneLabels = getBoolValue(@"HidePlaneLabels");
    moreDetailedTime = getBoolValue(@"MoreDetailedTime");
    tripPickerPlanes = getBoolValue(@"TripPickerPlanes");
    eventJobsOnTop = getBoolValue(@"EventJobsOnTop");

    log(@"twitterEnabled? %@", boolToString(twitterEnabled));
    log(@"soundOnNewJobs? %@", boolToString(soundOnNewJobs));
    log(@"planeLandingNotifications? %@", boolToString(planeLandingNotifications));
    log(@"sortEventProgress? %@", boolToString(sortEventProgress));
    log(@"mapOverviewEnabled? %@", boolToString(mapOverviewEnabled));
    log(@"hidePlaneLabels? %@", boolToString(hidePlaneLabels));
    log(@"moreDetailedTime? %@", boolToString(moreDetailedTime));
    log(@"tripPickerPlanes? %@", boolToString(tripPickerPlanes));
    log(@"eventJobsOnTop? %@", boolToString(eventJobsOnTop));

    [dict release];
#undef getBoolValue(val)
}
+(void)setup {
    debug(@"+[PPTSettings setup]");
    [PPTSettings reconfigure];
}
+(NSString*)pathOfSettingsFile {
    return @"/var/mobile/Library/Preferences/com.jaysan1292.pptweaksprefs.plist";
}

+(BOOL)enabled { return enabled; }
+(BOOL)twitterEnabled { return twitterEnabled; }
+(BOOL)soundOnNewJobs { return soundOnNewJobs; }
+(BOOL)planeLandingNotifications { return planeLandingNotifications; }
+(BOOL)sortEventProgress { return sortEventProgress; }
+(BOOL)mapOverviewEnabled { return mapOverviewEnabled; }
+(BOOL)hidePlaneLabels { return hidePlaneLabels; }
+(BOOL)moreDetailedTime { return moreDetailedTime; }
+(BOOL)tripPickerPlanes { return tripPickerPlanes; }
+(BOOL)eventJobsOnTop { return eventJobsOnTop; }
#ifdef DBG
+(void)setEnabled:(BOOL)val { enabled = val; }
+(void)setTwitterEnabled:(BOOL)val { twitterEnabled = val; }
+(void)setSoundOnNewJobs:(BOOL)val { soundOnNewJobs = val; }
+(void)setPlaneLandingNotifications:(BOOL)val { planeLandingNotifications = val; }
+(void)setSortEventProgress:(BOOL)val { sortEventProgress = val; }
+(void)setMapOverviewEnabled:(BOOL)val { mapOverviewEnabled = val; }
+(void)setHidePlaneLabels:(BOOL)val { hidePlaneLabels = val; }
+(void)setMoreDetailedTime:(BOOL)val { moreDetailedTime = val; }
+(void)setTripPickerPlanes:(BOOL)val { tripPickerPlanes = val; }
+(void)setEventJobsOnTop:(BOOL)val { eventJobsOnTop = val; }
#endif
@end

%hook PPSettingsLayer //{
/* cycript stuff
var settingslayer = [[PPScene sharedScene]menuLayer]
var btn = object_getIvar(settingslayer, class_getInstanceVariable([settingslayer class], "resetAwardsButton"))
var tweakBtn = [settingslayer.children objectAtIndex:19]
var tweakBtnShadow = [tweakBtn.children objectAtIndex:0]
*/
-(BOOL)ccTouchBegan:(UITouch*)began withEvent:(UIEvent*)event {
    #define tweakSettingBtn ((CCNode*)[[self children] objectAtIndex:19])

    CGPoint location = [self convertTouchToNodeSpace:began];
    CGRect tweakBtnRect = CGRectMake(271,96,154,28);

    if(CGRectContainsPoint(tweakBtnRect, location)) {
        debug(@"Tweak settings button pressed!");
        isTweakButtonPressed = YES;
        
        CCSprite* overlay = [%c(PPSpriteFactory) spriteWithFile:tweakButtonImage];
        [overlay setOpacity:128];
        [overlay setColor:ccBLACK];
        [overlay setPosition:ccp(0,0)];
        [overlay setIsRelativeAnchorPoint:NO];
        [overlay setScale:1];
        [tweakSettingBtn addChild:overlay z:1];
        
        return kEventHandled;
    } else {
        return %orig;
    }
}
-(void)ccTouchEnded:(UITouch*)ended withEvent:(UIEvent*)event {
    #define overlay [[tweakSettingBtn children] objectAtIndex:1]
    %orig;

    if(isTweakButtonPressed) {
        isTweakButtonPressed = NO;
        [tweakSettingBtn removeChild:overlay cleanup:YES];
        [self showTweakSettings];
    }
}
-(void)onEnter {
    debug(@"-[PPSettingsLayer onEnter]");
    %orig;

    CCSprite* tweakBtn = [%c(PPSpriteFactory) spriteWithFile:tweakButtonImage];
    tweakBtn.position = ccp(348, 110);

    [self addChild:tweakBtn];

    CCSprite* shadow = [%c(PPSpriteFactory) spriteWithFile:tweakButtonImage];
    [shadow setOpacity:75];
    [shadow setColor:ccGRAY];
    [shadow setPosition:ccp(1,-1)];
    [shadow setIsRelativeAnchorPoint:NO];
    [shadow setScale:1];
    [tweakBtn addChild:shadow z:-1];

    debug(@"Added tweak settings button.");
}
-(void)dealloc {
    debug(@"-[PPSettingsLayer dealloc]");
    %orig;
}
%new -(void)showTweakSettings {
    debug(@"-[PPSettingsLayer showTweakSettings]");
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Coming soon!" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil]; [alert show]; [alert release];
    // IASKAppSettingsViewController* viewController = [[IASKAppSettingsViewController alloc] init];
    // viewController.delegate = self;
    
    // [viewController setShowCreditsFooter:NO];
    // [viewController release];
}
%new -(void)settingsViewControllerDidEnd:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
    [PPTSettings reconfigure];
}
%end //}

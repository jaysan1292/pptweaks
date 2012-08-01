#import "Tweak.h"
#import "PPTSettingsViewController.h"

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
    NSDictionary* dict = [[NSDictionary alloc] initWithContentsOfFile:[PPTSettings pathOfUserSettingsFile]];

    enabled = getBoolValue(@"Enabled");
    if(enabled) {
        twitterEnabled = getBoolValue(@"TwitterEnabled");
        soundOnNewJobs = getBoolValue(@"SoundOnNewJobs");
        planeLandingNotifications = getBoolValue(@"PlaneLandingNotifications");
        sortEventProgress = getBoolValue(@"SortEventProgress");
        mapOverviewEnabled = getBoolValue(@"MapOverviewEnabled");
        hidePlaneLabels = getBoolValue(@"HidePlaneLabels");
        moreDetailedTime = getBoolValue(@"MoreDetailedTime");
        tripPickerPlanes = getBoolValue(@"TripPickerPlanes");
        eventJobsOnTop = getBoolValue(@"EventJobsOnTop");
    } else {
        twitterEnabled = YES;
        soundOnNewJobs = NO;
        planeLandingNotifications = YES;
        sortEventProgress = NO;
        mapOverviewEnabled = NO;
        hidePlaneLabels = NO;
        moreDetailedTime = NO;
        tripPickerPlanes = YES;
        eventJobsOnTop = NO;
    }
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
+(NSString*)pathOfUserSettingsFile {
    return @"/var/mobile/Library/Preferences/com.jaysan1292.pptweaksprefs.plist";
}
+(NSString*)pathOfSettingsFile {
    return @"/Library/PreferenceBundles/PocketPlanesTweaksPreferences.bundle/PocketPlanesTweaksPreferences.plist";
}
/*
cycript stuff
var dict = [[NSDictionary alloc] initWithContentsOfFile:@"/Library/PreferenceBundles/PocketPlanesTweaksPreferences.bundle/PocketPlanesTweaksPreferences.plist"]
var items = [[dict objectForKey:@"items"] allObjects]
*/

// Starts at a PSGroupCell, then traverses the dictionary until it reaches another, then returns
NSMutableDictionary* getSpecifiersForGroup(NSDictionary* input, NSInteger &index) {
#define items [[input objectForKey:@"items"] allObjects]
    debug(@"getSpecifiersForGroup(<NSDictionary>, %d)", index);
    NSMutableDictionary* out = [[[NSMutableDictionary alloc] initWithCapacity:1] autorelease];
    [out addEntriesFromDictionary:[items objectAtIndex:index]];
    
    if(index+1 >= [items count]) return out; //bail out early
    
    NSMutableArray* array = [[[NSMutableArray alloc] initWithCapacity:1] autorelease];
    do {
        if([[[items objectAtIndex:index+1] objectForKey:@"cell"] isEqualToString:@"PSGroupCell"]) break;
        
        index++;
        [array addObject:[[items objectAtIndex:index] copy]];
    } while (YES);
    
    [out setObject:array forKey:@"items"];
    // debug(@"returning: %@", [out description]);
    debug(@"index after: %d", index);
    return out;
#undef items
}
+(NSMutableDictionary*)parseSettingsFile {
    debug(@"+[PPTSettings parseSettingsFile]");
    NSDictionary* input = [NSDictionary dictionaryWithContentsOfFile:[PPTSettings pathOfSettingsFile]];
    NSMutableDictionary* output = [[[NSMutableDictionary alloc] initWithCapacity:1] autorelease];
    NSMutableArray* array = [[[NSMutableArray alloc] initWithCapacity:1] autorelease];
    
    NSInteger i = 0;
    do {
        debug(@"index: %d", i);
        [array addObject:getSpecifiersForGroup(input, i)];
        i++;
    } while (i < [[input objectForKey:@"items"] count]);
    
    [output setObject:array forKey:@"sections"];
    
    // debug(@"output: %@", [output description]);
    return output;
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

%hook AppDelegate //{
-(void)applicationDidFinishLaunching:(UIApplication*)application {
    debug(@"App finished launching!");
    %orig;
}
%end //}

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
    #ifndef DBG
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Coming soon!" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil]; [alert show]; [alert release];
    #else
    #define rootViewController [[[[UIApplication sharedApplication]delegate]window]rootViewController]
    PPTSettingsViewController* settings = [[PPTSettingsViewController alloc] init];
    [[[%c(CCDirector) sharedDirector] openGLView] addSubview:[[settings retain] view]];
    [settings release];
    #endif
}
%new -(void)settingsViewControllerDidEnd:(id)sender {
    debug(@"-[PPSettingsLayer settingsViewControllerDidEnd]");
    // [self dismissModalViewControllerAnimated:YES];
    [PPTSettings reconfigure];
}
%end //}

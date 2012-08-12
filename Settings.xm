#import "Tweak.h"
#import "PPTSettingsViewController.h"

#define tweakButtonImage @"/Library/PreferenceBundles/PocketPlanesTweaksPreferences.bundle/tweak_settings_button.png"
#define tweakButtonImagePressed @"/Library/PreferenceBundles/PocketPlanesTweaksPreferences.bundle/tweak_settings_button_pressed.png"
#define tweakButtonSprite [%c(PPSpriteFactory) spriteWithFile:tweakButtonImage]
#define tweakButtonSpritePressed [%c(PPSpriteFactory) spriteWithFile:tweakButtonImagePressed]

static BOOL isTweakButtonPressed = NO;

%hook PPSettingsLayer
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
    #undef overlay
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
    PPTSettingsViewController* settings = [[[PPTSettingsViewController alloc] init] autorelease];
    [[[%c(CCDirector) sharedDirector] openGLView] addSubview:[[settings retain] view]];
}
%end

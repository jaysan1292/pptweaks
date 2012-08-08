#import "Tweak.h"
#import "PPTSettings.h"

static BOOL enabled;                    // default: NO
static BOOL twitterEnabled;             // default: YES
static BOOL soundOnNewJobs;             // default: NO
static BOOL planeLandingNotifications;  // default: YES
static BOOL sortEventProgress;          // default: NO
static BOOL mapOverviewEnabled;         // default: NO
static BOOL hidePlaneLabels;            // default: NO
static BOOL moreDetailedTime;           // default: NO
static BOOL tripPickerPlanes;           // default: YES
static BOOL globalEventJobsOnTop;       // default: NO
static BOOL normalEventJobsOnTop;       // default: NO
static BOOL sortEventsBelowClass;       // default: YES
static BOOL advertisedJobsOnTop;        // default: NO

/*
cycript stuff
var dict = [[NSDictionary alloc] initWithContentsOfFile:@"/Library/PreferenceBundles/PocketPlanesTweaksPreferences.bundle/PocketPlanesTweaksPreferences.plist"]
var user = [[NSDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.jaysan1292.pptweaksprefs.plist"]
var items = [[dict objectForKey:@"items"] allObjects]
*/
NSMutableDictionary* getSpecifiersForGroup(NSDictionary* input, NSInteger &index); // Forward-declaration

@implementation PPTSettings
+(void)initialize {
    [PPTSettings reconfigure];
}
+(void)reconfigure {
#define getBoolValue(val) [[dict objectForKey:val] boolValue]
    debug(@"+[PPTSettings reconfigure]");
    NSDictionary* dict = [[NSDictionary alloc] initWithContentsOfFile:[PPTSettings pathOfUserSettingsFile]];

    enabled = getBoolValue(@"Enabled");
    if(enabled) {
        log(@"Pocket Planes Tweaks is enabled!");
        twitterEnabled = getBoolValue(@"TwitterEnabled");
        soundOnNewJobs = getBoolValue(@"SoundOnNewJobs");
        planeLandingNotifications = getBoolValue(@"PlaneLandingNotifications");
        sortEventProgress = getBoolValue(@"SortEventProgress");
        mapOverviewEnabled = getBoolValue(@"MapOverviewEnabled");
        hidePlaneLabels = getBoolValue(@"HidePlaneLabels");
        moreDetailedTime = getBoolValue(@"MoreDetailedTime");
        tripPickerPlanes = getBoolValue(@"TripPickerPlanes");
        globalEventJobsOnTop = getBoolValue(@"GlobalEventJobsOnTop");
        normalEventJobsOnTop = getBoolValue(@"NormalEventJobsOnTop");
        sortEventsBelowClass = getBoolValue(@"SortEventsBelowClass");
        advertisedJobsOnTop = getBoolValue(@"AdvertisedJobsOnTop");
    } else {
        log(@"Pocket Planes Tweaks is disabled.");
        twitterEnabled = YES;
        soundOnNewJobs = NO;
        planeLandingNotifications = YES;
        sortEventProgress = NO;
        mapOverviewEnabled = NO;
        hidePlaneLabels = NO;
        moreDetailedTime = NO;
        tripPickerPlanes = YES;
        globalEventJobsOnTop = NO;
        normalEventJobsOnTop = NO;
        sortEventsBelowClass = YES;
        advertisedJobsOnTop = NO;
    }
    log(@"enabled? %@", boolToString(enabled));
    log(@"twitterEnabled? %@", boolToString(twitterEnabled));
    log(@"soundOnNewJobs? %@", boolToString(soundOnNewJobs));
    log(@"planeLandingNotifications? %@", boolToString(planeLandingNotifications));
    log(@"sortEventProgress? %@", boolToString(sortEventProgress));
    log(@"mapOverviewEnabled? %@", boolToString(mapOverviewEnabled));
    log(@"hidePlaneLabels? %@", boolToString(hidePlaneLabels));
    log(@"moreDetailedTime? %@", boolToString(moreDetailedTime));
    log(@"tripPickerPlanes? %@", boolToString(tripPickerPlanes));
    log(@"globalEventJobsOnTop? %@", boolToString(globalEventJobsOnTop));
    log(@"normalEventJobsOnTop? %@", boolToString(normalEventJobsOnTop));
    log(@"sortEventsBelowClass? %@", boolToString(sortEventsBelowClass));
    log(@"advertisedJobsOnTop? %@", boolToString(advertisedJobsOnTop));

    [dict release];
#undef getBoolValue(val)
}
+(NSString*)pathOfUserSettingsFile {
    return @"/var/mobile/Library/Preferences/com.jaysan1292.pptweaksprefs.plist";
}
+(NSString*)pathOfSettingsFile {
    return @"/Library/PreferenceBundles/PocketPlanesTweaksPreferences.bundle/PocketPlanesTweaksPreferences.plist";
}
+(NSMutableDictionary*)parseSettingsFile {
    debug(@"+[PPTSettings parseSettingsFile]");
    NSDictionary* input = [NSDictionary dictionaryWithContentsOfFile:[PPTSettings pathOfSettingsFile]];
    NSMutableDictionary* output = [[[NSMutableDictionary alloc] initWithCapacity:1] autorelease];
    NSMutableArray* array = [[[NSMutableArray alloc] initWithCapacity:1] autorelease];
    
    NSInteger i = 0;
    do {
        // debug(@"index: %d", i);
        [array addObject:getSpecifiersForGroup(input, i)];
        i++;
    } while (i < [[input objectForKey:@"items"] count]);
    
    [output setObject:array forKey:@"sections"];
    
    // debug(@"output: %@", [output description]);
    return output;
}

// Starts at a PSGroupCell, then traverses the dictionary until it reaches another, then returns
NSMutableDictionary* getSpecifiersForGroup(NSDictionary* input, NSInteger &index) {
#define items [[input objectForKey:@"items"] allObjects]
    // debug(@"getSpecifiersForGroup(<NSDictionary>, %d)", index);
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
    // debug(@"index after: %d", index);
    return out;
#undef items
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
+(BOOL)globalEventJobsOnTop { return globalEventJobsOnTop; }
+(BOOL)normalEventJobsOnTop { return normalEventJobsOnTop; }
+(BOOL)sortEventsBelowClass { return sortEventsBelowClass; }
+(BOOL)advertisedJobsOnTop { return advertisedJobsOnTop; }
@end

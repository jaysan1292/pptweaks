/*
Pocket Planes Tweaks! v1.0.4
Author: jaysan1292

What it does:
- Remove the labels above each plane in the Map view. Does not affect the view for planes the player is sending out
- Change the time display to have more descriptive labels (i.e., 10s, 20s, 30s)
- Move the tweet button in the flight view to somewhere it won't be accidentally tapped
- Disables the plane notification dropdown, and plays an alert sound instead
- Sort the event list by progress made, in descending order
- Show the dots for owned airports at every zoom level. When planning a flight, only cities that the plane is able to land on will be shown, and are in range. The destination airport is also shown.
- When sending out a plane, all other planes are hidden.
- When planning a trip, don't show any other planes, and don't scale anything.
- Planes on the Map view are scaled according to the zoom level
- If a city is closed, then make its dot semi-transparent
- Play a sound when new jobs come in
- Planes are sorted when going from plane-to-plane using the side arrows or swiping (easier seen than explained)
- If a job is a global event job, move it to the top of the jobs list

Planned:
- Move dropdown bar below notification bar (instead of playing an alert sound like it does currently
- Add an entry to the event progress screen that shows how many jobs you've contributed to the global event
- Sort parts list by price value, and alphabetically
- Tap on the bottom bar (possibly the level label) to scroll to the bottom of a list
- Add a clock display to the main menu
- If a plane is full, change its appearance somehow on the Airplanes screen
- If an airport is closed, and the time to get there is greater than the time it would take for the airport to reopen, allow the plane to fly to that airport
- If an airport is closed, the text on the detail bar will be red when viewing that airport
- Eventually move settings interface from Settings.app to a new interface in-game, added into the Settings layer

Deferred:
- n/a

Configuration:
- Enable/disable Twitter integration
- Show/hide plane labels

TODO NEXT:
- Set up InAppSettingsKit
- Use NSUserDefaults for default values

KNOWN BUGS:
- There is a rare crash that happens when sending out a plane.

CHANGELOG:
1.0.4-162
    Global event jobs are placed at the top of the jobs list
1.0.4-156
    Added the ability to show or hide planes when planning a new trip
1.0.4-145
    Initial release
*/

// Header stuff {
#import <mach/mach.h>
#import <typeinfo>
#import <execinfo.h>

#import "Tweak.h"

#define showDropdown(str, args...) id dd = [[%c(PPDropdown) alloc] initWithMessage:[NSString stringWithFormat:str, ##args] callback:nil target:nil data:nil sound:nil buzz:NO]; [[%c(PPDropdownQueue) sharedQueue] addDropdown:dd]; [dd release]
#define playSound(sound) [[%c(SimpleAudioEngine) sharedEngine] playEffect:[%c(CDUtilities) fullPathFromRelativePath:sound]];
#define callMemoryCleanup() [[[%c(UIApplication) sharedApplication] delegate] applicationDidReceiveMemoryWarning:[%c(UIApplication) sharedApplication]]
#define logMemoryUsage() [%c(PPScene) logMemoryUsage]

// Sort functions {
NSComparisonResult compareEvent(id first, id second, void *context);
NSComparisonResult compareJobDist(id first, id second, void *context);
NSComparisonResult compareJobFare(id first, id second, void *context);
NSComparisonResult comparePart(PPPlanePartInfo*, PPPlanePartInfo*, void*);
NSComparisonResult comparePartName(PPPlanePartInfo*, PPPlanePartInfo*, void*);
NSComparisonResult comparePartPrice(PPPlanePartInfo*, PPPlanePartInfo*, void*);
NSComparisonResult comparePlane(PPPlaneInfo* first, PPPlaneInfo* second, void* context);
NSComparisonResult comparePlaneClass(PPPlaneInfo* first, PPPlaneInfo* second, void* context);
NSComparisonResult comparePlaneName(PPPlaneInfo* first, PPPlaneInfo* second, void* context);
NSComparisonResult comparePlaneSpeed(PPPlaneInfo* first, PPPlaneInfo* second, void* context);
// }

// Various reporting functions {
float get_memory() {
    struct task_basic_info info;
    mach_msg_type_number_t size = sizeof(info);
    kern_return_t kerr = task_info(mach_task_self(), TASK_BASIC_INFO, (task_info_t)&info, &size);
    
    if(kerr == KERN_SUCCESS) {
        return ((float)info.resident_size / 1024.0f / 1024.0f);
    } else {
        return -1.0f;
    }
}
NSString* return_memory() {
    float memory = get_memory();

    if (memory != -1) {
        return [NSString stringWithFormat:@"Memory usage (in megabytes): %.4f", memory];
    } else {
        return @"Error retrieving memory usage.";
    }
}
void report_memory() {
    log(@"%@", return_memory());
}
void print_backtrace() {
    void* array[24];
    size_t size;
    char **strings;
    size_t i;
    
    size = backtrace(array, 24);
    strings = backtrace_symbols(array, size);
    
    debug(@"Begin stack trace:");
    for(int i = 0; i < size; i++) {
        debug(@"%s",strings[i]);
    }
    debug(@"End stack trace.");
    
    free(strings);
}
// }

// }

// Hooking! {
%hook AppDelegate //{
-(void)applicationDidReceiveMemoryWarning:(id)application {
    float memory_usage = get_memory();
    %orig;
    float memory_delta = memory_usage - get_memory();
    if(memory_delta >= 0) log(@"Freed up %.4f MB of memory.", memory_delta);
}
%end //}

%hook PPAirportLayer //{
// BOOL soundPlayed = NO;

// -(void)updateTitle {
// #define _titleLbl ((CCLabelBMFont*)object_getIvar(self, class_getInstanceVariable([self class], "titleLbl"))).string
    // %orig;
    // debug(@"%@", _titleLbl);
    // if([_titleLbl rangeOfString:@"New jobs!"].location != NSNotFound){
        // log(@"New jobs!!!");
        // if(!soundPlayed) {
            // playSound(@"dink.wav");
            // soundPlayed = YES;
        // }
    // } else {
        // soundPlayed = NO;
    // }
// }
%end //}

%hook PPArrivalsLayer //{
-(void)loadUI {
    debug(@"-[PPArrivalsLayer loadUI]");
    %orig;
    callMemoryCleanup();
}
%end //}

%hook PPCraftingLayer //{
-(void)loadUI {
#define _partList object_getIvar(self, class_getInstanceVariable([self class], "items"))
#define _filter object_getIvar
    debug(@"-[PPCraftingLayer loadUI]");
    startTimeLog(start);
    %orig;
    int filter;
    
    object_getInstanceVariable(self, "filter", (void**)&filter);
    if(filter == 1) {
        [_partList sortUsingFunction:comparePlane context:nil];
    }
    
    endTimeLog(start, @"-[PPCraftingLayer loadUI]: Loading %d %s", [_partList count], filter == 1 ? "planes" : "parts");
    callMemoryCleanup();
}
%end //}

%hook PPDropdown //{
-(id)initWithMessage:(id)message callback:(SEL)callback target:(id)target data:(id)data sound:(id)sound buzz:(BOOL)buzz {
    id dd = %orig;
    debug(@"-[PPDropdown initWithMessage:%@ data:%@ sound:%@ buzz:%@]", object_getIvar(dd, class_getInstanceVariable([dd class], "msg")), [dd data], object_getIvar(dd, class_getInstanceVariable([dd class], "snd")), boolToString(buzz));
    if([message isEqualToString:@"NEW JOBS!!!"] && [PPTSettings soundOnNewJobs]) {
        log(@"New jobs!!!");
        playSound(@"dink.wav");
    }
    return dd;
}
-(void)closeDropDown {
    debug(@"-[PPDropdown closeDropDown]: %@", object_getIvar(self, class_getInstanceVariable([self class], "msg")));
    %orig;
}
-(void)dealloc {
    debug(@"-[PPDropdown dealloc]: %@", object_getIvar(self, class_getInstanceVariable([self class], "msg")));
    %orig;
}
%end //}

%hook PPDropdownQueue //{
-(void)addDropdown:(id)dropdown {
    // debug(@"-[PPDropdownQueue addDropdown:%@", object_getIvar(dropdown, class_getInstanceVariable([dropdown class], "msg")));
    if([[dropdown data] isMemberOfClass:[%c(PPPlaneInfo) class]] && ![PPTSettings planeLandingNotifications]) {
        // debug(@"Dropdown is a plane landing notification, discarding.");
        log(@"%@ has landed!", [[dropdown data] name]);
        playSound(@"alert.wav"); 
        return;
    } else {
        %orig;
    }
}
%end //}

%hook PPEventsLayer //{
// Sort functions {
NSComparisonResult compareEvent(id first, id second, void *context) {
    //should pass in each string in "xx:xx" format
    NSArray *a = [first componentsSeparatedByString:@":"];
    NSArray *b = [second componentsSeparatedByString:@":"];

    if ([[a objectAtIndex:1] intValue] > [[b objectAtIndex:1] intValue])
        return NSOrderedAscending;
    else if ([[a objectAtIndex:1] intValue] < [[b objectAtIndex:1] intValue])
        return NSOrderedDescending;
    else
        return NSOrderedSame;
}
// }
-(id)initWithFilter:(int)filter {
#define _eventList object_getIvar(self, class_getInstanceVariable([self class], "items"))
#define _playerEventCount [[[%c(PPScene) sharedScene] playerData] getMeta:@"eventCount"]
#define _globalEventId [[[%c(PPScene) sharedScene] playerData] getMeta:@"globalEvent"]
    debug(@"-[PPEventsLayer initWithFilter:%d]", filter);
    if(filter == 1) {
        id eventsLayer = %orig;
        
        return eventsLayer;
    } else {
        startTimeLog(start);
        startTimeLog(sort);
        id eventsLayer = %orig;
        
        if([PPTSettings sortEventProgress]) {
            debug(@"Sorting events list.");
            [_eventList sortUsingFunction:compareEvent context:nil];
            
            endTimeLog(sort, @"Sorting %d events", [_eventList count]);
            
            // Add the global event information to the top of the list
            // Create a string in the format XX:XX that has the eventID in before the colon, and the player's amount in the second
            // ^ this doesn't actually work, since the global event could have an ID that conflicts with the built-in one
            // only way to go here is to reimplement this function
            // [_eventList insertObject:[NSString stringWithFormat:@"%@:%@", _globalEventId, _playerEventCount] atIndex:0];
            
            endTimeLog(start, @"-[PPEventsLayer initWithFilter]");
        }
        return eventsLayer;
    }
#undef _eventList
#undef _playerEventCount
#undef _globalEventId
}
%end //}

%hook PPFlightCrewLayer //{
-(void)loadUI {
    %orig;
    if(![PPTSettings twitterEnabled]) {
        disableTweetBtn();
    }
}
%end //}

%hook PPFlightLayer //{
-(void)loadUI {
#define X 6.0f
#define Y 72.0f
    debug(@"-[PPFlightLayer loadUI]");
    %orig;
    // debug(@"Moving tweet button to (%.0f, %.0f)", X, Y);
    if([PPTSettings twitterEnabled]) {
        [object_getIvar(self, class_getInstanceVariable([self class], "shareBtn")) setPositionInPixels:ccp(X, Y)];
    } else {
        disableTweetBtn();
    }
#undef X
#undef Y
}
%end //}

%hook PPFlightLog //{

%end //}

%hook PPJobsLayer //{
// Sort functions {
NSComparisonResult compareJobFare(id first, id second, void *context) {
#define firstFare [%c(PPScene) fareFrom:[%c(PPCityInfo) cityInfoWithId:[first start_city_id]] to:[%c(PPCityInfo) cityInfoWithId:[first end_city_id]]]
#define secondFare [%c(PPScene) fareFrom:[%c(PPCityInfo) cityInfoWithId:[second start_city_id]] to:[%c(PPCityInfo) cityInfoWithId:[second end_city_id]]]
    if(firstFare > secondFare) {
        return NSOrderedAscending;
    } else if(firstFare < secondFare) {
        return NSOrderedDescending;
    } else {
        return NSOrderedSame;
    }
#undef firstFare
#undef secondFare
}
NSComparisonResult compareJobDist(id first, id second, void *context) {
#define firstDist [%c(PPScene) distBetween:[%c(PPCityInfo) cityInfoWithId:[first end_city_id]] to:context]
#define secondDist [%c(PPScene) distBetween:[%c(PPCityInfo) cityInfoWithId:[second end_city_id]] to:context]
    if(firstDist > secondDist) {
        return NSOrderedAscending;
    } else if(firstDist < secondDist) {
        return NSOrderedDescending;
    } else {
        return NSOrderedSame;
    }
#undef firstDist
#undef secondDist
}
// }
-(id)initWithCity:(id)city plane:(id)plane fiter:(int)fiter {
#define _jobList object_getIvar(orig, class_getInstanceVariable([orig class], "jobs"))
    debug(@"-[PPJobsLayer initWithCity:%@ plane:%@ fiter:%d]", [city name], [[plane info] name], fiter);
    
    startTimeLog(start);
    id orig =  %orig;
    
    if([PPTSettings eventJobsOnTop] && city != nil) {
        int globalEvent = (int)[[[[%c(PPScene) sharedScene] playerData] globalEvent] city_id];
        NSMutableArray* eventJobs = [[NSMutableArray alloc] initWithCapacity:1];
        
        // WHY DON'T WE TAKE ALL THE GLOBAL EVENT JOBS
        for(int i = [_jobList count] - 1; i >= 0; i--) {
            #define theJob [_jobList objectAtIndex:i]
            if(((PPCargoInfo*)theJob).end_city_id == globalEvent) {
                [eventJobs addObject:theJob];
            }
            #undef theJob
        }
        
        [_jobList removeObjectsInArray:eventJobs];
        
        // AND PUT THEM SOMEWHERE ELSE?
        for(int j = 0; j < [eventJobs count]; j++) {
            [_jobList insertObject:[eventJobs objectAtIndex:j] atIndex:1];
        }
        
        if([eventJobs count] != 0) {
            log(@"Found %d global event jobs!", [eventJobs count]);
        }
        
        [eventJobs release];
    }
    
    endTimeLog(start, @"Loading %d jobs", [_jobList count]);
    return orig;
#undef _jobList
}
-(void)loadUI {
    debug(@"-[PPJobsLayer loadUI]");
    %orig;
    callMemoryCleanup();
}
-(void)refreshCityJobs:(id)jobs {
    // id jobs = PPDialog
    debug(@"-[PPJobsLayer refreshCityJobs:%@]", object_getIvar(jobs, class_getInstanceVariable([jobs class], "_target")));
    %orig;
}
%end //}

%hook PPJobPool //{
-(void)setPool:(id)pool {
    debug(@"-[PPJobPool setPool:%@]", pool);
    %orig;
}
%end //}

// %hook PPList //{
// +(id)alloc {
    // debug(@"+[PPList alloc]");
    // %orig;
// }
// %end //}

%hook PPMapLayer //{
/*
cycript stuff
var mapLayer = object_getIvar([PPScene sharedScene], class_getInstanceVariable([[PPScene sharedScene] class], "mapLayer"))
var ppMapLayer = [[mapLayer children] objectAtIndex:0]
var mapCities = object_getIvar(ppMapLayer, class_getInstanceVariable([ppMapLayer class], "mapCities"))
var la = [mapCities objectAtIndex:1]
var dot = object_getIvar(la, class_getInstanceVariable([la class], "dot"))
*/
-(void)zoomMapOut {
    debug(@"-[PPMapLayer zoomMapOut]");
    %orig;
    [self setVisibleCities];
    [self scalePlanes];
}
-(void)zoomMapIn {
    debug(@"-[PPMapLayer zoomMapIn]");
    %orig;
    [self setVisibleCities];
    [self scalePlanes];
}
-(void)loadMapUI {
    debug(@"-[PPMapLayer loadMapUI]");
    %orig;
    [self setVisibleCities];
    if(self.tripPicker && ![PPTSettings tripPickerPlanes]) {
        [self hidePlanes];
    }
    [self scalePlanes];
    
    disableTweetBtn();
    
    callMemoryCleanup();
}
-(void)addCityToTrip:(id)trip {
    debug(@"-[PPMapLayer addCityToTrip:%@]", [trip name]);
    
    // if clicked city isClosed, 
    // check if the time remaining is greater than the flight time.
    // if true, then allow plane to fly there, else disallow it
    %orig;
    
    
    [self setVisibleCities];
}
-(void)removeLastLegFromTrip {
    debug(@"-[PPMapLayer removeLastLegFromTrip]");
    %orig;
    [self setVisibleCities];
}
-(id)init {
    debug(@"-[PPMapLayer init]");
    return %orig;
}
+(id)scene {
    debug(@"+[PPMapLayer scene]");
    return %orig;
}
void displayLabelForCity(id city, BOOL show) {
    // debug(@"displayLabelForCity(%@, %@)", [[city info] name], boolToString(show));
    ((CCNode*)object_getIvar(city, class_getInstanceVariable([city class], "nameLbl"))).visible = show;
    ((CCNode*)object_getIvar(city, class_getInstanceVariable([city class], "shadowLbl"))).visible = show;
    ((CCNode*)object_getIvar(city, class_getInstanceVariable([city class], "detailLbl"))).visible = show;
    ((CCNode*)object_getIvar(city, class_getInstanceVariable([city class], "detailShadowLbl"))).visible = show;   
}
%new -(void)setVisibleCities {
//define local "constants" to save on memory usage
#define _mapScale [[[[%c(PPScene) sharedScene] playerData] getMeta:@"mapZ"] floatValue]
#define _mapCities object_getIvar(self, class_getInstanceVariable([self class], "mapCities"))
#define _city [city info]
#define _nameLbl object_getIvar(city, class_getInstanceVariable([city class], "nameLbl"))
#define _shadowLbl object_getIvar(city, class_getInstanceVariable([city class], "shadowLbl"))
#define _detailLbl object_getIvar(city, class_getInstanceVariable([city class], "detailLbl"))
#define _countLbl object_getIvar(city, class_getInstanceVariable([city class], "countLbl"))
#define _detailShadowLbl object_getIvar(city, class_getInstanceVariable([city class], "detailShadowLbl"))
#define _dot object_getIvar(city, class_getInstanceVariable([city class], "dot"))
#define setDotOpacity(x) [_dot setOpacity:x]; [_countLbl setOpacity:x]

    startTimeLog(start);

    debug(@"-[PPMapLayer setVisibleCities]");
    if([PPTSettings mapOverviewEnabled]) {
        if(_mapScale < 0.3f) {
            for(int i = 0; i < [_mapCities count]; i++) {
            #define city [_mapCities objectAtIndex:i]
                if(isObject(city)) {
                    if([city isKindOfClass:[%c(PPCity) class]]){
                        if(![_city isLocked]) {
                            // debug(@"Setting visibility properties for %@.", [_city name]);
                            
                            // Scale the thing so it's more visible when zoomed out
                            if (_mapScale == 0.25f) {
                                // debug(@"Set scale to 2.");
                                ((CCNode*)city).scale = 2.0f;
                                displayLabelForCity(city, NO);

                            } else if (_mapScale == 0.125f) {
                                // debug(@"Set scale to 4.");
                                ((CCNode*)city).scale = 4.0f;
                                displayLabelForCity(city, NO);
                            }

                            /*
                            If selecting a trip, city is faded, and city is not destination
                            tripPicker = YES
                            isFaded    = YES
                            isDest     = NO
                            */
                            if(([self tripPicker]) && ([_city isFaded] && ![_city isDest])) {
                                // debug(@"%@ is visible? NO", [_city name]);
                                [city setVisible:NO];
                            } else if([_city isDest]) {
                                [city setVisible:YES];
                                displayLabelForCity(city, YES);
                            } else {
                                // debug(@"%@ is visible? YES", [_city name]);
                                [city setVisible:YES];
                                displayLabelForCity(city, NO);
                            }
                            
                            if(((PPCityInfo*)((PPCity*)city).info).isClosed) {
                                setDotOpacity(64);
                            } else {
                                setDotOpacity(255);
                            }
                            
                            // debug(@"Done setting visibility properties for %@.", [_city name]);
                        }
                    }
                } else { debug(@"Warning! Thing in array is not an object D:"); }
            #undef city
            }
        } else {
            for(int i = 0; i < [_mapCities count]; i++) {
            #define city [_mapCities objectAtIndex:i]
                if(isObject(city)) {
                    if([city isKindOfClass:[%c(PPCity) class]]) {
                        if(![_city isLocked]) {
                            //only bother resetting the scale if it hasn't been changed yet
                            if(((CCNode*)city).scale != 1.0f) {
                                // debug(@"Resetting size properties for %@.", [_city name]);
                                // debug(@"Set scale to 1.");
                                ((CCNode*)city).scale = 1.0f;
                                displayLabelForCity(city, YES);
                                // debug(@"Done resetting size properties for %@.", [_city name]);
                            }
                            
                            if(((PPCityInfo*)((PPCity*)city).info).isClosed) {
                                setDotOpacity(64);
                            } else {
                                setDotOpacity(255);
                            }
                        }
                    }
                }
            #undef city
            }
        }
    }
    endTimeLog(start, @"setVisibleCities");

#undef _mapScale
#undef _mapCities
#undef _city
#undef _nameLbl
#undef _shadowLbl
#undef _detailLbl
#undef _countLbl
#undef _detailShadowLbl
#undef _dot
#undef setDotOpacity(x)
}
%new -(void)hidePlanes {
#define _mapPlanes object_getIvar(self, class_getInstanceVariable([self class], "mapPlanes"))
    debug(@"-[PPMapLayer hidePlanes]");
    startTimeLog(start);
    
    for(PPMapPlane* plane in _mapPlanes) {
        if(!plane.showRange) {
            plane.visible = NO;
        }
    }
    
    endTimeLog(start, @"hidePlanes");
#undef _mapPlanes
}
%new -(void)scalePlanes {
#define _mapScale [[[[%c(PPScene) sharedScene] playerData] getMeta:@"mapZ"] floatValue]
#define _mapPlanes object_getIvar(self, class_getInstanceVariable([self class], "mapPlanes"))
    debug(@"-[PPMapLayer scalePlanes]");
    if([PPTSettings mapOverviewEnabled]) {
        startTimeLog(start);
        
        // debug(@"Scaling planes based on zoom level.");
        for(PPMapPlane* plane in _mapPlanes) {
            if(!plane.showRange) {
                if(_mapScale == 1.0f) {
                    // debug(@"Setting plane scale to 2");
                    plane.scale = 2.0f;
                } else if(_mapScale == 0.5f) {
                    // debug(@"Setting plane scale to 1");
                    plane.scale = 1.0f;
                } else if(_mapScale == 0.25f) {
                    // debug(@"Setting plane scale to 0.75");
                    plane.scale = 0.75f;
                } else if(_mapScale == 0.125f) {
                    // debug(@"Setting plane scale to 0.5");
                    plane.scale = 0.5f;
                }
            }
        }
        endTimeLog(start, @"-[PPMapLayer scalePlanes]");
    }
#undef _mapScale
#undef _mapPlanes
}
%end //}

%hook PPMapPlane //{
/*
cycript stuff
var mapLayer = object_getIvar([PPScene sharedScene], class_getInstanceVariable([[PPScene sharedScene] class], "mapLayer"))
var ppMapLayer = [[mapLayer children] objectAtIndex:0]
var mapPlanes = object_getIvar(ppMapLayer, class_getInstanceVariable([ppMapLayer class], "mapPlanes"))
*/
-(id)initWithInfo:(id)info trip:(id)trip {
    debug(@"-[PPMapPlane initWithInfo:%@ trip:%@]", [info name], [trip description]);
    CCNode* mapplane = %orig;

    if([PPTSettings hidePlaneLabels]) {
        [object_getIvar(mapplane, class_getInstanceVariable([mapplane class], "planeLbl")) setVisible:NO];
        [object_getIvar(mapplane, class_getInstanceVariable([mapplane class], "nameLbl")) setVisible:NO];
        if(((PPMapLayer*)mapplane.parent.parent).tripPicker) {
            [object_getIvar(mapplane, class_getInstanceVariable([mapplane class], "pMarker")) setVisible:NO];
        }
    }
    
    return mapplane;
}
%end //}

%hook PPMenuLayer //{
-(id)init {
    debug(@"-[PPMenuLayer init]");
    id orig = %orig;
    
    return orig;
}
-(void)dealloc {
    debug(@"-[PPMenuLayer dealloc]");
    %orig;
}
%end
//}

%hook PPPlayerData //{
/*
Sort planes in this order:
1. planeInfo.class_lvl  descending
2. planeInfo.speed      descending
3. planeInfo.name       (P, C, M)

Order is supposed to be:
CONCORDE
STARSHIP
CLOUDLINER
FOGBUSTER
TETRA
CYCLONE
C-130 HERCULES
SEQUOIA
PEARJET
AEROEAGLE
EQUINOX
BIRCHCRAFT
P-40 WARHAWK
ANAN
MOHAWK
NAVIGATOR
AIRVAN
SUPERGOPHER
WALLABY
GRIFFON
BOBCAT
SEA KNIGHT
BEARCLAW
HUEY
KANGAROO
BLIMP
HOT AIR BALLOON
*/
// Sort functions {
#define _sortDescending
NSComparisonResult comparePlane(PPPlaneInfo* first, PPPlaneInfo* second, void* context) {
    return comparePlaneClass(first, second, context);
}
NSComparisonResult comparePlaneClass(PPPlaneInfo* first, PPPlaneInfo* second, void* context) {
    // return first.class_lvl < second.class_lvl ? NSOrderedAscending : first.class_lvl > second.class_lvl ? NSOrderedDescending : comparePlaneSpeed(first, second, context); // ascending
    return first.class_lvl < second.class_lvl ? NSOrderedDescending : first.class_lvl > second.class_lvl ? NSOrderedAscending : comparePlaneSpeed(first, second, context); // descending
}
NSComparisonResult comparePlaneSpeed(PPPlaneInfo* first, PPPlaneInfo* second, void* context) {
    // return first.speed < second.speed ? NSOrderedAscending : first.speed > second.speed ? NSOrderedDescending : comparePlaneName(first, second, context); // ascending
    return first.speed < second.speed ? NSOrderedDescending : first.speed > second.speed ? NSOrderedAscending : comparePlaneName(first, second, context); // descending
}
NSComparisonResult comparePlaneName(PPPlaneInfo* first, PPPlaneInfo* second, void* context) {
    #define PPPassengerPlane 1
    #define PPCargoPlane 2
    #define PPMixedPlane 3
    
    int firstType = 0;
    int secondType = 0;
    
    if(first.cargoRows == 0 && first.passRows != 0) firstType = PPPassengerPlane;
    else if(first.cargoRows != 0 && first.passRows == 0) firstType = PPCargoPlane;
    else if(first.cargoRows != 0 && first.passRows != 0) firstType = PPMixedPlane;
    
    if(second.cargoRows == 0 && second.passRows != 0) secondType = PPPassengerPlane;
    else if(second.cargoRows != 0 && second.passRows == 0) secondType = PPCargoPlane;
    else if(second.cargoRows != 0 && second.passRows != 0) secondType = PPMixedPlane;
    
    // return firstType < secondType ? NSOrderedDescending : firstType > secondType ? NSOrderedAscending : NSOrderedSame;
    return firstType < secondType ? NSOrderedAscending : firstType > secondType ? NSOrderedDescending : NSOrderedSame;
}
//}
-(void)spendBux:(int)bux {
#ifdef DBG
    return;
#else
    log(@"Spent %d bux.", bux);
    %orig;
#endif
}
-(void)spendCoins:(int)coins {
    log(@"Spent %d %s.", coins, coins == 1 ? "coin":"coins");
    %orig;
}
-(void)addBux:(int)bux {
    log(@"Added %d bux.", bux);
    %orig;
}
-(void)addCoins:(int)coins {
    log(@"Added %d %s.", coins, coins == 1 ? "coin":"coins");
    %orig;
}
-(id)planes {
    id planes = %orig;
    startTimeLog(start);
    [planes sortUsingFunction:comparePlane context:nil];
    endTimeLogD(start, @"Sorting planes");
    return planes;
}
%end //}

%hook PPScene //{
+(NSString*)timeString:(int)string {
    if([PPTSettings moreDetailedTime]) {
        int days = (int)(string/(24*60*60));
        int hours = (string/(60*60))%24;
        int minutes = (string/60)%60;
        int seconds = (int)(10 * ceil((string%60) / 10 + 0.5));
        // if((string+1)%60 == 0){ minutes++; seconds = 0; }
        if(seconds == 60) { minutes++; seconds = 0; }
        if(minutes == 60) { hours++; minutes = 0; }
        if(hours == 24) { days++; hours = 0; }
        
        if (string < 0) {
            return @"LANDED";
        } else if(days > 0) {
            return formatString(@"%@%@",
                                hours == 0 ? [NSString stringWithFormat:@"%dd", days] : [NSString stringWithFormat:@"%dd, ", days],
                                hours == 0 ? @"" : [NSString stringWithFormat:@"%dh", hours]);
        } else if(hours > 0) {
            return formatString(@"%@%@",
                                minutes == 0 ? [NSString stringWithFormat:@"%dh", hours] : [NSString stringWithFormat:@"%dh, ", hours],
                                minutes == 0 ? @"" : [NSString stringWithFormat:@"%dm", minutes]);
        } else if(minutes > 0) {
            return formatString(@"%@%@",
                                seconds == 0 ? [NSString stringWithFormat:@"%dm", minutes] : [NSString stringWithFormat:@"%dm, ", minutes],
                                seconds == 0 ? @"" : [NSString stringWithFormat:@"%ds", seconds]);
        } else {
            return string == 0 ? @"10s" : [NSString stringWithFormat:@"%ds", seconds];
        }
    } else {
        return %orig;
    }
}
-(void)tweet:(id)tweet withImage:(id)image {
#ifdef DBG
    debug(@"-[PPScene tweet:%@ withImage:%@]", [tweet description], [image description]);
    showDropdown(return_memory());
#else
    %orig;
#endif
}
+(void)viewNextPlane:(id)plane direction:(int)direction {
    debug(@"+[PPScene viewNextPlane:%@ direction:%d]", [plane name], direction);
    %orig(plane, direction);
}
%new +(void)logMemoryUsage {
#ifdef DBG
    report_memory();
#else
    return;
#endif
}
%end //}

%hook PPStatsLayer //{
-(void)loadUI {
    %orig;
    if(![PPTSettings twitterEnabled]) {
        disableTweetBtn();
    }
}
%end //}

%hook PPStoreLayer //{
-(void)loadUI {
    debug(@"-[PPStoreLayer loadUI]");
    %orig;
    callMemoryCleanup();
}
%end //}
// }

__attribute__((constructor)) static void init() {
    NSDictionary* dict = [[NSDictionary alloc] initWithContentsOfFile:[PPTSettings pathOfSettingsFile]];
    if([[dict objectForKey:@"Enabled"] boolValue]) {
        log(@"Pocket Planes Tweaks is enabled!");
        [PPTSettings setup];
        %init;
    } else {
        log(@"Pocket Planes Tweaks is disabled.");
    }
    [dict release];
}

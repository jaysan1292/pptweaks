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
- Settings are in Settings.app as well as a new interface in the Settings screen in-game

Planned:
- Move dropdown bar below notification bar (instead of playing an alert sound like it does currently
- Add an entry to the event progress screen that shows how many jobs you've contributed to the global event
- Sort parts list by price value, and alphabetically
- Tap on the bottom bar (possibly the level label) to scroll to the bottom of a list
- Add a clock display to the main menu
- If a plane is full, change its appearance somehow on the Airplanes screen
- If an airport is closed, and the time to get there is greater than the time it would take for the airport to reopen, allow the plane to fly to that airport
- If an airport is closed, the text on the detail bar will be red when viewing that airport
- On the trip planner screen, if there are more than one destinations, display the number of passengers/cargo going to that specific city
- If a job is an event job, move it to the top of the jobs list

Deferred:
- n/a

Configuration:
- Enable/disable Twitter integration
- Show/hide plane labels

TODO NEXT:
- Use NSUserDefaults for default values

KNOWN BUGS:
- There is a rare crash that happens when sending out a plane.
- There is a rare crash that happens an arbitrary amount of time after you exit the in-app settings interface

CHANGELOG:
- 1.0.4-457
    - Normal event jobs can now be placed at the top of the job list, as global events are
- 1.0.4-427
    - If "Planes in Trip Picker" is on, other planes will appear faded when sending out a plane
    - Some performance enhancements
- 1.0.4-382
    - Added the ability to change settings from within the app via the Settings screen
- 1.0.4-162
    - Global event jobs are placed at the top of the jobs list
- 1.0.4-156
    - Added the ability to show or hide planes when planning a new trip
- 1.0.4-145
    - Initial release
*/

#import "Tweak.h"

#define playSound(sound) [[%c(SimpleAudioEngine) sharedEngine] playEffect:[%c(CDUtilities) fullPathFromRelativePath:sound]];
#define callMemoryCleanup() [[[%c(UIApplication) sharedApplication] delegate] applicationDidReceiveMemoryWarning:[%c(UIApplication) sharedApplication]]

%hook AppDelegate //{
-(void)applicationDidReceiveMemoryWarning:(id)application {
    float memory_usage = get_memory();
    %orig;
    float memory_delta = memory_usage - get_memory();
    if(memory_delta >= 0) log(@"Freed up %.4f MB of memory.", memory_delta);
}
%end //}

%hook PPArrivalsLayer //{
-(void)loadUI {
    debug(@"-[PPArrivalsLayer loadUI]");
    %orig;
    callMemoryCleanup();
}
%end //}

%hook PPDropdown //{
-(id)initWithMessage:(id)message callback:(SEL)callback target:(id)target data:(id)data sound:(id)sound buzz:(BOOL)buzz {
    id dd = %orig;
    if([PPTSettings enabled]) {
        debug(@"-[PPDropdown initWithMessage:%@ data:%@ sound:%@ buzz:%@]", getIvar(dd, "msg"), [dd data], getIvar(dd, "snd"), boolToString(buzz));
        if([message isEqualToString:@"NEW JOBS!!!"] && [PPTSettings soundOnNewJobs]) {
            log(@"New jobs!!!");
            playSound(@"dink.wav");
        }
    }
    return dd;
}
-(void)closeDropDown {
    debug(@"-[PPDropdown closeDropDown]: %@", getIvar(self, "msg"));
    %orig;
}
-(void)dealloc {
    debug(@"-[PPDropdown dealloc]: %@", getIvar(self, "msg"));
    %orig;
}
%end //}

%hook PPDropdownQueue //{
-(void)addDropdown:(id)dropdown {
    if([[dropdown data] isMemberOfClass:[%c(PPPlaneInfo) class]] && ![PPTSettings planeLandingNotifications]) {
        // debug(@"Dropdown is a plane landing notification, discarding.");
        log(@"%@ has landed!", [[dropdown data] name]);
        playSound(@"alertdouble.wav"); 
        return;
    } else {
        %orig;
    }
}
%end //}

%hook PPFlightCrewLayer //{
-(void)loadUI {
    %orig;
    disableTweetBtn();
}
%end //}

%hook PPFlightLayer //{
-(void)loadUI {
#define X 6.0f
#define Y 72.0f
    // debug(@"-[PPFlightLayer loadUI]");
    %orig;
    // debug(@"Moving tweet button to (%.0f, %.0f)", X, Y);
    if([PPTSettings enabled]) {
        if([PPTSettings twitterEnabled]) {
            [getIvar(self, "shareBtn") setPositionInPixels:ccp(X, Y)];
        } else {
            disableTweetBtn();
        }
    }
#undef X
#undef Y
}
%end //}

%hook PPMenuLayer //{
-(id)init {
    debug(@"-[PPMenuLayer init]");
    return %orig;
}
-(void)dealloc {
    debug(@"-[PPMenuLayer dealloc]");
    %orig;
}
-(void)release {
    debug(@"-[PPMenuLayer release]");
    %orig;
}
%end //}

%hook PPStatsLayer //{
-(void)loadUI {
    %orig;
    disableTweetBtn();
}
%end //}

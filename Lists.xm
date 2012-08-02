#import "Tweak.h"

#define callMemoryCleanup() [[[%c(UIApplication) sharedApplication] delegate] applicationDidReceiveMemoryWarning:[%c(UIApplication) sharedApplication]]

%hook PPCraftingLayer //{
-(void)loadUI {
#define _partList getIvar(self, "items")
    if([PPTSettings enabled]) {
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
    } else {
        %orig;
    }
}
%end //}

%hook PPEventsLayer //{
// Sort functions {
NSComparisonResult compareEvent(NSString* first, NSString* second, void *context) {
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
#define _eventList getIvar(self, "items")
#define _playerEventCount [[[%c(PPScene) sharedScene] playerData] getMeta:@"eventCount"]
#define _globalEventId [[[%c(PPScene) sharedScene] playerData] getMeta:@"globalEvent"]
    if([PPTSettings enabled]) {
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
    }
#undef _eventList
#undef _playerEventCount
#undef _globalEventId
}
%end //}

%hook PPFlightLog //{

%end //}

%hook PPHangarLayer //{
-(void)loadUI {
    %orig;
    if([PPTSettings enabled]) {
        debug(@"item class: %@", [[getIvar(self, "items") objectAtIndex:0] class]);
        [getIvar(self, "items") sortUsingFunction:comparePlane context:nil];
    }
}
%end //}

%hook PPJobsLayer //{
// Sort functions {
NSComparisonResult compareJobFare(PPCargoInfo* first, PPCargoInfo* second, void *context) {
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
NSComparisonResult compareJobDist(PPCargoInfo* first, PPCargoInfo* second, void *context) {
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
#define _jobList getIvar(orig, "jobs")
    debug(@"-[PPJobsLayer initWithCity:%@ plane:%@ fiter:%d]", [city name], [[plane info] name], fiter);
    
    startTimeLog(start);
    id orig =  %orig;
    
    if(![PPTSettings enabled]) return orig;
    
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
    debug(@"-[PPJobsLayer refreshCityJobs:%@]", getIvar(jobs, "_target"));
    %orig;
}
%end //}

%hook PPStoreLayer //{
-(void)loadUI {
    debug(@"-[PPStoreLayer loadUI]");
    %orig;
    callMemoryCleanup();
}
%end //}

#import "Tweak.h"

#define callMemoryCleanup() [[[%c(UIApplication) sharedApplication] delegate] applicationDidReceiveMemoryWarning:[%c(UIApplication) sharedApplication]]

%hook PPCraftingLayer //{
-(void)loadUI {
#define partList getIvar(self, "items")
    if([PPTSettings enabled]) {
        debug(@"-[PPCraftingLayer loadUI]");
        startTimeLog(start);
        %orig;
        int filter;
        
        object_getInstanceVariable(self, "filter", (void**)&filter);
        if(filter == 1) {
            [partList sortUsingFunction:comparePlane context:nil];
        }
        
        endTimeLog(start, @"-[PPCraftingLayer loadUI]: Loading %d %s", [partList count], filter == 1 ? "planes" : "parts");
        callMemoryCleanup();
    } else {
        %orig;
    }
#undef partList
}
%end //}

%hook PPEventsLayer //{
-(id)initWithFilter:(int)filter {
#define _eventList getIvar(self, "items")
    if([PPTSettings enabled]) {
        debug(@"-[PPEventsLayer initWithFilter:%d]", filter);
        if(filter == 1) {
            id eventsLayer = %orig;
            
            return eventsLayer;
        } else {
            startTimeLog(start);
            id eventsLayer = %orig;
            
            if([PPTSettings sortEventProgress]) {
                startTimeLog(sort);
                
                debug(@"Sorting events list.");
                [_eventList sortUsingFunction:compareEvent context:nil];
                
                endTimeLog(sort, @"Sorting %d events", [_eventList count]);
            }
            endTimeLog(start, @"-[PPEventsLayer initWithFilter]");
            return eventsLayer;
        }
    }
#undef _eventList
}
%end //}

%hook PPFlightLog //{
-(void)loadUI {
    %orig;
    callMemoryCleanup();
}
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
%end //}

%hook PPStoreLayer //{
-(void)loadUI {
    debug(@"-[PPStoreLayer loadUI]");
    %orig;
    callMemoryCleanup();
}
%end //}

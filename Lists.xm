#import "Tweak.h"

#define callMemoryCleanup() [[[%c(UIApplication) sharedApplication] delegate] applicationDidReceiveMemoryWarning:[%c(UIApplication) sharedApplication]]

%hook PPAirpedia //{
-(void)loadUI {
    %orig;
    callMemoryCleanup();
}
%end //}

%hook PPArrivalsLayer //{
/*
cycript stuff
var planelist = [[PPScene sharedScene] menuLayer]
var pplist = object_getIvar(planelist, class_getInstanceVariable([planelist class], "list"))
var item = [pplist itemAtIndex:0]
*/
-(void)loadUI {
    %orig;
    callMemoryCleanup();
}
%end //}

%hook PPCraftingLayer //{
-(void)loadUI {
#define partList getIvar(self, "items")
    if([PPTSettings enabled]) {
        debug(@"-[PPCraftingLayer loadUI]");
        startTimeLog(start);
        %orig;
        int filter;
        
        object_getInstanceVariable(self, "filter", (void**)&filter);
        if(filter == 1)
            [partList sortUsingFunction:comparePlane context:nil];
        // else
            
        
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
/*
cycript stuff
var joblayer = [[PPScene sharedScene]menuLayer]
var list = object_getIvar(joblayer, class_getInstanceVariable([joblayer class], "list"))
var item = [list itemAtIndex:1]
*/
-(id)initWithCity:(id)city plane:(id)plane fiter:(int)fiter {
    debug(@"-[PPJobsLayer initWithCity:%@ plane:%@ fiter:%d]", [city name], [[plane info] name], fiter);
    
    startTimeLog(start);
    id outLayer = %orig;
    
    if(![PPTSettings enabled]) return outLayer;
    
    if([PPTSettings advertisedJobsOnTop])  [self moveAdvertisedJobsToTop:outLayer city:city plane:plane];
    if([PPTSettings normalEventJobsOnTop]) [self moveNormalEventJobsToTop:outLayer city:city plane:plane];
    if([PPTSettings globalEventJobsOnTop]) [self moveGlobalEventJobsToTop:outLayer city:city plane:plane];
    
    endTimeLog(start, @"Loading %d jobs", [getIvar(outLayer, "jobs") count]);
    return outLayer;
}
-(void)loadUI {
    debug(@"-[PPJobsLayer loadUI]");
    %orig;
    callMemoryCleanup();
}
%new -(void)moveNormalEventJobsToTop:(id)layer city:(id)city plane:(id)plane {
#define _jobList getIvar(layer, "jobs")
    if(city != nil) {
        startTimeLog(nEvent);
        
        NSMutableArray* allEvents = [[NSMutableArray alloc] initWithCapacity:1];
        NSMutableArray* normalEventJobs = [[NSMutableArray alloc] initWithCapacity:1];
        
        [allEvents addObjectsFromArray:[[[%c(PPScene) sharedScene] playerData] events]];

        // don't process weather events and events that already have been completed
        NSMutableArray* eventsToRemove = [[NSMutableArray alloc] initWithCapacity:1];
        
        for(id event in allEvents)
            if([event isWeather] || [[[%c(PPScene) sharedScene] playerData] isLocalEventComplete:[event event_info_id]]) [eventsToRemove addObject:event];
        
        [allEvents removeObjectsInArray:eventsToRemove];
        
        [eventsToRemove release];
        
        int planeClass = (int)[[plane info] class_lvl];
        NSMutableArray* cities = [[NSMutableArray alloc] init];
        [cities addObjectsFromArray:[[[%c(PPScene) sharedScene] playerData] unlockedCities]];
        
        // Take the event jobs...
        for(int i = [_jobList count] - 1; i >= 0; i--) {
            #define theJob [_jobList objectAtIndex:i]
            for(int j = 0; j < [allEvents count]; j++) {
                #define theEvent [allEvents objectAtIndex:j]
                
                //skip processing entirely if the event is not active
                if(![theEvent active]) continue;
                
                int cityClass = 0;
                for(int k = 0; k < [cities count]; k++) {
                    #define theCity [cities objectAtIndex:k]
                        if([theCity city_id] == [theEvent city_id]) {
                            cityClass = [theCity class_lvl];
                            break;
                        }
                    #undef theCity
                }
                
                if((int)[theJob end_city_id] == (int)[theEvent city_id]) {
                    // debug(@"Processing class %d city: %@", [[cities
                    // If sortEventsBelowClass is OFF *and* the plane can travel
                    // to the city, OR if sortEventsBelowClass is ON, then add
                    // it to the list of jobs to move to the top
                    if(![PPTSettings sortEventsBelowClass] && planeClass <= cityClass || [PPTSettings sortEventsBelowClass]) {
                        [normalEventJobs addObject:theJob]; 
                    }
                }
                #undef theEvent
            }
            #undef theJob
        }
        
        [_jobList removeObjectsInArray:normalEventJobs]; // Ensure there are no duplicate jobs
        
        // ...and put them at the top
        for(int k = 0; k < [normalEventJobs count]; k++) 
            [_jobList insertObject:[normalEventJobs objectAtIndex:k] atIndex:1];
        
        if([normalEventJobs count] != 0) log(@"Found %d normal event jobs!", [normalEventJobs count]);
        
        [allEvents release];
        [normalEventJobs release];
        [cities release];
        
        endTimeLog(nEvent, @"Looking for normal event jobs");
    }
#undef _jobList
}
%new -(void)moveGlobalEventJobsToTop:(id)layer city:(id)city plane:(id)plane {
#define _jobList getIvar(layer, "jobs")
    if(city != nil) {
        startTimeLog(gEvent);
    
        int globalEvent = (int)[[[[%c(PPScene) sharedScene] playerData] globalEvent] city_id];
        NSMutableArray* eventJobs = [[NSMutableArray alloc] initWithCapacity:1];
        
        // WHY DON'T WE TAKE ALL THE GLOBAL EVENT JOBS
        for(int i = [_jobList count] - 1; i >= 0; i--) {
            #define theJob [_jobList objectAtIndex:i]
            if([theJob end_city_id] == globalEvent)
                [eventJobs addObject:theJob];
            #undef theJob
        }
        
        [_jobList removeObjectsInArray:eventJobs]; // Ensure there are no duplicate jobs
        
        // AND PUT THEM SOMEWHERE ELSE?
        for(int j = 0; j < [eventJobs count]; j++)
            [_jobList insertObject:[eventJobs objectAtIndex:j] atIndex:1];
        
        if([eventJobs count] != 0) log(@"Found %d global event jobs!", [eventJobs count]);
        
        [eventJobs release];
        
        endTimeLog(gEvent, @"Looking for global event jobs");
    }
#undef _jobList
}
%new -(void)moveAdvertisedJobsToTop:(id)layer city:(id)city plane:(id)plane {
#define _jobList getIvar(layer, "jobs")
    if(city != nil) {
        startTimeLog(aJobs);
        
        debug(@"init arrays");
        NSArray* ownedCities = [[NSArray alloc] initWithArray:[[[%c(PPScene) sharedScene] playerData] unlockedCities]];
        NSArray* campaigns = [ownedCities valueForKey:@"lastCampaign"];
        NSMutableArray* campaignCities = [[NSMutableArray alloc] init];
        
        debug(@"find all cities that have active advertising campaigns");
        for(int i = 0; i < [ownedCities count]; i++)
            if(![[campaigns objectAtIndex:i] isEqualToNumber:[NSNumber numberWithFloat:0.0f]]) [campaignCities addObject:[ownedCities objectAtIndex:i]];
        
        debug(@"Cities with active campaign: %@", [[[campaignCities valueForKey:@"name"] description] stringByReplacingOccurrencesOfString:@"\n" withString:@" "]);
        
        NSMutableArray* adJobs = [[NSMutableArray alloc] init];
        
        debug(@"iterate through job list");
        for(int i = [_jobList count] - 1; i >= 0; i--) {
            #define theJob [_jobList objectAtIndex:i]
            if([[campaignCities valueForKey:@"city_id"] indexOfObject:[NSNumber numberWithInt:[theJob end_city_id]]] != NSNotFound) [adJobs addObject:theJob];
            #undef theJob
        }
        
        [_jobList removeObjectsInArray:adJobs];
        
        debug(@"add jobs to top of the job list");
        for(int i = 0; i < [adJobs count]; i++)
            [_jobList insertObject:[adJobs objectAtIndex:i] atIndex:1];
        
        if([adJobs count] != 0) log(@"Found %d advertised jobs!", [adJobs count]);
        
        [adJobs release];
        [campaignCities release];
        [ownedCities release];
        
        endTimeLog(aJobs, @"Looking for advertised jobs");
    }
}
#undef _jobList
%end //}

%hook PPStoreLayer //{
-(void)loadUI {
    debug(@"-[PPStoreLayer loadUI]");
    %orig;
    callMemoryCleanup();
}
%end //}

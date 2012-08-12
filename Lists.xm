#import "Tweak.h"

#define callMemoryCleanup() [[[%c(UIApplication) sharedApplication] delegate] applicationDidReceiveMemoryWarning:[%c(UIApplication) sharedApplication]]

%hook PPAirpedia
-(void)loadUI {
    %orig;
    callMemoryCleanup();
}
%end

%hook PPArrivalsLayer
/*
cycript stuff
var planelist = [[PPScene sharedScene] menuLayer]
var pplist = object_getIvar(planelist, class_getInstanceVariable([planelist class], "list"))
var item = [pplist itemAtIndex:0]

// if plane is BOARDING
[item.children objectAtIndex:4] => <CCSpriteBatchNode {x:215,y:12}>
^ replace that with an instance of CCLabelBMFont:
[item.children removeObject:[item.children objectAtIndex:4]];
PPPlaneInfo* info = [[item.children objectAtIndex:3] info]

if(planetypeis PASSENGER) formatString(@"%d/%dP", current, max);
if(planetypeis CARGO) formatString(@"%d/%dC", current, max);
if(planetypeis MIXED) formatString(@"%d/%dP %d/%dC", currentpass, maxpass, currentcargo, maxcargo);

CCLabelBMFont* label = [CCLabelBMFont labelWithString:<info> fntFile:@"silkscreen9.fnt"];
[label setPosition:ccp(215, 10)];

[item.children addObject:label];

// if plane is IDLE
[item.children objectAtIndex:4] => <CCLabelBMFont {x:215,y:10"}>.string = "IDlE"

// if plane is LANDED
[item.children objectAtIndex:4] => <CCLabelBMFont {x:215,y:10"}>.string = "LANDED"
*/
-(void)updateLbls {
    %orig;
    [self updateBoardingLabels];
}
-(void)loadUI {
    debug(@"-[PPArrivalsLayer(%p) loadUI]", self);
    %orig;
    callMemoryCleanup();
    [self performSelector:@selector(updateBoardingLabels) withObject:nil afterDelay:1];
    [self performSelector:@selector(updateBoardingLabels) withObject:nil afterDelay:5];
}
%end

%hook PPCraftingLayer
-(void)loadUI {
    #define partList getIvar(self, "items")
    if([PPTSettings enabled]) {
        debug(@"-[PPCraftingLayer loadUI] (%p)", self);
        startTimeLog(start);
        %orig;
        int filter;
        
        object_getInstanceVariable(self, "filter", (void**)&filter);
        
        if(filter == 1)
            [partList sortUsingFunction:comparePlane context:nil];
            
        
        endTimeLog(start, @"-[PPCraftingLayer loadUI]: Loading %d %s", [partList count], filter == 1 ? "planes" : "parts");
        callMemoryCleanup();
    } else {
        %orig;
    }
    #undef partList
}
%end

%hook PPEventsLayer
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
%end

%hook PPFlightLog
-(void)loadUI {
    %orig;
    callMemoryCleanup();
}
%end

%hook PPHangerLayer
-(void)loadUI {
    debug(@"-[PPHangarLayer loadUI]");
    %orig;
    if([PPTSettings enabled]) {
        debug(@"item class: %@", [[getIvar(self, "items") objectAtIndex:0] class]);
        [getIvar(self, "items") sortUsingFunction:comparePlane context:nil];
    }
}
%end

%hook PPJobsLayer
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
%end

%hook PPStoreLayer
-(void)loadUI {
    debug(@"-[PPStoreLayer loadUI]");
    %orig;
    callMemoryCleanup();
}
%end

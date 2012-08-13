#import "Tweak.h"

#define callMemoryCleanup() [[[%c(UIApplication) sharedApplication] delegate] applicationDidReceiveMemoryWarning:[%c(UIApplication) sharedApplication]]

%hook PPMapLayer
/*
cycript stuff
var mapLayer = object_getIvar([PPScene sharedScene], class_getInstanceVariable([[PPScene sharedScene] class], "mapLayer"))
var ppMapLayer = [[mapLayer children] objectAtIndex:0]
var mapCities = object_getIvar(ppMapLayer, class_getInstanceVariable([ppMapLayer class], "mapCities"))
var la = [mapCities objectAtIndex:1]
var dot = object_getIvar(la, class_getInstanceVariable([la class], "dot"))

// close Mexico City
[[[mapCities objectAtIndex:45]info]setIsClosed:YES]

// open Mexico City
[[[mapCities objectAtIndex:45]info]setIsClosed:NO]
*/
-(void)zoomMapOut {
    debug(@"-[PPMapLayer zoomMapOut]");
    %orig;
    
    if(![PPTSettings enabled]) return;
    
    [self setVisibleCities];
    [self scalePlanes];
}
-(void)zoomMapIn {
    debug(@"-[PPMapLayer zoomMapIn]");
    %orig;
    
    if(![PPTSettings enabled]) return;
    
    [self setVisibleCities];
    [self scalePlanes];    
}
-(void)loadMapUI {
    debug(@"-[PPMapLayer loadMapUI]");
    startTimeLog(start);
    %orig;
    
    if(![PPTSettings enabled]) return;
        
    [self setVisibleCities];
    if([self tripPicker]) {
        if([PPTSettings tripPickerPlanes]) {
            [self fadePlanes];
        } else {
            [self hidePlanes];
        }
    }
    [self scalePlanes];

    disableTweetBtn();
    
    callMemoryCleanup();
    endTimeLog(start, @"-[PPMapLayer loadMapUI]");
}
-(void)addCityToTrip:(id)trip {
    if(![PPTSettings enabled]) { %orig; return; }

    debug(@"-[PPMapLayer addCityToTrip:%@]", [trip name]);

    if([trip isClosed]) {
        debug(@"%@ is closed! %p", [trip name], trip);

        BOOL cityWasClosed = YES;
        [trip setIsClosed:NO];

        // temporarily disable sounds, otherwise there will be a bunch of unnecessary sound played when this check happens
        [[%c(CDAudioManager) sharedManager] setMute:YES];
        %orig;
        if((double)[[[[%c(PPScene) sharedScene] playerData] eventForCity:trip] endTime] < [getIvar(self, "planeTrip") endTime]) {
            debug(@"Plane should arrive after the city reopens :D");
            [trip setIsClosed:YES];

            // reenable sounds before return
            [[%c(CDAudioManager) sharedManager] setMute:NO];
            return;
        }
        if(cityWasClosed) [trip setIsClosed:YES];
        [self removeLastLegFromTrip];
        
        // reenable sounds before executing original method
        [[%c(CDAudioManager) sharedManager] setMute:NO];
    }
    
    %orig;

    [self setVisibleCities];
}
-(void)removeLastLegFromTrip {
    debug(@"-[PPMapLayer removeLastLegFromTrip]");
    %orig;
    
    if(![PPTSettings enabled]) return;

    [self setVisibleCities];
}
%end

%hook PPMapPlane
/*
cycript stuff
var mapLayer = object_getIvar([PPScene sharedScene], class_getInstanceVariable([[PPScene sharedScene] class], "mapLayer"))
var ppMapLayer = [[mapLayer children] objectAtIndex:0]
var mapPlanes = object_getIvar(ppMapLayer, class_getInstanceVariable([ppMapLayer class], "mapPlanes"))
var plane = [mapPlanes objectAtIndex:0]
*/
-(id)initWithInfo:(id)info trip:(id)trip {
    CCNode* plane = %orig;

    // If tweak is disabled, bail out early
    if(![PPTSettings enabled]) return plane;
    
    [self hidePlaneLabel:plane];
    
    return plane;
}
%end

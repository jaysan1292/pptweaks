#import "Tweak.h"

#define callMemoryCleanup() [[[%c(UIApplication) sharedApplication] delegate] applicationDidReceiveMemoryWarning:[%c(UIApplication) sharedApplication]]

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
    debug(@"-[PPMapLayer addCityToTrip:%@]", [trip name]);

    // TODO: if clicked city isClosed,
    // check if the time remaining is greater than the flight time.
    // if true, then allow plane to fly there, else disallow it
    %orig;
    
    if(![PPTSettings enabled]) return;

    [self setVisibleCities];
}
-(void)removeLastLegFromTrip {
    debug(@"-[PPMapLayer removeLastLegFromTrip]");
    %orig;
    
    if(![PPTSettings enabled]) return;

    [self setVisibleCities];
}
%new -(void)setVisibleCities {
#define setDotOpacity(x) [getIvar(city, "dot") setOpacity:x]; [getIvar(city, "countLbl") setOpacity:x]
    startTimeLog(start);

    float mapScale = [[[[%c(PPScene) sharedScene] playerData] getMeta:@"mapZ"] floatValue];
    NSMutableArray* mapCities = getIvar(self, "mapCities");

    // oh god this is horrible, horrible code why why why
    if([PPTSettings mapOverviewEnabled]) {
        if(mapScale < 0.3f) {
            for(int i = 0; i < [mapCities count]; i++) {
            #define city [mapCities objectAtIndex:i]
                if(isObject(city)) {
                    if([city isKindOfClass:[%c(PPCity) class]] && city != nil) {
                        if(![[city info] isLocked]) {

                            // Scale the thing so it's more visible when zoomed out
                            if (mapScale == 0.25f) {
                                [city setScale:2.0f];
                                [self displayLabelForCity:city show:NO];
                            } else if (mapScale == 0.125f) {
                                [city setScale:4.0f];
                                [self displayLabelForCity:city show:NO];
                            }

                            /*
                            If selecting a trip, city is faded, and city is not destination
                            tripPicker = YES
                            isFaded    = YES
                            isDest     = NO
                            */
                            if(([self tripPicker]) && ([[city info] isFaded] && ![[city info] isDest])) {
                                [city setVisible:NO];
                            } else if([[city info] isDest]) {
                                [city setVisible:YES];
                                [self displayLabelForCity:city show:YES];
                            } else {
                                [city setVisible:YES];
                                [self displayLabelForCity:city show:NO];
                            }

                            if([[city info] isClosed]) {
                                setDotOpacity(64);
                            } else {
                                setDotOpacity(255);
                            }

                        }
                    }
                } else { debug(@"Warning! Thing in array is not an object D:"); } // This line should *never* be executed
            #undef city
            }
        } else {
            for(int i = 0; i < [mapCities count]; i++) {
            #define city [mapCities objectAtIndex:i]
                if(isObject(city)) {
                    if([city isKindOfClass:[%c(PPCity) class]]) {
                        if(![[city info] isLocked]) {
                            //only bother resetting the scale if it hasn't been changed yet
                            if([city scale] != 1.0f) {
                                [city setScale:1.0f];
                                [self displayLabelForCity:city show:YES];
                            }

                            if([[city info] isClosed]) {
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

#undef setDotOpacity(x)
}
%new -(void)hidePlanes {
    // debug(@"-[PPMapLayer hidePlanes]");
    startTimeLog(start);
    NSMutableArray* mapPlanes = getIvar(self, "mapPlanes");

    for(PPMapPlane* plane in mapPlanes) {
        if(!plane.showRange) {
            [plane setVisible:NO];
        }
    }

    endTimeLog(start, @"-[PPMapLayer hidePlanes]");
}
%new -(void)scalePlanes {
    // debug(@"-[PPMapLayer scalePlanes]");
    if([PPTSettings mapOverviewEnabled]) {
        float mapScale = [[[[%c(PPScene) sharedScene] playerData] getMeta:@"mapZ"] floatValue];
        NSMutableArray* mapPlanes = getIvar(self, "mapPlanes");
        startTimeLog(start);

        // debug(@"Scaling planes based on zoom level.");
        for(PPMapPlane* plane in mapPlanes) {
            if(![plane showRange]) {
                if(mapScale == 1.0f) {
                    [plane setScale:2.0f];
                } else if(mapScale == 0.5f) {
                    [plane setScale:1.0f];
                } else if(mapScale == 0.25f) {
                    [plane setScale:0.75f];
                } else if(mapScale == 0.125f) {
                    [plane setScale:0.5f];
                }
            }
        }
        endTimeLog(start, @"-[PPMapLayer scalePlanes]");
    }
}
%new -(void)fadePlanes {
    startTimeLog(start);

    NSMutableArray* mapPlanes = getIvar(self, "mapPlanes");

    for(PPMapPlane* plane in mapPlanes) {
        if([self tripPicker] && ![plane showRange]) {
            [getIvar(plane, "pMarker")  setOpacity:72];
            [getIvar(plane, "planeLbl") setOpacity:72];
            [getIvar(plane, "nameLbl")  setOpacity:72];
        }
    }

    endTimeLog(start, @"-[PPMapLayer fadePlanes]");
}
%new -(void)displayLabelForCity:(id)city show:(BOOL)show {
    [getIvar(city, "nameLbl") setVisible:show];
    [getIvar(city, "shadowLbl") setVisible:show];
    [getIvar(city, "detailLbl") setVisible:show];
    [getIvar(city, "detailShadowLbl") setVisible:show];
}
%end //}

%hook PPMapPlane //{
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
%new -(void)hidePlaneLabel:(PPMapPlane*)plane {
    if([PPTSettings hidePlaneLabels]) {
        startTimeLog(start);
        
        [getIvar(plane, "planeLbl") setVisible:NO];
        [getIvar(plane, "nameLbl") setVisible:NO];

        if([[[plane parent] parent] tripPicker]) {
            [getIvar(plane, "pMarker") setVisible:NO];
        }
        
        endTimeLogD(start, @"Hiding plane label for %@", [[plane info] name]);
    }
}
%end //}

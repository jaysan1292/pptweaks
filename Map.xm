#import "Tweak.h"

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
    if([PPTSettings enabled]) {
        [self setVisibleCities];
        [self scalePlanes];
    }
}
-(void)zoomMapIn {
    debug(@"-[PPMapLayer zoomMapIn]");
    %orig;
    if([PPTSettings enabled]) {
        [self setVisibleCities];
        [self scalePlanes];
    }
}
-(void)loadMapUI {
    debug(@"-[PPMapLayer loadMapUI]");
    %orig;
    if([PPTSettings enabled]) {
        [self setVisibleCities];
        if(self.tripPicker && ![PPTSettings tripPickerPlanes]) {
            [self hidePlanes];
        }
        [self scalePlanes];
        
        // disableTweetBtn();
    }
    callMemoryCleanup();
}
-(void)addCityToTrip:(id)trip {
    debug(@"-[PPMapLayer addCityToTrip:%@]", [trip name]);
    
    // if clicked city isClosed, 
    // check if the time remaining is greater than the flight time.
    // if true, then allow plane to fly there, else disallow it
    %orig;
    
    if([PPTSettings enabled]) [self setVisibleCities];
}
-(void)removeLastLegFromTrip {
    debug(@"-[PPMapLayer removeLastLegFromTrip]");
    %orig;
    if([PPTSettings enabled]) [self setVisibleCities];
}
void displayLabelForCity(id city, BOOL show) {
    // debug(@"displayLabelForCity(%@, %@)", [[city info] name], boolToString(show));
    ((CCNode*)getIvar(city, "nameLbl")).visible = show;
    ((CCNode*)getIvar(city, "shadowLbl")).visible = show;
    ((CCNode*)getIvar(city, "detailLbl")).visible = show;
    ((CCNode*)getIvar(city, "detailShadowLbl")).visible = show;
}
%new -(void)setVisibleCities {
// define local "constants" to save on memory usage
// oh god this is horrible code why
// TODO: Look at re-implementing this function; it could probably be done better
#define _mapScale [[[[%c(PPScene) sharedScene] playerData] getMeta:@"mapZ"] floatValue]
#define _mapCities getIvar(self, "mapCities")
#define _city [city info]
#define _nameLbl getIvar(city, "nameLbl")
#define _shadowLbl getIvar(city, "shadowLbl")
#define _detailLbl getIvar(city, "detailLbl")
#define _countLbl getIvar(city, "countLbl")
#define _detailShadowLbl getIvar(city, "detailShadowLbl")
#define _dot getIvar(city, "dot")
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
#define _mapPlanes getIvar(self, "mapPlanes")
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
#define _mapPlanes getIvar(self, "mapPlanes")
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
    // debug(@"-[PPMapPlane initWithInfo:%@ trip:%@]", [info name], [trip description]);
    CCNode* mapplane = %orig;

    if([PPTSettings hidePlaneLabels]) {
        [getIvar(mapplane, "planeLbl") setVisible:NO];
        [getIvar(mapplane, "nameLbl") setVisible:NO];
        if(((PPMapLayer*)mapplane.parent.parent).tripPicker) {
            [getIvar(mapplane, "pMarker") setVisible:NO];
        }
    }
    
    return mapplane;
}
%end //}

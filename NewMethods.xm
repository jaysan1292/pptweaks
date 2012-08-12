#import "Tweak.h"

%hook CCLabelBMFont

%end

%hook PPArrivalsLayer
%new -(int)itemsLoaded {
    int out;
    object_getInstanceVariable(self, "itemsLoaded", (void**)&out);
    return out;
}
%new -(void)updateBoardingLabels {
    if(![PPTSettings enabled] || ![PPTSettings detailedBoardingLabels]) return;
    debug(@"-[PPArrivalsLayer updateBoardingLabels]");
    PPList* list = getIvar(self, "list");

    // for(int i = 0; i < (int)[self itemsLoaded]; i++) {
    int i = 0;
    do {
        #define item [list itemAtIndex:i]
        // debug(@"Current index: %d, [[item children] count] = %d", i, [[item children] count]);
        if((int)[[item children] count] != 5 || i >= (int)[self itemsLoaded] - 1) break;

        if([[[item children] objectAtIndex:4] isMemberOfClass:[%c(CCSpriteBatchNode) class]]) {
            PPPlaneInfo* info = [[[item children] objectAtIndex:3] info];
            
            [[[item children] objectAtIndex:4] setVisible:NO];
            // [[item children] removeObject:[[item children] objectAtIndex:4]]; // this causes SIGSEGV

            // debug(@"Add label");
            NSString* label = nil;
            switch([info planeType]) {
                case PPPassengerPlaneType:
                    debug(@"%@ is a passenger-type plane.", [info name]);
                    label = formatString(@"%d/%dP", [info countForType:PPBitizenType], [info passRows]);
                    break;
                case PPCargoPlaneType:
                    debug(@"%@ is a cargo-type plane.", [info name]);
                    label = formatString(@"%d/%dC", [info countForType:PPCargoType], [info cargoRows]);
                    break;
                case PPMixedPlaneType:
                    debug(@"%@ is a mixed-type plane.", [info name]);
                    label = formatString(@"%d/%dC %d/%dP", [info countForType:PPCargoType], [info cargoRows], [info countForType:PPBitizenType], [info passRows]);
                    break;
                default:
                    break;
            }
            // debug(@"init new label with string \"%@\"", label);
            CCLabelBMFont* newLbl = [[%c(CCLabelBMFont) alloc] initWithString:label fntFile:@"silkscreen9.fnt"];
            [newLbl setPosition:ccp(214, 13)];

            //pulse label if full
            if([info isFull]) {
                debug(@"%@ is full!", [info name]);
                [newLbl setColor:ccYELLOW];
                // [newLbl runAction:
                //     [%c(CCRepeatForever) actionWithAction:
                //         [%c(CCSequence) actions:
                //             [%c(CCFadeIn) actionWithDuration:1.0],
                //             [%c(CCFadeOut) actionWithDuration:1.0],
                //             nil
                //         ]
                //     ]
                // ];
            }

            [[item children] addObject:newLbl];
        }
        #undef item
        i++;
    } while(true);
    //debug(@"finished iterating through list");
}
%end

%hook PPJobsLayer
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
        
        NSArray* ownedCities = [[NSArray alloc] initWithArray:[[[%c(PPScene) sharedScene] playerData] unlockedCities]];
        NSArray* campaigns = [ownedCities valueForKey:@"lastCampaign"];
        NSMutableArray* campaignCities = [[NSMutableArray alloc] init];
        
        for(int i = 0; i < [ownedCities count]; i++)
            if(![[campaigns objectAtIndex:i] isEqualToNumber:[NSNumber numberWithFloat:0.0f]])
                [campaignCities addObject:[ownedCities objectAtIndex:i]];
                
        if([campaignCities count] == 0) return;
        log(@"Cities currently advertising: %@", [campaignCities componentsJoinedByString:@", "]);
        
        NSMutableArray* adJobs = [[NSMutableArray alloc] init];
        
        for(int i = [_jobList count] - 1; i >= 0; i--) {
            #define theJob [_jobList objectAtIndex:i]
            if([[campaignCities valueForKey:@"city_id"] indexOfObject:[NSNumber numberWithInt:[theJob end_city_id]]] != NSNotFound)
                [adJobs addObject:theJob];
            #undef theJob
        }
        
        [_jobList removeObjectsInArray:adJobs];
        
        for(int i = 0; i < [adJobs count]; i++)
            [_jobList insertObject:[adJobs objectAtIndex:i] atIndex:1];
        
        if([adJobs count] != 0) log(@"Found %d advertised jobs!", [adJobs count]);
        
        [adJobs release];
        [campaignCities release];
        [ownedCities release];
        
        endTimeLog(aJobs, @"Looking for advertised jobs");
    }
    #undef _jobList
}
%end

%hook PPMapLayer
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
%end

%hook PPMapPlane
%new -(void)hidePlaneLabel:(PPMapPlane*)plane {
    if([PPTSettings hidePlaneLabels]) {
        [getIvar(plane, "planeLbl") setVisible:NO];
        [getIvar(plane, "nameLbl") setVisible:NO];

        if([[[plane parent] parent] tripPicker]) {
            [getIvar(plane, "pMarker") setVisible:NO];
        }
    }
}
%end

%hook PPPlaneInfo
%new -(PPPlaneType)planeType {
    PPPlaneType out;

    planeType(self, out);

    return out;
    // debug(@"-[PPPlaneInfo planeType]: %@", self);
    // if(self.cargoRows == 0) return PPPassengerPlaneType;
    // else if(self.passRows == 0) return PPCargoPlaneType;
    // else return PPMixedPlaneType;
}
%new -(NSUInteger)countForType:(PPCargoInfoType)type {
    NSArray* onboard = [[self cargo] valueForKey:@"type"];
    NSUInteger onCount = 0;
    
    debug(@"Onboard: %@", [onboard componentsJoinedByString:@", "]);
    if(type == PPBitizenType) {
        for(NSString* item in onboard) {
            if([item isEqualToString:@"b"]) onCount++;
        }
    } else if (type == PPCargoType) {
        for(NSString* item in onboard) {
            if([item isEqualToString:@"c"]) onCount++;
        }
    }

    return onCount;
}
%end

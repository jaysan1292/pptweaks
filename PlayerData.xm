#import "Tweak.h"

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
    if([PPTSettings enabled]) {
        return;
    } else {
        log(@"Spent %d bux.", bux);
        %orig;
    }
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
    if([PPTSettings enabled]) {
        startTimeLog(start);
        [planes sortUsingFunction:comparePlane context:nil];
        endTimeLogD(start, @"Sorting planes");
    }
    return planes;
}
%end //}

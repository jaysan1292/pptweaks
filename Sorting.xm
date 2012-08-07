#import "Tweak.h"

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
    PPPlaneType firstType;
    PPPlaneType secondType;
    
    if(first.cargoRows == 0 && first.passRows != 0) firstType = PPPassengerPlaneType;
    else if(first.cargoRows != 0 && first.passRows == 0) firstType = PPCargoPlaneType;
    else if(first.cargoRows != 0 && first.passRows != 0) firstType = PPMixedPlaneType;
    
    if(second.cargoRows == 0 && second.passRows != 0) secondType = PPPassengerPlaneType;
    else if(second.cargoRows != 0 && second.passRows == 0) secondType = PPCargoPlaneType;
    else if(second.cargoRows != 0 && second.passRows != 0) secondType = PPMixedPlaneType;
    
    // return firstType < secondType ? NSOrderedDescending : firstType > secondType ? NSOrderedAscending : NSOrderedSame;
    return firstType < secondType ? NSOrderedAscending : firstType > secondType ? NSOrderedDescending : NSOrderedSame;
}
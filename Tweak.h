#ifndef __TWEAK_H
#define __TWEAK_H

// #define DBG

#import <mach/mach.h>
#import <typeinfo>
#import <execinfo.h>
#import <signal.h>
#import <stdio.h>

typedef enum {
    PPPassengerPlaneType,
    PPCargoPlaneType,
    PPMixedPlaneType
} PPPlaneType;

typedef enum {
	PPBitizenType,
	PPCargoType
} PPCargoInfoType;

typedef enum {
	PPBodyPartType,
	PPControlsPartType,
	PPEnginePartType
} PPPlanePartType;

#import "PPTSettings.h"
#import "hookclasses.h"


#define boolToString(x) (x ? @"YES" : @"NO")
#define ccp(_X_,_Y_) CGPointMake(_X_,_Y_)
#define disableTweetBtn() if(![PPTSettings twitterEnabled]) { ((CCNode*)getIvar(self, "shareBtn")).positionInPixels = ccp(-9999.0, -9999.0); }
#define endTimeLog(var, str, args...) log(@"%@ took %.6fs.", [NSString stringWithFormat:str, ##args], fabs([var timeIntervalSinceNow]))
#define endTimeLogD(var, str, args...) debug(@"%@ took %.6fs.", [NSString stringWithFormat:str, ##args], fabs([var timeIntervalSinceNow]))
#define formatString(str, args...) [NSString stringWithFormat:str, ##args]
#define getIvar(var, name) object_getIvar(var, class_getInstanceVariable([var class], name))
#define getInstanceVariable(var, name, outval) object_getInstanceVariable(var, name, outval)
#define isObject(obj) ([[NSString stringWithFormat:@"%s", typeid(obj).name()] rangeOfString:@"objc_object"].location != NSNotFound)
#define log(str, args...) NSLog(@"[PPT-%@:%d]: %@", [[[NSString stringWithCString:__FILE__ encoding:NSASCIIStringEncoding] componentsSeparatedByString:@"."] objectAtIndex:0], __LINE__, [NSString stringWithFormat:str, ##args])
#define startTimeLog(var) NSDate* var = [NSDate date]
#define planeType(plane, outvar) \
if(plane.cargoRows == 0) { outvar = PPPassengerPlaneType; } \
else if(plane.passRows == 0) { outvar = PPCargoPlaneType; } \
else { outvar = PPMixedPlaneType; }

#ifdef DBG
#define debug(str, args...) log(str, ##args)
#else
#define debug(str, args...)
#endif

float get_memory();
NSString* return_memory();
void report_memory();
void print_backtrace();
// PPPlaneType planeType(PPPlaneInfo* plane); 

NSComparisonResult compareEvent(NSString* first, NSString* second, void *context);
NSComparisonResult compareJobDist(PPCargoInfo* first, PPCargoInfo* second, void *context);
NSComparisonResult compareJobFare(PPCargoInfo* first, PPCargoInfo* second, void *context);
NSComparisonResult comparePlane(PPPlaneInfo* first, PPPlaneInfo* second, void* context);
NSComparisonResult comparePlaneClass(PPPlaneInfo* first, PPPlaneInfo* second, void* context);
NSComparisonResult comparePlaneName(PPPlaneInfo* first, PPPlaneInfo* second, void* context);
NSComparisonResult comparePlaneSpeed(PPPlaneInfo* first, PPPlaneInfo* second, void* context);
NSComparisonResult comparePlanePart(PPPlanePartInfo* first, PPPlanePartInfo* second, void* context) ;
NSComparisonResult comparePlanePartType(PPPlanePartInfo* first, PPPlanePartInfo* second, void* context) ;

#endif

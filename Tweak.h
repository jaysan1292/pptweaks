#ifndef __TWEAK_H
#define __TWEAK_H

#import <mach/mach.h>
#import <typeinfo>
#import <execinfo.h>

#import "PPTSettings.h"
#import "hookclasses.h"

#define DBG

#define boolToString(x) (x ? @"YES" : @"NO")
#define ccp(_X_,_Y_) CGPointMake(_X_,_Y_)
#define disableTweetBtn() if(![PPTSettings twitterEnabled]) { ((CCNode*)getIvar(self, "shareBtn")).positionInPixels = ccp(-9999.0, -9999.0); }
#define endTimeLog(var, str, args...) log(@"%@ took %.6fs.", [NSString stringWithFormat:str, ##args], fabs([var timeIntervalSinceNow]))
#define endTimeLogD(var, str, args...) debug(@"%@ took %.6fs.", [NSString stringWithFormat:str, ##args], fabs([var timeIntervalSinceNow]))
#define formatString(str, args...) [NSString stringWithFormat:str, ##args]
#define getIvar(var, name) object_getIvar(var, class_getInstanceVariable([var class], name))
#define isObject(obj) ([[NSString stringWithFormat:@"%s", typeid(obj).name()] rangeOfString:@"objc_object"].location != NSNotFound)
#define log(str, args...) NSLog(@"[PPT-%@:%d]: %@", [[[NSString stringWithCString:__FILE__ encoding:NSASCIIStringEncoding] componentsSeparatedByString:@"."] objectAtIndex:0], __LINE__, [NSString stringWithFormat:str, ##args])
#define startTimeLog(var) NSDate* var = [NSDate date]

#ifdef DBG
#define debug(str, args...) log(str, ##args)
#else
#define debug(str, args...)
#endif

float get_memory();
NSString* return_memory();
void report_memory();
void print_backtrace();

typedef enum {
    PPNilPlaneType,
    PPPassengerPlaneType,
    PPCargoPlaneType,
    PPMixedPlaneType
} PPPlaneType;

NSComparisonResult compareEvent(NSString* first, NSString* second, void *context);
NSComparisonResult compareJobDist(PPCargoInfo* first, PPCargoInfo* second, void *context);
NSComparisonResult compareJobFare(PPCargoInfo* first, PPCargoInfo* second, void *context);
NSComparisonResult comparePart(PPPlanePartInfo*, PPPlanePartInfo*, void*);
NSComparisonResult comparePartName(PPPlanePartInfo*, PPPlanePartInfo*, void*);
NSComparisonResult comparePartPrice(PPPlanePartInfo*, PPPlanePartInfo*, void*);
NSComparisonResult comparePlane(PPPlaneInfo* first, PPPlaneInfo* second, void* context);
NSComparisonResult comparePlaneClass(PPPlaneInfo* first, PPPlaneInfo* second, void* context);
NSComparisonResult comparePlaneName(PPPlaneInfo* first, PPPlaneInfo* second, void* context);
NSComparisonResult comparePlaneSpeed(PPPlaneInfo* first, PPPlaneInfo* second, void* context);

#endif

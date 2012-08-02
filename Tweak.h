#ifndef __TWEAK_H
#define __TWEAK_H

#import <mach/mach.h>
#import <typeinfo>
#import <execinfo.h>
#import "hookclasses.h"

#define DBG

#define getIvar(var, name) object_getIvar(var, class_getInstanceVariable([var class], name))
#define formatString(str, args...) [NSString stringWithFormat:str, ##args]
#define boolToString(x) (x ? @"YES" : @"NO")
#define log(str, args...) NSLog(@"[PPTweaks-%.1s:%-3d]: %@", __FILE__, __LINE__, [NSString stringWithFormat:str, ##args])
#define startTimeLog(var) NSDate* var = [NSDate date]
#define endTimeLog(var, str, args...) log(@"%@ took %.6fs.", [NSString stringWithFormat:str, ##args], fabs([var timeIntervalSinceNow]))
#define endTimeLogD(var, str, args...) debug(@"%@ took %.6fs.", [NSString stringWithFormat:str, ##args], fabs([var timeIntervalSinceNow]))
#define ccp(_X_,_Y_) CGPointMake(_X_,_Y_)
#define isObject(obj) ([[NSString stringWithFormat:@"%s", typeid(obj).name()] rangeOfString:@"objc_object"].location != NSNotFound)
#define disableTweetBtn() ((CCNode*)getIvar(self, "shareBtn")).positionInPixels = ccp(-9999.0, -9999.0)

#ifdef DBG
#define debug(str, args...) NSLog(@"[PPTweaks-%.1s:%-3d]: %@", __FILE__, __LINE__, [NSString stringWithFormat:str, ##args])
#else
#define debug(str, args...)
#define logMemoryUsage()
#endif

float get_memory();
NSString* return_memory();
void report_memory();
void print_backtrace();

@interface PPTSettings {}
+(BOOL)enabled;
+(BOOL)twitterEnabled;
+(BOOL)soundOnNewJobs;
+(BOOL)planeLandingNotifications;
+(BOOL)sortEventProgress;
+(BOOL)mapOverviewEnabled;
+(BOOL)hidePlaneLabels;
+(BOOL)moreDetailedTime;
+(BOOL)tripPickerPlanes;
+(BOOL)eventJobsOnTop;

+(void)reconfigure;
+(void)setup;
+(NSString*)pathOfSettingsFile;
+(NSString*)pathOfUserSettingsFile;
+(NSDictionary*)parseSettingsFile;
@end

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

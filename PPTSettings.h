#ifndef __PPTSETTINGS_H
#define __PPTSETTINGS_H

#import "Tweak.h"

@interface PPTSettings {}
+(void)initialize;
+(void)reconfigure;
+(NSString*)pathOfSettingsFile;
+(NSString*)pathOfUserSettingsFile;
+(NSMutableDictionary*)parseSettingsFile;

+(BOOL)enabled;
+(BOOL)twitterEnabled;
+(BOOL)soundOnNewJobs;
+(BOOL)planeLandingNotifications;
+(BOOL)sortEventProgress;
+(BOOL)mapOverviewEnabled;
+(BOOL)hidePlaneLabels;
+(BOOL)moreDetailedTime;
+(BOOL)tripPickerPlanes;
+(BOOL)globalEventJobsOnTop;
+(BOOL)normalEventJobsOnTop;
+(BOOL)sortEventsBelowClass;
@end

#endif

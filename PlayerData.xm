#import "Tweak.h"

#define playSound(sound) [[%c(SimpleAudioEngine) sharedEngine] playEffect:[%c(CDUtilities) fullPathFromRelativePath:sound]];

%hook PPPlayerData
-(id)planes {
    id planes = %orig;

    if([PPTSettings enabled]) {
        startTimeLog(start);
        [planes sortUsingFunction:comparePlane context:nil];
        endTimeLogD(start, @"Sorting planes");
    }

    return planes;
}
%end

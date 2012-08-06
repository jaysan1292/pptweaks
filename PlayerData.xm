#import "Tweak.h"

%hook PPPlayerData //{
-(void)spendBux:(int)bux {
    log(@"Spent %d bux.", bux);
    %orig;
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

#import "Tweak.h"

#define formatNumber(x) [%c(PPScene) numString:x]
// #define showDialog(

static NSUInteger totalCoinsEarned = 0;
static NSUInteger totalCoinsSpent = 0;
static NSUInteger totalBuxEarned = 0;
static NSUInteger totalBuxSpent = 0;

@interface PPTStats {
}
+(NSUInteger)getSessionCoinsEarned;
+(NSUInteger)getSessionCoinsSpent;
+(NSUInteger)getSessionBuxEarned;
+(NSUInteger)getSessionBuxSpent;
+(NSInteger)getSessionCoinProfit;
+(NSInteger)getSessionBuxProfit;
+(NSString*)getBuxProfitString;
+(NSString*)getCoinProfitString;
+(NSString*)getSummaryString;
@end

@implementation PPTStats
+(NSUInteger)getSessionCoinsEarned {
    return totalCoinsEarned;
}
+(NSUInteger)getSessionCoinsSpent {
    return totalCoinsSpent;
}
+(NSUInteger)getSessionBuxEarned {
    return totalBuxEarned;
}
+(NSUInteger)getSessionBuxSpent {
    return totalBuxSpent;
}
+(NSInteger)getSessionCoinProfit {
    return (NSInteger)([PPTStats getSessionCoinsEarned] - [PPTStats getSessionCoinsSpent]);
}
+(NSInteger)getSessionBuxProfit {
    return (NSInteger)([PPTStats getSessionBuxEarned] - [PPTStats getSessionBuxSpent]);
}
+(NSString*)getBuxProfitString {
    return formatString(@"Bux earned this session: %@", formatNumber([PPTStats getSessionBuxProfit]));
}
+(NSString*)getCoinProfitString {
    return formatString(@"Coins earned this session: %@", formatNumber([PPTStats getSessionCoinProfit]));
}
+(NSString*)getSummaryString {
    return formatString(@"%@ | %@", [PPTStats getCoinProfitString], [PPTStats getBuxProfitString]);
}
@end

%hook PPPlayerData
-(void)addBux:(int)bux {
    totalBuxEarned += bux;
    log(@"Added %@ bux. Earned this session: %@", formatNumber(bux), formatNumber([PPTStats getSessionBuxProfit]));
    %orig;
}
-(void)spendBux:(int)bux {
    totalBuxSpent += bux;
    log(@"Spent %@ bux. Earned this session: %@", formatNumber(bux), formatNumber([PPTStats getSessionBuxProfit]));
    %orig;
}
-(void)addCoins:(int)coins {
    totalCoinsEarned += coins;
    log(@"Added %@ %s. Earned this session: %@", formatNumber(coins), coins == 1 ? "coin":"coins", formatNumber([PPTStats getSessionCoinProfit]));
    %orig;
}
-(void)spendCoins:(int)coins {
    totalCoinsSpent += coins;
    log(@"Spent %@ %s. Earned this session: %@", formatNumber(coins), coins == 1 ? "coin":"coins", formatNumber([PPTStats getSessionCoinProfit]));
    %orig;
}
%end

// %hook PPHud
// -(void)ccTouchEnded:(id)ended withEvent:(id)event {
// #define coinLbl getIvar(self, "coinLabel")
// #define buxLbl getIvar(self, "buxLabel")
//     // debug(@"-[PPHud ccTouchEnded:<UITouch> withEvent:<UITouchesEvent>]");
//     %orig;
//     
//     CGPoint location = [self convertTouchToNodeSpace:ended];
//     CGRect cLblRect = ((CCNode*)coinLbl).boundingBox;
//     CGRect bLblRect = ((CCNode*)buxLbl).boundingBox;
//     
//     if(CGRectContainsPoint(cLblRect, location)) {
//         debug(@"coinLabel tapped");
//         PPDialog* dialog = [[%c(PPDialog) alloc] initWithMessage:[PPTStats getCoinProfitString] buttons:[@"OK" componentsSeparatedByString:@"|"] callback:nil target:self data:nil];
//         [[%c(PPDialogQueue) sharedQueue] addDialog:dialog];
//         [dialog release];
//     }
//     if (CGRectContainsPoint(bLblRect, location)) {
//         debug(@"buxLabel tapped");
//         PPDialog* dialog = [[%c(PPDialog) alloc] initWithMessage:[PPTStats getBuxProfitString] buttons:[@"OK" componentsSeparatedByString:@"|"] callback:nil target:self data:nil];
//         [[%c(PPDialogQueue) sharedQueue] addDialog:dialog];
//         [dialog release];
//     }
// #undef coinLbl
// #undef buxLbl
// }
// %end
// 
// %hook PPDialog
// -(id)initWithMessage:(id)message buttons:(id)buttons callback:(SEL)callback target:(id)target data:(id)data {
//     debug(@"-[PPDialog initWithMessage:%@ buttons:%@ callback:'%@' target:%@ data:%@", message, [buttons class], NSStringFromSelector(callback), target, data);
//     %orig;
// }
// %end

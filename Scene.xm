#import "Tweak.h"

#define showDropdown(str, args...) id dd = [[%c(PPDropdown) alloc] initWithMessage:[NSString stringWithFormat:str, ##args] callback:nil target:nil data:nil sound:nil buzz:NO]; [[%c(PPDropdownQueue) sharedQueue] addDropdown:dd]; [dd release]

%hook PPScene
-(id)init {
    debug(@"-[PPScene init]");
    return %orig;
}
+(NSString*)timeString:(int)string {
    if([PPTSettings moreDetailedTime]) {
        int days = (int)(string/(24*60*60));
        int hours = (string/(60*60))%24;
        int minutes = (string/60)%60;
        int seconds = (int)(10 * ceil((string%60) / 10 + 0.5));
        
        if(seconds == 60) { minutes++; seconds = 0; }
        if(minutes == 60) { hours++; minutes = 0; }
        if(hours == 24) { days++; hours = 0; }
        
        if (string < 0) {
            return @"LANDED";
        } else if(days > 0) {
            return formatString(@"%@%@",
                                hours == 0 ? [NSString stringWithFormat:@"%dd", days] : [NSString stringWithFormat:@"%dd, ", days],
                                hours == 0 ? @"" : [NSString stringWithFormat:@"%dh", hours]);
        } else if(hours > 0) {
            return formatString(@"%@%@",
                                minutes == 0 ? [NSString stringWithFormat:@"%dh", hours] : [NSString stringWithFormat:@"%dh, ", hours],
                                minutes == 0 ? @"" : [NSString stringWithFormat:@"%dm", minutes]);
        } else if(minutes > 0) {
            return formatString(@"%@%@",
                                seconds == 0 ? [NSString stringWithFormat:@"%dm", minutes] : [NSString stringWithFormat:@"%dm, ", minutes],
                                seconds == 0 ? @"" : [NSString stringWithFormat:@"%ds", seconds]);
        } else {
            return string == 0 ? @"10s" : [NSString stringWithFormat:@"%ds", seconds];
        }
    } else {
        return %orig;
    }
}
-(void)tweet:(id)tweet withImage:(id)image {
#ifdef DBG
    debug(@"-[PPScene tweet:%@ withImage:%@]", [tweet description], [image description]);
    showDropdown(return_memory());
#else
    %orig;
#endif
}

// convenience methods for Cycript
%new +(CGPoint)pointWithX:(int)x Y:(int)y {
    return ccp(x, y);
}
%end

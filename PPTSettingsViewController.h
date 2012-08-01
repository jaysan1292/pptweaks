#import "Tweak.h"

@interface PPTSettingsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>{
NSDictionary* settings;
NSMutableDictionary* userSettings;
UIView* contentView;
UINavigationBar* navBar;
UITableView* settingsTableView;
}
@end
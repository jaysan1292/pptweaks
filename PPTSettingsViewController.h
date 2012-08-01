#import "Tweak.h"

@interface PPTSettingsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>{
NSDictionary* settings;
NSDictionary* userSettings;
UIView* contentView;
UINavigationBar* navBar;
UITableView* settingsTableView;
}
@end
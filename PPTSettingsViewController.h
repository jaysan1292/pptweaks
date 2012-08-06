#ifndef __PPTSETTINGSVIEWCONTROLLER_H
#define __PPTSETTINGSVIEWCONTROLLER_H

#import "Tweak.h"

@interface PPTSettingsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>{
NSDictionary* settings;
NSMutableDictionary* userSettings;
NSMutableDictionary* settingMap;
UIView* contentView;
UINavigationBar* navBar;
UITableView* settingsTableView;
}
@property (nonatomic, retain) NSDictionary* settings;
@property (nonatomic, retain) NSMutableDictionary* userSettings;
@property (nonatomic, retain) NSMutableDictionary* settingMap;
@property (nonatomic, retain) UIView* contentView;
@property (nonatomic, retain) UINavigationBar* navBar;
@property (nonatomic, retain) UITableView* settingsTableView;
@end

#endif
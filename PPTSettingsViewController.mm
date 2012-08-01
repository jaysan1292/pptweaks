#import "Tweak.h"
#import "PPTSettingsViewController.h"

@interface PPTSettingsViewController()
@property (nonatomic, retain) NSDictionary* settings;
@property (nonatomic, retain) NSDictionary* userSettings;
@property (nonatomic, retain) NSDictionary* settingMap;
@property (nonatomic, retain) UIView* contentView;
@property (nonatomic, retain) UINavigationBar* navBar;
@property (nonatomic, retain) UITableView* settingsTableView;
@end

@implementation PPTSettingsViewController
@synthesize settings, userSettings, settingMap;
@synthesize contentView, navBar, settingsTableView;

-(void)loadView {
    debug(@"-[PPTSettingsViewController loadView]");
    contentView = [[UIView alloc] initWithFrame:CGRectMake(80,320,320,480)];
    
    contentView.autoresizesSubviews = YES;
    contentView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    contentView.backgroundColor = [UIColor clearColor];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.4];
    
    [contentView setFrame:CGRectMake(0,0,320,480)];
    [self setView:contentView];
    
    [UIView commitAnimations];

    [contentView release];
    
    navBar = [[UINavigationBar alloc] init];
    navBar.frame = CGRectMake(0,0,self.view.frame.size.height,44);
    
    UINavigationItem* navItem = [[UINavigationItem alloc] initWithTitle:@"Tweak Settings"];
    navBar.items = [NSArray arrayWithObject:navItem];
    
    UIBarButtonItem* exitButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonPressed)];
    navItem.rightBarButtonItem = exitButton;
    
    [self.view addSubview:navBar];
    
    [navBar release];
    
    settingsTableView = [[UITableView alloc] initWithFrame:CGRectMake(0,44,320,436) style:UITableViewStyleGrouped];
    [settingsTableView setAutoresizesSubviews:YES];
    [settingsTableView setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
    
    [settingsTableView setDataSource:self];
    [settingsTableView setDelegate:self];
    
    [[self view] addSubview:settingsTableView];
    
    [settingsTableView release];
}
-(void)doneButtonPressed {
    [PPTSettings reconfigure];

    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.4];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(closeAnimationDidFinish:finished:context:)];
    
    [self.view setFrame:CGRectMake(0,320,480,320)];
    
    [UIView commitAnimations];
}
-(void)closeAnimationDidFinish:(NSString*)animationID finished:(NSNumber*)finished context:(void*)context {
    debug(@"self.view.retainCount: %d", self.view.retainCount);
    [self.view removeFromSuperview];
    debug(@"self.view.retainCount: %d", self.view.retainCount);
}

-(void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
-(void)dealloc {
    debug(@"-[PPTSettingsViewController dealloc]");
    [settings release];
    [userSettings release];
    [super dealloc];
}

// View lifecycle
-(void)viewDidLoad {
    [super viewDidLoad];
    
    debug(@"-[PPTSettingsViewController viewDidLoad]");
    
    self.settings = [PPTSettings parseSettingsFile];
    self.userSettings = [NSDictionary dictionaryWithContentsOfFile:[PPTSettings pathOfUserSettingsFile]];
}
-(void)viewDidUnload {
    [super viewDidUnload];
    
    debug(@"-[PPTSettingsViewController viewDidUnload]");
    
    self.settings = nil;
    self.userSettings = nil;
}
-(void)viewWillAppear:(BOOL)animated {
    debug(@"-[PPTSettingsViewController viewWillAppear:%@]", boolToString(animated));
    [super viewWillAppear:animated];
}
-(void)viewDidAppear:(BOOL)animated {
    debug(@"-[PPTSettingsViewController viewDidAppear:%@]", boolToString(animated));
    [super viewDidAppear:animated];
}
-(void)viewWillDisappear:(BOOL)animated {
    debug(@"-[PPTSettingsViewController viewWillDisappear:%@]", boolToString(animated));
    [super viewWillDisappear:animated];
}
-(void)viewDidDisappear:(BOOL)animated {
    debug(@"-[PPTSettingsViewController viewDidDisappear:%@]", boolToString(animated));
    [super viewDidDisappear:animated];
}
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

// Table view data source
-(NSInteger)numberOfSectionsInTableView:(UITableView*)tableView {
    return [[self.settings objectForKey:@"sections"] count];
}
-(NSString*)tableView:(UITableView*)tableView titleForHeaderInSection:(NSInteger)section {
    return [[[[self.settings objectForKey:@"sections"] allObjects] objectAtIndex:section] objectForKey:@"label"];
}
-(NSString*)tableView:(UITableView*)tableView titleForFooterInSection:(NSInteger)section {
    return [[[[self.settings objectForKey:@"sections"] allObjects] objectAtIndex:section] objectForKey:@"footerText"];
}
-(NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section {
    return [[[[[self.settings objectForKey:@"sections"] allObjects] objectAtIndex:section] objectForKey:@"items"] count];
}
-(UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath {
    UITableViewCell* cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
    
    UISwitch* theSwitch = [[[UISwitch alloc] init] autorelease];
    [theSwitch setOn:[[self.userSettings objectForKey:[[[[[[[self.settings objectForKey:@"sections"] allObjects] objectAtIndex:indexPath.section] objectForKey:@"items"] allObjects] objectAtIndex:indexPath.row] objectForKey:@"key"]] boolValue] animated:NO];
    [theSwitch addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
    //TODO: use settingMap to set up tags and stuff
    
    cell.textLabel.text = [[[[[[[self.settings objectForKey:@"sections"] allObjects] objectAtIndex:indexPath.section] objectForKey:@"items"] allObjects] objectAtIndex:indexPath.row] objectForKey:@"label"];
    cell.accessoryView = theSwitch;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
-(void)switchChanged:(id)sender {
    debug(@"-[PPTSettingsViewController switchChanged]");
    // TODO: When a switch changes, figure out which one changed and update its value in the user's settings
}
@end

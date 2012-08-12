#import "Tweak.h"
#import "PPTSettingsViewController.h"

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
    
    [exitButton release];
    [navItem release];
    [navBar release];
    
    settingsTableView = [[UITableView alloc] initWithFrame:CGRectMake(0,44,320,436) style:UITableViewStyleGrouped];
    [settingsTableView setAutoresizesSubviews:YES];
    [settingsTableView setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
    
    [settingsTableView setDataSource:self];
    [settingsTableView setDelegate:self];
    
    [self.view addSubview:settingsTableView];
    
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
    [self.view removeFromSuperview];
}

-(void)didReceiveMemoryWarning {
    debug(@"-[PPTSettingsViewController didReceiveMemoryWarning]");
    [super didReceiveMemoryWarning];
}
-(void)dealloc {
    debug(@"-[PPTSettingsViewController dealloc]");
    
    [settings release];
    [userSettings release];
    [settingMap release];
    navBar = nil;
    settingsTableView = nil;
    contentView = nil;
    
    [super dealloc];
}
// View lifecycle
-(void)viewDidLoad {
    [super viewDidLoad];
    
    debug(@"-[PPTSettingsViewController viewDidLoad]");
    
    self.settings = [PPTSettings parseSettingsFile];
    self.userSettings = [NSMutableDictionary dictionaryWithContentsOfFile:[PPTSettings pathOfUserSettingsFile]];
    self.settingMap = [[NSMutableDictionary alloc] initWithCapacity:1];
}
-(void)viewWillUnload {
    debug(@"-[PPTSettingsViewController viewWillUnload]");    
    [super viewWillUnload];
}
-(void)viewDidUnload {
    debug(@"-[PPTSettingsViewController viewDidUnload]");
    
    self.settings = nil;
    self.userSettings = nil;
    self.settingMap = nil;
    [self.view release];
    [self release];
    
    [super viewDidUnload];
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
    [self release];
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
#define theKey [[[[[[[self.settings objectForKey:@"sections"] allObjects] objectAtIndex:indexPath.section] objectForKey:@"items"] allObjects] objectAtIndex:indexPath.row] objectForKey:@"key"]
    UITableViewCell* cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
    
    UISwitch* theSwitch = [[[UISwitch alloc] init] autorelease];
    [theSwitch setOn:[[self.userSettings objectForKey:[[[[[[[self.settings objectForKey:@"sections"] allObjects] objectAtIndex:indexPath.section] objectForKey:@"items"] allObjects] objectAtIndex:indexPath.row] objectForKey:@"key"]] boolValue] animated:NO];
    [theSwitch addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
    
    [self.settingMap setObject:theSwitch forKey:theKey];
    
    cell.textLabel.text = [[[[[[[self.settings objectForKey:@"sections"] allObjects] objectAtIndex:indexPath.section] objectForKey:@"items"] allObjects] objectAtIndex:indexPath.row] objectForKey:@"label"];
    cell.accessoryView = theSwitch;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
#undef theKey
}
-(void)switchChanged:(UISwitch*)sender {
    debug(@"-[PPTSettingsViewController switchChanged]");
    
    if([[self.settingMap allKeysForObject:sender] count] != 0) {
        NSString* key = [[self.settingMap allKeysForObject:sender] objectAtIndex:0];
        
        log(@"Setting %@ %@", key, sender.on ? @"ON" : @"OFF");
        
        [self.userSettings setValue:[NSNumber numberWithBool:sender.on] forKey:key];
        
        if([self.userSettings writeToFile:[PPTSettings pathOfUserSettingsFile] atomically:YES]) {
            log(@"Successfully wrote user tweak settings to %@.", [PPTSettings pathOfUserSettingsFile]);
        }
    } else {
        log(@"Error! Setting not found for some reason :C");
    }
}
@end

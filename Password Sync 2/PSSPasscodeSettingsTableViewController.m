//
//  PSSSettingsTableViewController.m
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-08-14.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import "PSSPasscodeSettingsTableViewController.h"
#import "PSSPasswordSyncOneDataImporter.h"
#import "PSSAppDelegate.h"
#import "PSSWelcomeScreenPasscodeModeChooserTableViewController.h"
#import "Appirater.h"

@interface PSSPasscodeSettingsTableViewController ()

@end

@implementation PSSPasscodeSettingsTableViewController

-(void)lockUIAction:(id)notification{
    [self.navigationController popToRootViewControllerAnimated:NO];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)presentPasscodeEditor{
    UIStoryboard * welcomeStoryboard;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        welcomeStoryboard = [UIStoryboard storyboardWithName:@"FirstLaunchStoryboard_iPad" bundle:[NSBundle mainBundle]];
    } else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        welcomeStoryboard = [UIStoryboard storyboardWithName:@"FirstLaunchStoryboard_iPhone" bundle:[NSBundle mainBundle]];
    }
    
    
    PSSWelcomeScreenPasscodeModeChooserTableViewController * passcodeChooserController = [welcomeStoryboard instantiateViewControllerWithIdentifier:@"passcodeChooserTypeSelectorViewController"];
    
    UINavigationController * navController = [[UINavigationController alloc] initWithRootViewController:passcodeChooserController];
    
    [self presentViewController:navController animated:YES completion:NULL];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.title = NSLocalizedString(@"Passcode", nil);
    }
    
    // Subscribe to the lock notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(lockUIAction:) name:PSSGlobalLockNotification object:nil];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"normalCell"];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Table view data source

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 0) {
        return 80.;
    }
    
    return 44.;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section==0) {
        // Checkboxes
        return 2;
    } else if (section == 1) {
        return 1;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==0) {
        static NSString *CellIdentifier = @"settingsSubtitleTableViewCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        
        NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
        
        if (indexPath.section == 0) {
            // Passcode
            
            UISwitch * accessorySwitch = [[UISwitch alloc] init];
            
            cell.accessoryView = accessorySwitch;
            
            if (indexPath.row == 0) {
                // Prompt on launch
                
                if ([[userDefaults objectForKey:PSSUserSettingsPromptForPasscodeAtEveryLaunch] boolValue]) {
                    [accessorySwitch setOn:YES animated:NO];
                } else {
                    [accessorySwitch setOn:NO animated:NO];
                }
                
                [accessorySwitch addTarget:self action:@selector(promptForPasscodeOnLaunchHandler:) forControlEvents:UIControlEventValueChanged];
                
                
                cell.textLabel.text = NSLocalizedString(@"Prompt on launch", nil);
                cell.detailTextLabel.text = NSLocalizedString(@"When on, will ask for a passcode every time the app launches.", nil);
                
            } else if (indexPath.row == 1) {
                
                
                // Prompt for every item
                if ([[userDefaults objectForKey:PSSUserSettingsPromptForPasscodeForEveryUnlockedEntry] boolValue]) {
                    [accessorySwitch setOn:YES animated:NO];
                } else {
                    [accessorySwitch setOn:NO animated:NO];
                }
                
                [accessorySwitch addTarget:self action:@selector(promptForPasscodeOnEveryEntry:) forControlEvents:UIControlEventValueChanged];
                
                
                cell.textLabel.text = NSLocalizedString(@"Prompt for every entry", nil);
                cell.detailTextLabel.text = NSLocalizedString(@"When on, will ask for a passcode for every unlocked website's password, card, location and document.", nil);
                
                
                
            }
            
            
        }
        
          return cell;
          
        
        
    } else if (indexPath.section == 1) {
            
            // Other actions
            
            if (indexPath.row == 0) {
                // Change Passcode
                
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"normalCell" forIndexPath:indexPath];
                
                cell.textLabel.text = NSLocalizedString(@"Change Passcode", nil);
                cell.textLabel.textColor = self.view.window.tintColor;
                
                return cell;
            }
            
            
        }
    
    return nil;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    if (indexPath.section==1 && indexPath.row == 0) {
        // Edit passcode
        
        [self presentPasscodeEditor];
    }
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark - UISwitch handlers
-(void)promptForPasscodeOnLaunchHandler:(UISwitch*)sender{
    NSUserDefaults * standardUserDefaults = [NSUserDefaults standardUserDefaults];
    [standardUserDefaults setObject:[NSNumber numberWithBool:sender.isOn] forKey:PSSUserSettingsPromptForPasscodeAtEveryLaunch];
    [standardUserDefaults synchronize];
}

-(void)promptForPasscodeOnEveryEntry:(UISwitch*)sender{
    NSUserDefaults * standardUserDefaults = [NSUserDefaults standardUserDefaults];
    [standardUserDefaults setObject:[NSNumber numberWithBool:sender.isOn] forKey:PSSUserSettingsPromptForPasscodeForEveryUnlockedEntry];
    [standardUserDefaults synchronize];
}

@end

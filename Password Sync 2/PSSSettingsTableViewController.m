//
//  PSSSettingsTableViewController.m
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-08-14.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import "PSSSettingsTableViewController.h"
#import "PSSPasswordSyncOneDataImporter.h"
#import "PSSAppDelegate.h"

@interface PSSSettingsTableViewController ()

@end

@implementation PSSSettingsTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.title = NSLocalizedString(@"Settings", nil);
    }
    
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"normalCell"];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 0) {
        return 80.;
    }
    
    return 44.;
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return NSLocalizedString(@"Passcode", nil);
    }
    return @"";
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section==0) {
        // Passcode
        return 2;
    } else if (section == 1) {
        return 3;
    } else if (section==2) {
        // legal (and import from Password Sync One
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"passsyncjsonexport://passsynctwoupgrade?enckey=ABCD"]])
            return 2;
        
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
        
        static NSString * cellIdentifier = @"normalCell";
        if (indexPath.row == 0) {
            // Facebook
            
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
            
            cell.textLabel.text = @"Like™";
            
            cell.imageView.image = [UIImage imageNamed:@"Facebook"];
            return cell;
            
        } else if (indexPath.row== 1) {
            
            // Pinterest
            
            
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
            
            cell.textLabel.text = @"Pin It™";
            
            cell.imageView.image = [UIImage imageNamed:@"Pinterest"];
            return cell;
            
        } else if (indexPath.row == 2) {
            
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
            
            cell.textLabel.text = @"@PasswordSync";
            
            cell.imageView.image = [UIImage imageNamed:@"Twitter"];
            return cell;
            
        }
        
        
        
        
        
    } else if (indexPath.section==2){
        
        
        // Legal and import

        if (indexPath.row == 0) {
        
            static NSString *CellIdentifier = @"submenuCell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        
            cell.textLabel.text = NSLocalizedString(@"Legal", nil);
        
            cell.imageView.image = [[UIImage imageNamed:@"Mug"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            return cell;

        } else if (indexPath.row == 1) {
            
            static NSString * cellIdentifier = @"normalCell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
            
            cell.textLabel.text = NSLocalizedString(@"Import from Password Sync 1", nil);
            
            cell.imageView.image = [UIImage imageNamed:@"PasswordSyncOne"];
            return cell;

            
        }
    }
    
    return nil;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 1) {
        // Social
        UIApplication* app = [ UIApplication sharedApplication ];
        
        if (indexPath.row == 0) {
            // Facebook
            NSURL* facebookURL = [ NSURL URLWithString: @"https://facebook.com/passwordSync" ];
            NSURL* facebookAppURL = [ NSURL URLWithString: @"fb://profile/562323427160523" ];
            if( [ app canOpenURL: facebookAppURL ] ) {
                [ app openURL: facebookAppURL ];
            } else {
                [ app openURL: facebookURL ];
            }
            
            
        } else if (indexPath.row == 1) {
            // Pinterest
            
            NSURL* pinterestURL = [ NSURL URLWithString: @"https://pinterest.com/passwordsync/" ];
            NSURL* pinterestAppURL = [ NSURL URLWithString: @"pinterest://user/passwordsync/" ];
            if( [ app canOpenURL: pinterestAppURL ] ) {
                [ app openURL: pinterestAppURL ];
            } else {
                [ app openURL: pinterestURL ];
            }
            
        } else if (indexPath.row == 2) {
            // Twitter
            NSURL* twitterURL = [ NSURL URLWithString: @"https://twitter.com/PasswordSync" ];
            NSURL* twitterAppURL = [ NSURL URLWithString: @"twitter://user?screen_name=passwordSync" ];
            if( [ app canOpenURL: twitterAppURL ] ) {
                [ app openURL: twitterAppURL ];
            } else {
                [ app openURL: twitterURL ];
            }
            
        }
        
        
        
    } else if (indexPath.section == 2 && indexPath.row == 1) {
        // Import from Password Sync 1
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            [(UIPopoverController*)[(UINavigationController*)self.parentViewController parentViewController] dismissPopoverAnimated:NO];
            
        }
        [(UITabBarController*)APP_DELEGATE.window.rootViewController setSelectedIndex:0];
        
        PSSPasswordSyncOneDataImporter * dataImporter = [[PSSPasswordSyncOneDataImporter alloc] init];
        [dataImporter beginImportProcedure:self];
        
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

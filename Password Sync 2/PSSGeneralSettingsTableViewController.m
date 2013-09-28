//
//  PSSSettingsTableViewController.m
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-08-14.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import "PSSGeneralSettingsTableViewController.h"
#import "PSSPasswordSyncOneDataImporter.h"
#import "PSSAppDelegate.h"
#import "Appirater.h"
#import "PSSUnlockPromptViewController.h"

@interface PSSGeneralSettingsTableViewController ()

@end

@implementation PSSGeneralSettingsTableViewController



-(void)presentPasscodeSettingsViewAction:(id)sender{
    
    UIStoryboard * unlockStoryboard = [UIStoryboard storyboardWithName:@"UnlockPrompt" bundle:[NSBundle mainBundle]];
    PSSUnlockPromptViewController * unlockController = (PSSUnlockPromptViewController*)[unlockStoryboard instantiateInitialViewController];
    
    [self.navigationController presentViewController:[unlockController promptForPasscodeBlockingView:NO completion:^{
        // We only run the refresh if the UI was locked to prevent double reloads
        
        [self performSegueWithIdentifier:@"showPasscodeSettingsSegue" sender:self];
        
        
    } cancelation:^{
        
    }] animated:YES completion:^{
        
    }];
    
    
    
}


-(void)presentMasterPasswordSettings:(id)sender{
    
    UIStoryboard * unlockStoryboard = [UIStoryboard storyboardWithName:@"UnlockPrompt" bundle:[NSBundle mainBundle]];
    PSSUnlockPromptViewController * unlockController = (PSSUnlockPromptViewController*)[unlockStoryboard instantiateInitialViewController];
    
    [self.navigationController presentViewController:[unlockController promptForMasterPasswordBlockingView:NO completion:^{
        // We only run the refresh if the UI was locked to prevent double reloads
        
        [self performSegueWithIdentifier:@"showMasterPasswordSettingsSegue" sender:self];
        
        
    } cancelation:^{
        
        
        
    }] animated:YES completion:^{
        
        
        
    }];
    
    
}

-(UIView*)lockedImageAccessoryView{
    
    UIImage * lockImage = [UIImage imageNamed:@"SmallLock"];
    
    UIImageView * accessoryView = [[UIImageView alloc] initWithImage:[lockImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    return accessoryView;
}

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
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        self.navigationController.tabBarItem.selectedImage = [UIImage imageNamed:@"Gear-selected"];
    } else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.navigationController.tabBarItem.selectedImage = [UIImage imageNamed:@"Gear-selected"];
    }
    
  
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"normalCell"];
    
    self.title = NSLocalizedString(@"Settings", nil);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 44.;
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return NSLocalizedString(@"Locked", nil);
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
        // Locked preferences
        return 2;
    } else if (section == 1) {
        return 3;
    } else if (section==2) {
        // legal (and import from Password Sync One
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"passsyncjsonexport://passsynctwoupgrade?enckey=ABCD"]])
            return 4;
        
        return 3;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellIdentifier = @"normalCell";
    if (indexPath.section==0) {
        
        if (indexPath.row == 0) {
            // Passcode
            
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
            
            cell.textLabel.text = NSLocalizedString(@"Passcode", nil);
            cell.accessoryView = [self lockedImageAccessoryView];
            
            return cell;
            
        } else if (indexPath.row== 1) {
            
            // Master Password
            
            
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
            
            cell.textLabel.text = NSLocalizedString(@"Master Password", nil);
            cell.accessoryView = [self lockedImageAccessoryView];
            
            return cell;
            
        }
        
        
    } else if (indexPath.section == 1) {
        
        
        if (indexPath.row == 0) {
            // Facebook
            
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
            
            cell.textLabel.text = @"Like™";
            cell.accessoryView = nil;
            cell.imageView.image = [UIImage imageNamed:@"Facebook"];
            return cell;
            
        } else if (indexPath.row== 1) {
            
            // Pinterest
            
            
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
            
            cell.textLabel.text = @"Pin It™";
            cell.accessoryView = nil;
            cell.imageView.image = [UIImage imageNamed:@"Pinterest"];
            return cell;
            
        } else if (indexPath.row == 2) {
            
            // Twitter
            
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
            
            cell.textLabel.text = @"@PasswordSync";
            cell.accessoryView = nil;
            cell.imageView.image = [UIImage imageNamed:@"Twitter"];
            return cell;
            
        }
        
        
        
        
        
    } else if (indexPath.section==2){
        
        
        // Legal and import
        
        if (indexPath.row == 0) {
            
            static NSString *CellIdentifier = @"submenuCell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
            
            cell.textLabel.text = NSLocalizedString(@"Legal", nil);
            cell.accessoryView = nil;
            cell.imageView.image = [[UIImage imageNamed:@"Mug"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            return cell;
            
        } else if (indexPath.row == 1) {
            // Submit a review
            static NSString * cellIdentifier = @"normalCell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
            
            cell.textLabel.text = NSLocalizedString(@"Review Password Sync", nil);
            cell.accessoryView = nil;
            cell.imageView.image = [[UIImage imageNamed:@"Love-Icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            return cell;
            
            
        } else if (indexPath.row == 2) {
            // Report a problem
            static NSString * cellIdentifier = @"normalCell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
            
            cell.textLabel.text = NSLocalizedString(@"Report a problem", nil);
            cell.accessoryView = nil;
            cell.imageView.image = [[UIImage imageNamed:@"Problem-Icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            return cell;
            
            
        } else if (indexPath.row == 3) {
            // Import from Password Sync 1
            
            static NSString * cellIdentifier = @"normalCell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
            
            cell.textLabel.text = NSLocalizedString(@"Import from Password Sync 1", nil);
            cell.accessoryView = nil;
            cell.imageView.image = [UIImage imageNamed:@"PasswordSyncOne"];
            return cell;
            
            
        }
    }
    
    return nil;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 0) {
        
        if (indexPath.row == 0) {
            // Passcode
            
            [self presentPasscodeSettingsViewAction:nil];
            
        } else if (indexPath.row == 1) {
            
            // Master Password
            [self presentMasterPasswordSettings:nil];
            
        }
        
    } else if (indexPath.section == 1) {
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
        
        
        
    } else if (indexPath.section == 2 && indexPath.row == 0) {
        
        [self performSegueWithIdentifier:@"presentLegalViewSegue" sender:self];
        
    } else if (indexPath.section == 2 && indexPath.row == 1) {
        // Review the app
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            [(UIPopoverController*)[(UINavigationController*)self.parentViewController parentViewController] dismissPopoverAnimated:NO];
            
        }
        
        [Appirater rateApp];
        
        
    } else if (indexPath.section == 2 && indexPath.row == 2) {
        // Report a problem
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            [(UIPopoverController*)[(UINavigationController*)self.parentViewController parentViewController] dismissPopoverAnimated:NO];
            
        }
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://passwordsync.freshdesk.com/support/tickets/new"]];
        
        
    } else if (indexPath.section == 2 && indexPath.row == 3) {
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




@end

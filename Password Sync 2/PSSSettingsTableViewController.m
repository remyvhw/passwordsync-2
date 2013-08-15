//
//  PSSSettingsTableViewController.m
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-08-14.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import "PSSSettingsTableViewController.h"

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return NSLocalizedString(@"Passcode", nil);
    }
    return @"";
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
        // Passcode
        return 2;
    } else if (section==1) {
        // legal
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
        
    } else if (indexPath.section==1){
        
        static NSString *CellIdentifier = @"submenuCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        
        cell.textLabel.text = NSLocalizedString(@"Legal", nil);
        
        return cell;
    }
    
    return nil;
    
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */


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

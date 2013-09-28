//
//  PSSMasterPasswordSettingsViewController.m
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-09-26.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import "PSSMasterPasswordSettingsViewController.h"
#import "PSSnewPasswordPasswordTextFieldCell.h"
#import "PSSnewPasswordBasicTextFieldCell.h"
#import "SVProgressHUD.h"

@interface PSSMasterPasswordSettingsViewController ()

@property (nonatomic, strong) PSSnewPasswordPasswordTextFieldCell * passwordCell;
@property (nonatomic, strong) PSSnewPasswordBasicTextFieldCell * hintCell;
@property (nonatomic, strong) UIPopoverController * generatorPopover;

@end

@implementation PSSMasterPasswordSettingsViewController

-(void)rencryptDataWithPassword:(NSString*)newMasterPassword{
    
    
    [SVProgressHUD show];
    
    
}

-(void)promptForPasswordConfirmation{
    
    UIAlertView * promptAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Confirm your master password", nil) message:NSLocalizedString(@"Please re-enter your master password.", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:NSLocalizedString(@"Confirm", nil), nil];
    
    
    [promptAlertView setAlertViewStyle:UIAlertViewStyleSecureTextInput];
    
    [promptAlertView show];
    
}

-(void)showPasswordGenerator:(id)sender{
    
    PSSPasswordGeneratorTableViewController * passwordGenerator = [[PSSPasswordGeneratorTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    passwordGenerator.generatorDelegate = self;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        
        if (self.generatorPopover) {
            [self.generatorPopover dismissPopoverAnimated:YES];
            self.generatorPopover = nil;
            return;
        }
        
        
        UINavigationController * navController = [[UINavigationController alloc] initWithRootViewController:passwordGenerator];
        
        UIPopoverController * popover = [[UIPopoverController alloc] initWithContentViewController:navController];
        self.generatorPopover = popover;
        
        
        [popover presentPopoverFromRect:self.passwordCell.shuffleButton.frame inView:self.passwordCell permittedArrowDirections:UIPopoverArrowDirectionRight animated:YES];
        
    } else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        
        [self.navigationController pushViewController:passwordGenerator animated:YES];
    }
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated{
    [[UIDevice currentDevice] setBatteryMonitoringEnabled:YES];
}

-(void)viewWillDisappear:(BOOL)animated{
    [[UIDevice currentDevice] setBatteryMonitoringEnabled:NO];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.title = NSLocalizedString(@"Master Password", nil);
    }
    
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"normalCell"];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

-(NSString*)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section{
    if (section==0) {
        return NSLocalizedString(@"Changing master password is a lengthy process that can take a few minutes. Plug your device into power and do not interrupt the operation.", nil);
    }
    return @"";
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section==0) {
        return NSLocalizedString(@"Change Master Password", nil);
    }
    return @"";
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 44.;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section==0) {
        // Password and hint
        return 3;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        
        
        if (indexPath.row == 0) {
            // Change Master Password
            
                        
            if (!self.passwordCell) {
                PSSnewPasswordPasswordTextFieldCell * passwordCell = [[PSSnewPasswordPasswordTextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
                
                self.passwordCell = passwordCell;
                
                self.passwordCell.textField.placeholder = NSLocalizedString(@"New Master Password", nil);
                self.passwordCell.selectionStyle = UITableViewCellSelectionStyleNone;
                [self.passwordCell.shuffleButton addTarget:self action:@selector(showPasswordGenerator:) forControlEvents:UIControlEventTouchUpInside];
                self.passwordCell.nextFormField = self.hintCell.textField;
            }
            
            return self.passwordCell;
        } else if (indexPath.row == 1) {
            if (!self.hintCell) {
                
                PSSnewPasswordBasicTextFieldCell * hintCell = [[PSSnewPasswordBasicTextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
                self.hintCell = hintCell;
               
                self.hintCell.textField.placeholder = NSLocalizedString(@"Password Hint or Reminder", nil);
                self.hintCell.selectionStyle = UITableViewCellSelectionStyleNone;
                
            }
            return self.hintCell;
        } else if (indexPath.row == 2) {
            
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"normalCell" forIndexPath:indexPath];
            
            cell.textLabel.text = NSLocalizedString(@"Change Password", nil);
            cell.textLabel.textColor = self.view.window.tintColor;
            
            return cell;
            
            
        }
        
        
    }
    
    return nil;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 0 && indexPath.row == 2) {
        
        // Check if device is unplugged/battery level low.
        
        NSLog(@"%f", [[UIDevice currentDevice] batteryLevel]);
        
        if ([[UIDevice currentDevice] batteryLevel] < 1.0 && [[UIDevice currentDevice] batteryState] == UIDeviceBatteryStateUnplugged) {
            UIAlertView * batteryAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Low Battery Alert", nil) message:NSLocalizedString(@"Please connect to AC power before continuing master password change.", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
            
            [batteryAlert show];
        } else {
            
            [self promptForPasswordConfirmation];
            
        }
        
        
    }
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - PSSPasswordGeneratorTableViewControllerProtocol methods
-(void)passwordGenerator:(PSSPasswordGeneratorTableViewController *)generator finishedWithPassword:(NSString *)randomPassword{
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [self.generatorPopover dismissPopoverAnimated:YES];
        self.generatorPopover = nil;
    }
    
    [self.passwordCell setUnsecureTextPassword:randomPassword];
}

#pragma mark - UIAlertViewDelegate methods

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex == 0) {
        [self.passwordCell.textField becomeFirstResponder];
    } else {
        
        // Check if master password is the same in both fields
        if ([[[alertView textFieldAtIndex:0] text] isEqualToString:self.passwordCell.textField.text]) {
            //[self saveMasterPassword:self.passwordCell.textField.text hint:self.passwordHintTextField.text];
            
            
            // If user already printer it's master Password, jump to the passcode chooser
            
            
            [self rencryptDataWithPassword:[[alertView textFieldAtIndex:0] text]];
            
            
            
        } else {
            
            UIAlertView * errorAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Cannot Verify Master Password", nil) message:NSLocalizedString(@"Make sure you wrote your master password exactly the same way in the two fields.", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
            [errorAlertView show];
            
        }
        
        
        
    }
    
    
}



@end

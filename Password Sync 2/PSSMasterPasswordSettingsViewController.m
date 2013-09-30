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
#import "PSSAppDelegate.h"
#import "PSSMasterPasswordVerifyerViewController.h"
#import "PSSBaseGenericObject.h"

@interface PSSMasterPasswordSettingsViewController ()

@property (nonatomic, strong) PSSnewPasswordPasswordTextFieldCell * passwordCell;
@property (nonatomic, strong) PSSnewPasswordBasicTextFieldCell * hintCell;
@property (nonatomic, strong) UIPopoverController * generatorPopover;

@end

@implementation PSSMasterPasswordSettingsViewController

/* Save notification handler for the background context */
- (void)backgroundContextDidSave:(NSNotification *)notification {
    /* Make sure we're on the main thread when updating the main context */
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(backgroundContextDidSave:)
                               withObject:notification
                            waitUntilDone:NO];
        return;
    }
    
    /* Merge in the changes to the main context */
    [APP_DELEGATE.managedObjectContext mergeChangesFromContextDidSaveNotification:notification];
}

-(void)lockUIAction:(id)notification{
    [self.navigationController popToRootViewControllerAnimated:NO];
}


-(void)manuallySetMasterPassword:(NSString*)newMasterPassword{
    
    PSSMasterPasswordVerifyerViewController * masterPasswordController = [[PSSMasterPasswordVerifyerViewController alloc] init];
    
    [masterPasswordController manuallySetMasterPasswordWithNoSync:newMasterPassword];
    
    
    [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Success", nil)];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(void)rencryptDataWithPassword:(NSString*)newMasterPassword{
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];

    dispatch_queue_t main_queue = dispatch_get_main_queue();
    dispatch_queue_t request_queue = dispatch_queue_create("com.pumaxprod.iOS.Password-Sync-2.masterPasswordChangeReencodingThread", NULL);

    __block __typeof__(self) blockSelf = self;
    
    dispatch_async(request_queue, ^{
        
        
        // Generate a new password hash.
        PSSMasterPasswordVerifyerViewController * masterPasswordVerifyer = [[PSSMasterPasswordVerifyerViewController alloc] init];
        
        NSString * hashedMasterPassword = [masterPasswordVerifyer generateMasterPasswordHash:newMasterPassword hint:self.hintCell.textField.text];
        
        
        NSFetchRequest * allBaseObjectsRequest = [[NSFetchRequest alloc] initWithEntityName:@"PSSBaseGenericObject"];
        
        allBaseObjectsRequest.sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey:@"displayName" ascending:YES]];
        
        NSManagedObjectContext * threadSafeContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        
        [threadSafeContext setPersistentStoreCoordinator:APP_DELEGATE.persistentStoreCoordinator];
        
        NSArray * allBaseObjects = [threadSafeContext executeFetchRequest:allBaseObjectsRequest error:NULL];

        
        for (PSSBaseGenericObject *baseObject in allBaseObjects) {
            
            [baseObject reencryptAllDependantObjectsUsingPassword:hashedMasterPassword];
            
        }
        
        
        // Subscribe to the save notification so our main object context (in the App_delegate) is notified and run a merge.
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(backgroundContextDidSave:)
                                                     name:NSManagedObjectContextDidSaveNotification
                                                   object:threadSafeContext];
        
        __block NSError * saveError;
        
        [threadSafeContext performBlockAndWait:^{
            [threadSafeContext save:&saveError];
        }];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:NSManagedObjectContextDidSaveNotification
                                                      object:threadSafeContext];
        
        if (saveError) {
            
            // Cancel everything and inform the user
            
            [threadSafeContext rollback];
            
            dispatch_sync(main_queue, ^{
                
                [SVProgressHUD dismiss];
                [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
                
                UIAlertView * errorAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"An Error Occured", nil) message:[saveError localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
                [errorAlert show];
                
            });
            
            
        } else {
            
            // Perform the official master password change
            
            [masterPasswordVerifyer saveNewMasterPassword:blockSelf.passwordCell.textField.text hint:blockSelf.hintCell.textField.text];
            
            
            dispatch_sync(main_queue, ^{
                
                [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
                
                [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Success", nil)];
                [blockSelf.navigationController popToRootViewControllerAnimated:YES];
                
            });
            
        }
        
        
        
    });
    
    
}

-(void)promptForPasswordConfirmation{
    
    UIAlertView * promptAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Confirm your master password", nil) message:NSLocalizedString(@"Please re-enter your master password.", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:NSLocalizedString(@"Confirm", nil), nil];
    
    
    [promptAlertView setAlertViewStyle:UIAlertViewStyleSecureTextInput];
    [promptAlertView setTag:100];
    [promptAlertView show];
    
}


-(void)promptForManualMasterPassword{
    UIAlertView * promptAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Manually set your master password", nil) message:NSLocalizedString(@"Manually setting the master password let you change the master password used by the app on this device without rencrypting the entire database or notifying installations running on other devices. Setting the master password manually could be necessary if, after a master password change on another device, you cannot decrypt your passwords on this one.", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:NSLocalizedString(@"Confirm", nil), nil];
    
    
    [promptAlertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [promptAlertView setTag:101];
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

-(NSString*)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section{
    if (section==0) {
        return NSLocalizedString(@"Changing master password is a lengthy process that can take a few minutes. Plug your device into power and do not interrupt the operation. It is highly recommanded you wait a couple of minutes and restart Password Sync 2 on all your other devices after this operation.", nil);
    }
    return @"";
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section==0) {
        return NSLocalizedString(@"Change Master Password", nil);
    } else if (section==1) {
        return NSLocalizedString(@"Advanced", nil);
    }
    return @"";
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
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
        // Password and hint
        return 3;
    } else if (section == 1) {
        // Advanced
        return 1;
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
        
        
    } else if (indexPath.section==1) {
        // Advanced
        
        if (indexPath.row == 0) {
            // Manually set master password
            
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"normalCell" forIndexPath:indexPath];
            
            cell.textLabel.text = NSLocalizedString(@"Manually set master password", nil);
            cell.textLabel.textColor = self.view.window.tintColor;
            
            return cell;
            
        }
        
    }
    
    return nil;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 0 && indexPath.row == 2) {
        
        // Check if device is unplugged/battery level low.
        
        [self.hintCell.textField resignFirstResponder];
        [self.passwordCell.textField resignFirstResponder];
        
        if ([[UIDevice currentDevice] batteryLevel] < 0.4 && [[UIDevice currentDevice] batteryState] == UIDeviceBatteryStateUnplugged) {
            UIAlertView * batteryAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Low Battery Alert", nil) message:NSLocalizedString(@"Please connect to AC power before continuing master password change.", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
            
            [batteryAlert show];
        } else {
            
            [self promptForPasswordConfirmation];
        }
        
    } else if (indexPath.section==1 && indexPath.row == 0) {
        // Manually set master password
        [self promptForManualMasterPassword];
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
    
    if (alertView.tag == 100) {
        // Confirm master password alert view
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
    } else if (alertView.tag == 101) {
        // Manually set master password
        
        if (buttonIndex != 0) {
            // Confirm button
            
            [self manuallySetMasterPassword:[[alertView textFieldAtIndex:0] text]];
            
        }
        
    }// End of alertview.tag == 101

    
}



@end

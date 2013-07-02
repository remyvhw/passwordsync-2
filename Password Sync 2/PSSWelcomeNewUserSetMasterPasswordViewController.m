//
//  PSSWelcomeNewUserSetMasterPasswordViewController.m
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-06-29.
//  Copyright (c) 2013 Pumax. All rights reserved.
//


#import "PSSWelcomeNewUserSetMasterPasswordViewController.h"
#import "PSSMasterPasswordVerifyerViewController.h"

@interface PSSWelcomeNewUserSetMasterPasswordViewController ()

@end

@implementation PSSWelcomeNewUserSetMasterPasswordViewController

-(void)storyboardJumpToPrinterController{
    
    [self performSegueWithIdentifier:@"newUserFinishedSettingMasterPasswordPushPrintViewControllerSegue" sender:self];
    
}

-(void)storyboardJumpToPasscodeChooserController{
    
    [self performSegueWithIdentifier:@"newUserFinishedSettingMasterPasswordPushPrintViewControllerSegue" sender:self];
    
    
}

-(void)saveMasterPassword:(NSString*)masterPassword hint:(NSString*)hint{
    
    PSSMasterPasswordVerifyerViewController * masterPasswordVerifyer = [[PSSMasterPasswordVerifyerViewController alloc] init];
    
    [masterPasswordVerifyer saveMasterPassword:masterPassword hint:hint];
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self.masterPasswordTextField becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)saveButtonAction:(id)sender {
    
    
    UIAlertView * promptAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Confirm your master password", nil) message:NSLocalizedString(@"Please re-enter your master password.", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:NSLocalizedString(@"Confirm", nil), nil];
    
    
    [promptAlertView setAlertViewStyle:UIAlertViewStyleSecureTextInput];
    
    [promptAlertView show];
    
}

#pragma mark - UIAlerViewDelegate methods

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex == 0) {
        [self.masterPasswordTextField becomeFirstResponder];
    } else {
        
        // Check if master password is the same in both fields
        if ([[[alertView textFieldAtIndex:0] text] isEqualToString:self.masterPasswordTextField.text]) {
            [self saveMasterPassword:self.masterPasswordTextField.text hint:self.passwordHintTextField.text];
            
            
            // If user already printer it's master Password, jump to the passcode chooser
            
            if ([UIPrintInteractionController isPrintingAvailable]) {
                [self storyboardJumpToPrinterController];
            } else {
                [self storyboardJumpToPasscodeChooserController];
            }
            
            
            
            
        } else {
            
            UIAlertView * errorAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Cannot Verify Master Password", nil) message:NSLocalizedString(@"Make sure you wrote your master password exactly the same way in the two fields.", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
            [errorAlertView show];
            
        }
        
        
        
    }
    
    
}

@end

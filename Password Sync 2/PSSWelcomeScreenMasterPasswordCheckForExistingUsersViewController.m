//
//  PSSWelcomeScreenMasterPasswordCheckForExistingUsersViewController.m
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-07-01.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import "PSSWelcomeScreenMasterPasswordCheckForExistingUsersViewController.h"
#import "PSSMasterPasswordVerifyerViewController.h"
#import <AudioToolbox/AudioToolbox.h>

@interface PSSWelcomeScreenMasterPasswordCheckForExistingUsersViewController ()
@property (weak, nonatomic) IBOutlet UITextField *masterPasswordTextField;
@property (weak, nonatomic) IBOutlet UIButton *continueButton;
@property (weak, nonatomic) IBOutlet UILabel *hintTextField;
@property (weak, nonatomic) IBOutlet UILabel *hintCaption;

- (IBAction)continueAction:(id)sender;


@end

@implementation PSSWelcomeScreenMasterPasswordCheckForExistingUsersViewController

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

- (IBAction)continueAction:(id)sender {
    
    NSString * typedPassword = self.masterPasswordTextField.text;
    
    PSSMasterPasswordVerifyerViewController * passwordVerifyer = [[PSSMasterPasswordVerifyerViewController alloc] init];
    
    BOOL passwordIsValid = [passwordVerifyer verifyMasterPasswordValidity:typedPassword];
    
    if (passwordIsValid) {
        [self navigateToAppropriateViewController];
    } else {
        // Password is invalid
        AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
        
        UIAlertView * invalidPasswordAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Password is Incorrect", nil) message:NSLocalizedString(@"Cannot Verify Master Password", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
        
        [invalidPasswordAlert show];
        
        
        
        self.masterPasswordTextField.text = @"";
        [self.masterPasswordTextField resignFirstResponder];
        
        

        
    }
    
}

-(void)navigateToAppropriateViewController{
    // Should we prompt the user to print her master password? Will depends on two factors: available printer and if the user printed it already/asked never to print it.
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:PSSUserAlreadyPrintedMasterPassword]) {
        // User already printed/opted out. Just redirect immediatly to the passcode window
        
        [self performSegueWithIdentifier:@"existingUserFinishedSettingMasterPasswordNoPrintNecessarySegue" sender:self];
        return;
    }
    
    if (![UIPrintInteractionController isPrintingAvailable]) {
        // Cannot print from this device. Just go to passcode
        [self performSegueWithIdentifier:@"existingUserFinishedSettingMasterPasswordNoPrintNecessarySegue" sender:self];
        return;
    }
    
    [self performSegueWithIdentifier:@"existingUserFinishedSettingMasterPasswordPushPrintViewControllerSegue" sender:self];
    
}


#pragma mark - UIAlerViewDelegate methods

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    
    // We implement didDismiss so we can animate the hint AFTER the alert has disapeared so the user can notice the animation and the apparition of the hint.
    
    
    
    if ([self.hintTextField isHidden]) {
        [self.hintTextField setAlpha:0.0];
        [self.hintTextField setHidden:NO];
        self.hintTextField.text = [[NSUserDefaults standardUserDefaults] stringForKey:PSSMasterPasswordHintTextString];
        [self.hintTextField sizeToFit];
        [self.hintCaption setAlpha:0.0];
        [self.hintCaption setHidden:NO];
        [UIView animateWithDuration:0.2 animations:^{
            [self.hintTextField setAlpha:1.0];
            [self.hintCaption setAlpha:1.0];
            
        }];
    }
}

@end

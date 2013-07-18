//
//  PSSMasterPasswordPromptViewController.m
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-07-16.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import "PSSMasterPasswordPromptViewController.h"
#import "PSSPasscodeVerifyerViewController.h"
#import "PSSMasterPasswordVerifyerViewController.h"
#import "PSSUnlockPromptViewController.h"

@interface PSSMasterPasswordPromptViewController ()
@property (weak, nonatomic) IBOutlet UITextField *masterPasswordField;
@property (weak, nonatomic) IBOutlet UILabel *masterPasswordPromptText;
@property (weak, nonatomic) IBOutlet UILabel *detailsTextField;
@property (weak, nonatomic) IBOutlet UILabel *counterField;
@property (weak, nonatomic) IBOutlet UIButton *dismissKeyboardButton;
- (IBAction)dismissKeyboardAction:(id)sender;

@end

@implementation PSSMasterPasswordPromptViewController

-(void)userProvidedWrongPassword{
    
    // Block the view for 5 seconds
    
    UIColor * originalTextColor = self.detailsTextField.textColor;
    UIColor * replacementColor = [UIColor colorWithRed: 143./255. green: 45./255. blue: 50./255. alpha: 1];
    
    [self.masterPasswordField resignFirstResponder];
    [self.masterPasswordField setEnabled:NO];
    [self.navigationItem.rightBarButtonItem setEnabled:NO];
    self.counterField.text = NSLocalizedString(@"Please wait 5 seconds before trying again.", nil);
    [UIView animateWithDuration:0.5 animations:^{
        self.detailsTextField.textColor = replacementColor;
        self.detailsTextField.text = NSLocalizedString(@"Password is Incorrect.", nil);
        [self.counterField setAlpha:1.0];
    }];
    
    int64_t delayInSeconds = 5; // Your Game Interval as mentioned above by you
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        // Update your label here.
        [self.masterPasswordField setEnabled:YES];
        [self.navigationItem.rightBarButtonItem setEnabled:YES];
        [self.masterPasswordField becomeFirstResponder];
        [UIView animateWithDuration:0.5 animations:^{
            [self.counterField setAlpha:0.0];
            self.detailsTextField.textColor = originalTextColor;
            self.detailsTextField.text = NSLocalizedString(@"Enter your Master Password", nil);
        }];
        
        
    });
    
    
    
}


-(void)userProvidedCorrectPassword{
    
    PSSUnlockPromptViewController* unlockController = (PSSUnlockPromptViewController*)self.navigationController;
    
    [unlockController userDidSuccesfullyUnlockedWithMasterPassword];
    

    
}

-(IBAction)doneAction:(id)sender{
    
    PSSMasterPasswordVerifyerViewController*masterPasswordVerifyer = [[PSSMasterPasswordVerifyerViewController alloc] init];
    
    NSString * providedMasterPassword = self.masterPasswordField.text;
    BOOL providedPasswordIsCorrect = [masterPasswordVerifyer verifyMasterPasswordValidity:providedMasterPassword];
    
    if (providedPasswordIsCorrect) {
        [self userProvidedCorrectPassword];
    } else {
        [self userProvidedWrongPassword];
    }
    
    
}

-(IBAction)cancelAction:(id)sender{
    
    PSSUnlockPromptViewController* unlockController = (PSSUnlockPromptViewController*)self.navigationController;
    
    
    [unlockController userDidCancelUnlockWithMasterPassword];
    
}

- (IBAction)dismissKeyboardAction:(id)sender {
    [self.masterPasswordField resignFirstResponder];
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
    
    // Always hide the back button if any
    self.navigationItem.leftBarButtonItem = nil;
    
    UIBarButtonItem * doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneAction:)];
    
    self.navigationItem.rightBarButtonItem = doneButton;
    
    if (!self.blockingView) {
        UIBarButtonItem * cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelAction:)];
        
        self.navigationItem.leftBarButtonItem = cancelButton;
        
    }
    
    PSSPasscodeVerifyerViewController * passcodeVerifyer = [[PSSPasscodeVerifyerViewController alloc] init];
    
    if (passcodeVerifyer.countOfPasscodeAttempts >= 5) {
        // Passcode is locked. Inform the user she will have to enter her master password
        
        self.detailsTextField.text = NSLocalizedString(@"Your passcode has been locked. Please enter your master password to reset your passcode and unlock your Password Sync Database.", nil);
        
    } else {
        self.detailsTextField.text = @"";
        [self.detailsTextField setHidden:YES];
        [self.masterPasswordField becomeFirstResponder];
    }
    
    
    self.counterField.text = @"";
    
    
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

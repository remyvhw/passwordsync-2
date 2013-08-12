//
//  PSSWelcomeScreenMasterPasswordExplanationViewController.m
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-06-29.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import "PSSWelcomeScreenMasterPasswordExplanationViewController.h"
#import "PDKeychainBindings.h"
#import "UIImage+ImageEffects.h"

@interface PSSWelcomeScreenMasterPasswordExplanationViewController ()
@property (weak, nonatomic) IBOutlet UILabel *masterPasswordTitleLabel;
@property (weak, nonatomic) IBOutlet UITextView *masterPasswordExplanationTextView;
@property (weak, nonatomic) IBOutlet UIButton *continueAsNewUserButton;
@property (weak, nonatomic) IBOutlet UIButton *continueAsExistingUserButton;
@property (weak, nonatomic) IBOutlet UILabel *masterPasswordExplanationTextLabel;

@end

@implementation PSSWelcomeScreenMasterPasswordExplanationViewController

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

    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
    

    
    // Configure the explanation text depending of if user first launched the app or not
    
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    
    PDKeychainBindings * keychainBindings = [PDKeychainBindings sharedKeychainBindings];
    NSString * hashedMasterPassword = [keychainBindings stringForKey:PSSHashedMasterPasswordKeychainEntry];
    
    NSString * explanationText;
    
    if ([userDefaults boolForKey:PSSApplicationWasConfiguredOnAnotherDeviceDefaults] || hashedMasterPassword) {
        // Not a first launch, just explain how the master password must stay the same.
        
        explanationText = NSLocalizedString(@"As you know, your master password is the ultimate key that encodes your Password Sync database. It must be the same on this device as it is on all your other devices running Password Sync 2. That includes your other iOS devices or Mac computers. On the following screen, you'll have to enter your master password exactly the same way as you typed it on your other devices. If you can't remember it, we'll help you with a hint you provided us when you created your master password.", @"First master password explanation screen for existing users.");
        
    } else {
        // First launch, explain why is there a need for a master password.
        
        explanationText = NSLocalizedString(@"A master password is the key that will encode your Password Sync database and is the same for all other devices that have the Password Sync App installed. \nChoose your password carefully: once set, it is absolutely impossible to unlock your passwords without it. If the master password is lost or you find yourself unable to recall it, then you will be unable to retrieve any of your stored passwords.  There is no password retrieval link, nor is there anyone to help you reset it. It is also important to remember that the security level of your data will be proportional to the strength of your password.", @"First master password explanation screen for first launch.");

        
    }
    
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.masterPasswordExplanationTextLabel.text = explanationText;
    } else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
        self.masterPasswordExplanationTextView.text = explanationText;
    }
    
    [self.masterPasswordExplanationTextView setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleBody]];
    [self.masterPasswordExplanationTextView setTextAlignment:NSTextAlignmentCenter];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)continueButtonWasPressed:(id)sender {
    
    PDKeychainBindings * keychainBindings = [PDKeychainBindings sharedKeychainBindings];
    NSString * hashedMasterPassword = [keychainBindings stringForKey:PSSHashedMasterPasswordKeychainEntry];
    
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults boolForKey:PSSApplicationWasConfiguredOnAnotherDeviceDefaults] || hashedMasterPassword) {
        [self performSegueWithIdentifier:@"masterPasswordForExistingUserSegue" sender:sender];
    } else {
        [self performSegueWithIdentifier:@"masterPasswordForNewUserSegue" sender:sender];
    }
    
    
    
    
}
@end

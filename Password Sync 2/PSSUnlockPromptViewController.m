//
//  PSSUnlockPromptViewController.m
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-07-15.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import "PSSUnlockPromptViewController.h"
#import "PDKeychainBindings.h"
#import "PSSWelcomeScreenGesturePasscodeSetterViewController.h"
#import "PSSWelcomeScreenPINPasscodeSetterViewController.h"
#import "PSSMasterPasswordPromptViewController.h"
#import "PSSWelcomeScreenPasscodeModeChooserTableViewController.h"
#import "PSSAppDelegate.h"

@interface PSSUnlockPromptViewController ()

@property BOOL masterPasswordChecker;

@end

@implementation PSSUnlockPromptViewController

-(void)sendUserUnlockedNotification{
    NSNotificationCenter * defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter postNotificationName:PSSGlobalUnlockNotification object:self];
}

-(void)userDidCancelUnlockWithMasterPassword{
    
    if (self.cancelationBlock) {
        self.cancelationBlock();
    }
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
    
}

-(PSSUnlockPromptViewController*)promptForMasterPasswordBlockingView:(BOOL)blockingView completion:(void (^)(void))completion cancelation:(void (^)(void))cancelation{
    // Incomplete implementation;
    return self;
}

-(PSSUnlockPromptViewController*)promptForPasscodeBlockingView:(BOOL)blockingView completion:(void (^)(void))completion cancelation:(void (^)(void))cancelation{
    
    self.cancelationBlock = cancelation;
    self.unlockBlock = completion;
    
    NSNumberFormatter * numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    
    
    PSSPasscodeVerifyerViewController * passcodeVeryfier = [[PSSPasscodeVerifyerViewController alloc] init];
    if (passcodeVeryfier.countOfPasscodeAttempts >= 5) {
        
        [self presentMasterPasswordPromptControllerAnimated:NO];
        
    } else {
        PSSPasscodeType passcodeType = [[numberFormatter numberFromString:[[PDKeychainBindings sharedKeychainBindings] stringForKey:PSSDefinedPasscodeType]] intValue];
        [[PDKeychainBindings sharedKeychainBindings] setString:[@(passcodeType) stringValue] forKey:PSSDefinedPasscodeType];
        switch (passcodeType) {
            case PSSPasscodeTypeGestureBased:
                // Launch the gesture based interface
                self.viewControllers = @[[self instanciateGestureViewController]];
                break;
            case PSSPasscodeTypeNIPcode:
                // Use the gesture based interface
                self.viewControllers = @[[self instanciatePINViewController]];
                break;
            default:
                break;
        }
    }

    return self;
    
    
    
}


-(void)userDidSuccesfullyUnlockedWithMasterPassword{
    
    // Check if the passcode has been locked. If so, redirect our user to the UIStoryboard that let her reset her passcode.
    
    
    PSSPasscodeVerifyerViewController * passcodeVerifyer = [[PSSPasscodeVerifyerViewController alloc] init];
    
    if ([passcodeVerifyer countOfPasscodeAttempts] >= 5) {
        // User has been locked out, present the passcode setter view controller.
        
        
        UIStoryboard * welcomeStoryboard = [UIStoryboard storyboardWithName:@"FirstLaunchStoryboard_iPhone" bundle:[NSBundle mainBundle]];
        
        PSSWelcomeScreenPasscodeModeChooserTableViewController * passcodeChooserController = [welcomeStoryboard instantiateViewControllerWithIdentifier:@"passcodeChooserTypeSelectorViewController"];

        [self pushViewController:passcodeChooserController animated:YES];
        // prevent the back button from appearing
        self.viewControllers = @[passcodeChooserController];
        
        
    } else {
        if (self.masterPasswordChecker) {
            // Execute the completion block for the master password
            if (self.masterPasswordUnlockBlock) {
                self.masterPasswordUnlockBlock();
            }
        } else {
            // User successfully unlocked the passcode
            if (self.unlockBlock) {
                self.unlockBlock();
            }
        }

        [self sendUserUnlockedNotification];
        
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    }
    
    
    
    
}


-(void)userDidSuccessfullyUnlockWithPasscode{
    
    
    if (self.unlockBlock) {
        self.unlockBlock();
    }
    [self sendUserUnlockedNotification];
    
    [self dismissViewControllerAnimated:YES completion:^{
        
        
        
        
    }];
}

-(PSSWelcomeScreenGesturePasscodeSetterViewController*)instanciateGestureViewController{
    
    PSSWelcomeScreenGesturePasscodeSetterViewController * gestureController = [self.storyboard instantiateViewControllerWithIdentifier:@"gesturePatternViewController"];
    gestureController.promptMode = YES;
    return gestureController;
}

-(void)presentMasterPasswordPromptControllerAnimated:(BOOL)animated{
    
    
    PSSMasterPasswordPromptViewController * passwordPrompt = [self.storyboard instantiateViewControllerWithIdentifier:@"masterPasswordPrompt"];
    
    [passwordPrompt setBlockingView:YES];
    
    if (animated) {
        [self pushViewController:passwordPrompt animated:animated];
        self.viewControllers = @[passwordPrompt];
    } else {
        self.viewControllers = @[passwordPrompt];
    }
    
    
    
}

-(void)skipPasscodeVerification{
    [self presentMasterPasswordPromptControllerAnimated:YES];
}

-(PSSWelcomeScreenPINPasscodeSetterViewController*)instanciatePINViewController{
    
    PSSWelcomeScreenPINPasscodeSetterViewController * pinController = [self.storyboard instantiateViewControllerWithIdentifier:@"PINviewController"];
    pinController.promptMode = YES;
    return pinController;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        
        
        
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

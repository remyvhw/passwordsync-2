//
//  PSSWelcomeScreenGesturePasscodeSetterViewController.m
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-07-03.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import "PSSWelcomeScreenGesturePasscodeSetterViewController.h"
#import "SPLockScreen.h"
#import "PSSPasscodeVerifyerViewController.h"
#import "PSSUnlockPromptViewController.h"

@interface PSSWelcomeScreenGesturePasscodeSetterViewController ()
@property (weak, nonatomic) IBOutlet SPLockScreen *lockScreen;
@property (weak, nonatomic) IBOutlet UILabel *instructionsLabel;
@property (weak, nonatomic) IBOutlet UIView *lockScreenSubview;
@property (strong) NSString * currentPasscode;
@property PSSGesturePasscodeStatus passcodeStatus;

@end

@implementation PSSWelcomeScreenGesturePasscodeSetterViewController

-(void)savePasscodeAndContinueWithSegue{
    
    PSSPasscodeVerifyerViewController * passcodeVerifyer = [[PSSPasscodeVerifyerViewController alloc] init];
    
    [passcodeVerifyer savePasscode:self.currentPasscode withType:PSSPasscodeTypeGestureBased];
    
    [self performSegueWithIdentifier:@"userFinishedSettingGesturePasscodeSegue" sender:self];
}

-(void)refreshLabel{
    
    [UIView animateWithDuration:0.2 animations:^{
        [self.instructionsLabel setAlpha:0.0];
    } completion:^(BOOL finished) {
        switch (self.passcodeStatus) {
            case PSSGesturePasscodeStatusUndefined:
                self.instructionsLabel.text = NSLocalizedString(@"Draw your custom gesture pattern", nil);
                break;
            case PSSGesturePasscodeStatusInvalid:
                self.instructionsLabel.text = NSLocalizedString(@"Oops! Your gesture is invalid (repeating circles, overlapping or squiggly lines, too simple gesture, etc). Try again!", nil);
                break;
            case PSSGesturePasscodeStatusNotMatching:
                self.instructionsLabel.text = NSLocalizedString(@"Oops! Your gesture is different this time. Try again from scratch!", nil);
                self.passcodeStatus = PSSGesturePasscodeStatusUndefined;
                self.currentPasscode = nil;
                break;
            case PSSGesturePasscodeStatusValid:
                self.instructionsLabel.text = NSLocalizedString(@"Excellent! Now repeat your gesture!", nil);
                break;
        }
        
        [UIView animateWithDuration:0.2 animations:^{
            [self.instructionsLabel setAlpha:1.0];
        }];
        
        
        
    }];
    
    
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.lockScreen.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    SPLockScreen * lockScreen;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        lockScreen = [[SPLockScreen alloc] initWithFrame:CGRectMake(self.lockScreenSubview.frame.origin.x, self.lockScreenSubview.frame.origin.y, self.lockScreenSubview.frame.size.width, self.lockScreenSubview.frame.size.height)];
        [lockScreen setTranslatesAutoresizingMaskIntoConstraints:NO];
        
    } else {
            lockScreen = [[SPLockScreen alloc] initWithFrame:CGRectMake(0, 0, self.lockScreenSubview.frame.size.width, self.lockScreenSubview.frame.size.height)];
    }

    [lockScreen setAlpha:0.0];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [self.view addSubview:lockScreen];
    } else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
        [self.lockScreenSubview addSubview:lockScreen];
    }


    
    lockScreen.delegate = self;
    self.lockScreen = lockScreen;
    
    CGAffineTransform scaleTransform = CGAffineTransformScale(self.lockScreen.transform, 1.25, 1.25);
        
        self.lockScreen.transform = scaleTransform;
    
    
    [UIView animateWithDuration:0.1 animations:^{
        [lockScreen setAlpha:1.0];
        
        self.lockScreen.transform = CGAffineTransformScale(self.lockScreen.transform, 0.8, 0.8);
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
           [self.lockScreen setCenter:self.lockScreenSubview.center];
        }

        
    }];
    
}

#pragma mark - LockScreenDelegate

-(void)rejectInvalidPasscode {
    self.passcodeStatus = PSSGesturePasscodeStatusInvalid;
    [self refreshLabel];
}

-(void)lockScreen:(SPLockScreen *)lockScreen didEndWithPattern:(NSNumber *)patternNumber{
    
    NSString * chosenPasscode = [patternNumber stringValue];
    
    if (self.promptMode) {
        
        PSSPasscodeVerifyerViewController * passcodeVerifyer = [[PSSPasscodeVerifyerViewController alloc] init];
        
        if ([passcodeVerifyer verifyPasscode:chosenPasscode]) {
            
            [UIView animateWithDuration:1. animations:^{
               
                self.lockScreen.alpha = 0.0;
                self.lockScreen.transform = CGAffineTransformRotate(self.lockScreen.transform, 0.15);
                
                [UIView performWithoutAnimation:^{
                    PSSUnlockPromptViewController * unlockPromptViewController = (PSSUnlockPromptViewController*)self.navigationController;
                    [unlockPromptViewController userDidSuccessfullyUnlockWithPasscode];
                }];
                
            }];
            
            
            
            
        } else {
            
            if (passcodeVerifyer.countOfPasscodeAttempts >= 5) {
                // We must alert the delegate that it's time to reset the passcode with the master password.
                
                PSSUnlockPromptViewController * promptNavigator = (PSSUnlockPromptViewController*)self.navigationController;
                [promptNavigator skipPasscodeVerification];
                
                
            } else {
                
                [UIView animateWithDuration:0.1 animations:^{
                    [self.instructionsLabel setAlpha:0.0];
                } completion:^(BOOL finished) {
                    
                    [self.instructionsLabel setText:NSLocalizedString(@"Invalid gesture. Try again.", nil)];
                    
                    [UIView animateWithDuration:0.1 animations:^{
                        [self.instructionsLabel setAlpha:1.0];
                    }];
                    
                }];
                
                
            }

            
        }
        
        
    } else {
        // We're in setter mode.
        
        // First, let's make sure the pattern number is positive. Negative values are not accepted.
        // We take the long long value as the patterns can be long ass numbers
        if ([patternNumber longLongValue] < 0) {
            [self rejectInvalidPasscode];
            return;
        }
        
        
        // We must parse the chosen passcode to look for repetitions. Theoretically, no number should be repeated.
        
        
        NSMutableArray * arrayOfNumbers = [NSMutableArray arrayWithCapacity:[chosenPasscode length]];
        BOOL shouldRejectRepeteaingNumber = NO;
        for (int counter = 0; counter < [chosenPasscode length]; counter++) {
            
            unichar character = [chosenPasscode characterAtIndex:counter];
            NSNumber * numberForCharacter = @(character); // ASCII decimal character (ex.: @"1" = 49)
            
            BOOL alreadyInArray = NO;
            for (NSNumber *number in arrayOfNumbers) {
                if ([number isEqualToNumber:numberForCharacter]) {
                    alreadyInArray = YES;
                }
            }
            if (!alreadyInArray) {
                [arrayOfNumbers addObject:numberForCharacter];
            } else {
                shouldRejectRepeteaingNumber = YES;
            }
        }
        
        
        if (shouldRejectRepeteaingNumber) {
            [self rejectInvalidPasscode];
            return;
        }
        
        
        // Now set the passcode
        if (!self.currentPasscode) {
            self.currentPasscode = chosenPasscode;
            self.passcodeStatus = PSSGesturePasscodeStatusValid;
            [self refreshLabel];
        } else {
            if ([chosenPasscode isEqualToString:self.currentPasscode]) {
                
                // We can now proceed, the passcodes are identical!
                
                [self savePasscodeAndContinueWithSegue];
            } else {
                
                self.passcodeStatus = PSSGesturePasscodeStatusNotMatching;
                [self refreshLabel];
                
            }
        }
        
        
    }
    
    
    
    
    
}


-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        
        [UIView animateWithDuration:0.1 animations:^{
            [self.lockScreen setCenter:self.lockScreenSubview.center];
        }];
        
    }
}



@end

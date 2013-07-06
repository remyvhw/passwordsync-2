//
//  PSSWelcomeScreenPrintMasterPasswordViewController.m
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-07-01.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import "PSSWelcomeScreenPrintMasterPasswordViewController.h"
#import "PSSMasterPasswordPrintView.h"
#import "PSSMasterPasswordVerifyerViewController.h"
#import "PDKeychainBindings.h"

@interface PSSWelcomeScreenPrintMasterPasswordViewController ()
- (IBAction)neverAskAgainAction:(id)sender;
- (IBAction)printAction:(id)sender;
- (IBAction)skipForNowAction:(id)sender;

@end

@implementation PSSWelcomeScreenPrintMasterPasswordViewController

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
	
    // We don't want users to be able to revert their master password pass this stage.
    self.navigationItem.hidesBackButton = YES;
    
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)navigateToNextViewControllerOrCloseModalNeverAskingAgain:(BOOL)neverAskAgain{
    
    [[NSUserDefaults standardUserDefaults] setBool:neverAskAgain forKey:PSSUserAlreadyPrintedMasterPassword];
    
    // If the user already has a passcode, just dismiss the modal view controller. If the user has no passcode, continue in the current segue.
    
    
    PDKeychainBindings * keychainBindings = [PDKeychainBindings sharedKeychainBindings];
    
    NSString * hashedPasscode = [keychainBindings stringForKey:PSSHashedPasscodeCodeKeychainEntry];

    if (hashedPasscode) {
        // Dismiss
        [self.navigationController dismissViewControllerAnimated:YES completion:^{
            
        }];
    } else {
        [self performSegueWithIdentifier:@"userFinishedPrintingMasterPasswordPushToPasscodeChooserSegue" sender:self];
    }
    
    
    
}


- (IBAction)neverAskAgainAction:(id)sender {
    [self navigateToNextViewControllerOrCloseModalNeverAskingAgain:YES];
}

- (IBAction)printAction:(id)sender {
    
    UIAlertView * passwordPrompt = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Enter your Master Password", nil) message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
    
    [passwordPrompt setAlertViewStyle:UIAlertViewStyleSecureTextInput];
    
    [passwordPrompt show];
    
}

- (IBAction)skipForNowAction:(id)sender {
    [self navigateToNextViewControllerOrCloseModalNeverAskingAgain:NO];
}


#pragma mark - UIAlertViewDelegate method

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex == 0 ) {
        // Cancel button
    } else {
        
        PSSMasterPasswordVerifyerViewController * passwordVerifyer = [[PSSMasterPasswordVerifyerViewController alloc] init];
        
        if ([passwordVerifyer verifyMasterPasswordValidity:[alertView textFieldAtIndex:0].text]) {
            // Master password is valid
            
            CGRect frame = CGRectMake(0, 0, 612, 792);
            PSSMasterPasswordPrintView * printView = [[PSSMasterPasswordPrintView alloc] initWithFrame:frame];
            
            UIGraphicsBeginImageContext(CGSizeMake(612, 792));
            [printView.layer drawInContext:UIGraphicsGetCurrentContext()];
            
            
            
            UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            UIPrintInteractionController *printer = [UIPrintInteractionController sharedPrintController];
            printer.printingItem = viewImage;
            
            UIPrintInfo *info = [UIPrintInfo printInfo];
            info.orientation = UIPrintInfoOrientationLandscape;
            info.outputType = UIPrintInfoOutputGrayscale;
            printer.printInfo = info;
            
            UIPrintInteractionCompletionHandler completionHandler = ^(UIPrintInteractionController *pic, BOOL completed, NSError *error) {
                if (!completed && error){
                    NSLog(@"FAILED! due to error in domain %@ with error code %u: %@", error.domain, error.code, [error localizedDescription]);
                } else {
                    
                    [self navigateToNextViewControllerOrCloseModalNeverAskingAgain:YES];
                    
                    
                }
            };
            
            [printer presentAnimated:YES completionHandler:completionHandler];
            
            
            
        } else {
            
            
            UIAlertView * wrongPassword = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Password is Incorrect", nil) message:NSLocalizedString(@"Cannot Verify Master Password", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
            
            [wrongPassword show];
            
        }
        
        
        
    }
    
    
}


@end

//
//  PSSPasscodeVerifyerViewController.m
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-07-03.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import "PSSPasscodeVerifyerViewController.h"
#import "RVshaDigester.h"
#import "PDKeychainBindings.h"

@interface PSSPasscodeVerifyerViewController ()

@end

@implementation PSSPasscodeVerifyerViewController

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
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)savePasscodeToKeychain:(NSString*)masterPassword{
    RVshaDigester * shaDigester = [[RVshaDigester alloc] init];
    
    // Save the master password itself in keychain as a SHA512 basee64 encoded string.
    [[PDKeychainBindings sharedKeychainBindings] setString:[shaDigester base64EncodedSha512DigestWithString:masterPassword] forKey:PSSHashedPasscodeCodeKeychainEntry];
}

#pragma mark - Public methods
-(void)savePasscode:(NSString*)passcode withType:(PSSPasscodeType)passcodeType{
    
    return;
    [self savePasscodeToKeychain:passcode];
    // Save the passcode type to the keychain; we save it on the keychain so it doesn't get synced all over icloud.
    [[PDKeychainBindings sharedKeychainBindings] setString:[@(passcodeType) stringValue] forKey:PSSDefinedPasscodeType];
    
    
    
}

@end

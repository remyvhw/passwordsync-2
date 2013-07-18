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
#import "PSSAppDelegate.h"

@import AudioToolbox;

@interface PSSPasscodeVerifyerViewController ()

@end

@implementation PSSPasscodeVerifyerViewController

-(NSInteger)countOfPasscodeAttempts{
    NSNumberFormatter * numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    
    NSString * numberOfAttemptsAsAString = [[PDKeychainBindings sharedKeychainBindings] stringForKey:PSSFailedPasscodeAttempsCount];
    NSNumber * numberOfAttempts = [numberFormatter numberFromString:numberOfAttemptsAsAString];
    NSInteger attemptsCount = [numberOfAttempts integerValue];
    return attemptsCount;
}

-(void)savePasscodeToKeychain:(NSString*)passcode{
    RVshaDigester * shaDigester = [[RVshaDigester alloc] init];
    
    // Save the master password itself in keychain as a SHA512 basee64 encoded string.
    [[PDKeychainBindings sharedKeychainBindings] setString:[shaDigester base64EncodedSha512DigestWithString:passcode] forKey:PSSHashedPasscodeCodeKeychainEntry];
}

#pragma mark - Public methods
-(void)savePasscode:(NSString*)passcode withType:(PSSPasscodeType)passcodeType{
    
    [self savePasscodeToKeychain:passcode];
    // Save the passcode type to the keychain; we save it on the keychain so it doesn't get synced all over icloud.
    NSNumberFormatter * numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    
    [[PDKeychainBindings sharedKeychainBindings] setString:[numberFormatter stringFromNumber:@(passcodeType)] forKey:PSSDefinedPasscodeType];
    
    // Reset the failed attempts

    
    [[PDKeychainBindings sharedKeychainBindings] setString:[numberFormatter stringFromNumber:@0] forKey:PSSFailedPasscodeAttempsCount];
    
    PSSAppDelegate * appDelegate = (PSSAppDelegate*)[[UIApplication sharedApplication] delegate];
    appDelegate.isUnlocked = YES;
}

-(BOOL)verifyPasscode:(NSString *)passcode{
    
    NSInteger attemptsCount = [self countOfPasscodeAttempts];
    
    
    // We'll systematically block the user after 4 attempts.
    if (attemptsCount >= 5) {
        return NO;
    }
    
    
    NSString * base64EncodedPasscodeDigestInKeychain = [[PDKeychainBindings sharedKeychainBindings] stringForKey:PSSHashedPasscodeCodeKeychainEntry];
    
    RVshaDigester * shaDigester = [[RVshaDigester alloc] init];
    NSString * base64EncodedPasscodeDigestProvided = [shaDigester base64EncodedSha512DigestWithString:passcode];
    
    NSNumberFormatter * numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    
    if ([base64EncodedPasscodeDigestInKeychain isEqualToString:base64EncodedPasscodeDigestProvided]) {
        // There's a match!
        [[PDKeychainBindings sharedKeychainBindings] setString:[numberFormatter stringFromNumber:@0] forKey:PSSFailedPasscodeAttempsCount];
        PSSAppDelegate * appDelegate = (PSSAppDelegate*)[[UIApplication sharedApplication] delegate];
        appDelegate.isUnlocked = YES;
        return YES;
    }
    
    // Failed attempt...
    AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
    
    // There was no match. Increment by one the attempts
    attemptsCount ++;
    
    [[PDKeychainBindings sharedKeychainBindings] setString:[numberFormatter stringFromNumber:@(attemptsCount)] forKey:PSSFailedPasscodeAttempsCount];
    
    
    return NO;
    
}

@end

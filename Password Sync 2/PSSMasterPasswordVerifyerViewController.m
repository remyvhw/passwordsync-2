//
//  PSSMasterPasswordVerifyerViewController.m
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-07-01.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import "PSSMasterPasswordVerifyerViewController.h"
#import "PDKeychainBindings.h"
#import <Security/Security.h>
#import "RVshaDigester.h"
#import "RNEncryptor.h"
#import "RNDecryptor.h"
#import "PSSAppDelegate.h"

@interface PSSMasterPasswordVerifyerViewController ()

@property (nonatomic, retain, readonly) NSDateFormatter * dateToUserDefaultsAndKeychainStringFormatter;

@end

@implementation PSSMasterPasswordVerifyerViewController
@synthesize dateToUserDefaultsAndKeychainStringFormatter = _dateToUserDefaultsAndKeychainStringFormatter;

-(NSDateFormatter*)dateToUserDefaultsAndKeychainStringFormatter{
    if (_dateToUserDefaultsAndKeychainStringFormatter) {
        return _dateToUserDefaultsAndKeychainStringFormatter;
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd-MM-yyyy HH:mm:ss"];
    _dateToUserDefaultsAndKeychainStringFormatter = dateFormatter;
    
    return _dateToUserDefaultsAndKeychainStringFormatter;
}

-(BOOL)isLocalMasterPasswordCurrent{

    NSString * localMasterPasswordDateString = [[PDKeychainBindings sharedKeychainBindings] stringForKey:PSSlastLocalMasterPasswordChange];;
    NSString * globalMasterPasswordDateString = [[NSUserDefaults standardUserDefaults] stringForKey:PSSlastGlobalMasterPasswordChange];
    
    NSDate * localDate = [self.dateToUserDefaultsAndKeychainStringFormatter dateFromString:localMasterPasswordDateString];
    NSDate * globalDate = [self.dateToUserDefaultsAndKeychainStringFormatter dateFromString:globalMasterPasswordDateString];
    
    
    if ([localDate compare:globalDate] == NSOrderedDescending) {
        // localDate is later than globalDate
        // Userdefaults probably haven't synchronized yet
        return YES;
    } else if ([localDate compare:globalDate] == NSOrderedAscending) {
        // localDate is earlier than globalDate
        return NO;
    }
    
    // Dates are the same
    return YES;
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
    // Do any additional setup after loading the view from its nib.
}

-(NSString*)generateMasterPasswordHash:(NSString*)masterPassword{
    RVshaDigester * shaDigester = [[RVshaDigester alloc] init];
    
    NSString* hash = [shaDigester base64EncodedSha512DigestWithString:masterPassword];
    return hash;
}

-(NSString*)generateMasterPasswordHash:(NSString *)masterPassword hint:(NSString *)hint{
    return [self generateMasterPasswordHash:masterPassword];
}

-(void)saveMasterPasswordToKeychain:(NSString*)masterPassword{
        // Save the master password itself in keychain as a SHA512 base64 encoded string.
    [[PDKeychainBindings sharedKeychainBindings] setString:[self generateMasterPasswordHash:masterPassword] forKey:PSSHashedMasterPasswordKeychainEntry];
}

-(void)saveLastMasterPasswordLocalChangeToKeychainWithDate:(NSString*)dateString{
    // Will save the last master password change locally so we can compare with an iCloud global value so we know when the user changes it's master password
    
    [[PDKeychainBindings sharedKeychainBindings] setString:dateString forKey:PSSlastLocalMasterPasswordChange];
    
}

-(void)saveLastMasterPasswordGlobalChangeToSyncingDefaults:(NSString*)dateString{
    // Will save the last master password change globally
    
    [[NSUserDefaults standardUserDefaults] setObject:dateString forKey:PSSlastGlobalMasterPasswordChange];
    
}


#pragma mark - Public methods
-(void)saveNewMasterPassword:(NSString*)masterPassword hint:(NSString*)hint{
    
    RVshaDigester * shaDigester = [[RVshaDigester alloc] init];

    [self saveMasterPasswordToKeychain:masterPassword];
    
    // Save the hint
    NSString * passwordHint = hint;
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:passwordHint forKey:PSSMasterPasswordHintTextString];
    
    // Encode a verification message
    // We will concatenate a static string with the user's password hint. That static string will then be SHA512 digested, and represented in a Base 64 string. We will then use the same algorithm as the other passwords to encode that base64 digest string with the master password. The NSData will then be saved on iCloud on NSUserDefaults.
    NSString*completeVerificationString = [NSString stringWithFormat:@"%@%@", PSSPasswordVerificationPaddingStaticString, passwordHint];
    
    
    NSData * verificationStringDigest = [shaDigester sha512DataDigestWithString:completeVerificationString];
    
    
    NSError * encryptionError; // Encrypted with the REAL, plaintext password!
    NSData * encryptedVerificationString = [RNEncryptor encryptData:verificationStringDigest withSettings:kRNCryptorAES256Settings password:masterPassword error:&encryptionError];
    
    
    [userDefaults setObject:encryptedVerificationString forKey:PSSMasterPasswordVerificationHash];
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:PSSApplicationWasConfiguredOnAnotherDeviceDefaults];
    
    NSDate * now = [NSDate date];
    NSString *strDate = [self.dateToUserDefaultsAndKeychainStringFormatter stringFromDate:now];
    [self saveLastMasterPasswordLocalChangeToKeychainWithDate:strDate];
    [self saveLastMasterPasswordGlobalChangeToSyncingDefaults:strDate];
    
    [userDefaults synchronize];
    
    PSSAppDelegate * appDelegate = (PSSAppDelegate*)[[UIApplication sharedApplication] delegate];
    appDelegate.isUnlocked = YES;
    
}

-(BOOL)verifyMasterPasswordValidity:(NSString *)providedMasterPassword{
    PDKeychainBindings * keychainBindings = [PDKeychainBindings sharedKeychainBindings];
    RVshaDigester * shaDigester = [[RVshaDigester alloc] init];

    NSString * shaedProvidedPassword = [shaDigester base64EncodedSha512DigestWithString:providedMasterPassword];
                             
    // Check if master password is in keychain
    NSString * hashedMasterPasswordInKeychain = [keychainBindings stringForKey:PSSHashedMasterPasswordKeychainEntry];
    
    // If a hashed master password is in the keychain but is not current, we start from scratch and consider we don't have any.
    if (![self isLocalMasterPasswordCurrent]) {
        hashedMasterPasswordInKeychain = nil;
    }
    
    if (hashedMasterPasswordInKeychain) {
        // Just compare the provided master password
        
        if ([hashedMasterPasswordInKeychain isEqualToString:shaedProvidedPassword]) {
            // The same passwords are identical
            PSSAppDelegate * appDelegate = (PSSAppDelegate*)[[UIApplication sharedApplication] delegate];
            appDelegate.isUnlocked = YES;
            return YES;
        }
        
    } else {
        // We should compare the master password with the iCloud/NSUserDefaults hash
        
        NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
        
        
        // Build the string based on what the user provided
        NSString*providedVerificationString = [NSString stringWithFormat:@"%@%@", PSSPasswordVerificationPaddingStaticString, [userDefaults objectForKey:PSSMasterPasswordHintTextString]];
        
        NSData * providedVerificationStringDigest = [shaDigester sha512DataDigestWithString:providedVerificationString];
        
        // Decrypt the expected string with the password provided by the user
        
        NSData * encryptedVerificationStringDigest = [userDefaults objectForKey:PSSMasterPasswordVerificationHash];
        
        NSError * decryptionError;
        NSData * decryptedData = [RNDecryptor decryptData:encryptedVerificationStringDigest withPassword:providedMasterPassword error:&decryptionError];
        
        if (decryptionError) {
            // Provided password is incorrect
            NSLog(@"%@", [decryptionError description]);
            return NO;
        }
        
        // There was no decryption error, chances are we have indeed the same master password.
        if ([decryptedData isEqualToData:providedVerificationStringDigest]) {
            
            // Save the master password to the keychain
            
            [self saveMasterPasswordToKeychain:providedMasterPassword];
            
            [self saveLastMasterPasswordLocalChangeToKeychainWithDate:[[NSUserDefaults standardUserDefaults] stringForKey:PSSlastGlobalMasterPasswordChange]];
        
            return YES;
        }
        
        
    }
    
    
    return NO;
    
}

@end

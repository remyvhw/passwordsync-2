//
//  PSSEncryptor.m
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-07-06.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import "PSSEncryptor.h"
#import "PSSAppDelegate.h"
#import "PDKeychainBindings.h"
#import "RNEncryptor.h"
#import "RNDecryptor.h"

@implementation PSSEncryptor


+(NSData*)encryptData:(NSData *)dataToEncrypt{
    
    PDKeychainBindings * keychainBindings = [PDKeychainBindings sharedKeychainBindings];
    NSString * hashedMasterPassword = [keychainBindings stringForKey:PSSHashedMasterPasswordKeychainEntry];
    
    
    NSError * error;
    NSData * encryptedData = [RNEncryptor encryptData:dataToEncrypt withSettings:kRNCryptorAES256Settings password:hashedMasterPassword error:&error];
    
    if (error) {
        return nil;
    }
    
    return encryptedData;
}

+(NSData*)decryptData:(NSData *)encryptedData{
    
    
    // First, we won't decrypt anything if the app hasn't been unlocked with a passcode/master password
    PSSAppDelegate * appDelegate = (PSSAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    if (!appDelegate.isUnlocked) {
        return nil;
    }
    
    PDKeychainBindings * keychainBindings = [PDKeychainBindings sharedKeychainBindings];
    NSString * hashedMasterPassword = [keychainBindings stringForKey:PSSHashedMasterPasswordKeychainEntry];
    
    
    NSError * error;
    NSData * unencryptedData = [RNDecryptor decryptData:encryptedData withPassword:hashedMasterPassword error:&error];
    
    if (error) {
        return nil;
    }
    
    
    return unencryptedData;
}


+(NSData*)encryptString:(NSString *)stringToEncrypt{
    
    NSData* data=[stringToEncrypt dataUsingEncoding:NSUTF8StringEncoding];
    
    return [PSSEncryptor encryptData:data];
}

+(NSString*)decryptString:(NSData *)encryptedData{
    
    NSData *decryptedData = [PSSEncryptor decryptData:encryptedData];
    
    NSString* decryptedString = [[NSString alloc] initWithData:decryptedData encoding:NSUTF8StringEncoding];
    
    return decryptedString;
}

@end

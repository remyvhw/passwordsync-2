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

+(NSData*)encryptData:(NSData*)decryptedData withPasswordHash:(NSString*)passwordHash{
    
    NSError * error;
    NSData * encryptedData = [RNEncryptor encryptData:decryptedData withSettings:kRNCryptorAES256Settings password:passwordHash error:&error];
    
    if (error) {
        return nil;
    }
    
    return encryptedData;
    
}

+(NSData*)encryptData:(NSData *)dataToEncrypt{
    
    PDKeychainBindings * keychainBindings = [PDKeychainBindings sharedKeychainBindings];
    NSString * hashedMasterPassword = [keychainBindings stringForKey:PSSHashedMasterPasswordKeychainEntry];
    
    NSData * encryptedData = [self encryptData:dataToEncrypt withPasswordHash:hashedMasterPassword];
    
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


+(NSData*)reencryptData:(NSData *)originalData withPassword:(NSString *)newPassword{
    
    // First, we'll decrypt the provided data with the master password in the keychain
    NSData * decryptedData = [self decryptData:originalData];
    
    // Encrypt the data with the provided password
    
    NSData * reencryptedData = [self encryptData:decryptedData withPasswordHash:newPassword];
    return reencryptedData;
    
}

@end

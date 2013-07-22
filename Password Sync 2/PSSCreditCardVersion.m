//
//  PSSCreditCardVersion.m
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-06-27.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import "PSSCreditCardVersion.h"


@implementation PSSCreditCardVersion

@dynamic bankPhoneNumber;
@dynamic bankWebsite;
@dynamic cardholdersName;
@dynamic cardType;
@dynamic expiryDate;
@dynamic issuingBank;
@dynamic note;
@dynamic number;
@dynamic pin;
@dynamic unencryptedLastDigits;
@dynamic verificationCode;

@synthesize decryptedCardholdersName = _decryptedCardholdersName;
@synthesize decryptedExpiryDate = _decryptedExpiryDate;
@synthesize decryptedNote = _decryptedNote;
@synthesize decryptedNumber = _decryptedNumber;
@synthesize decryptedPin = _decryptedPin;
@synthesize decryptedVerificationcode = _decryptedVerificationcode;

-(NSString*)decryptedCardholdersName{
    if (!_decryptedCardholdersName) {
        NSLog(@"Decrypted Name");
        NSString * decryptedCardholders = [self decryptDataToUTF8String:self.cardholdersName];
        _decryptedCardholdersName = decryptedCardholders;
    }
    
    return _decryptedCardholdersName;
}

-(void)setDecryptedCardholdersName:(NSString *)decryptedCardholdersName{
    
    self.cardholdersName = [self encryptedDataFromUTF8String:decryptedCardholdersName];
    _decryptedCardholdersName = decryptedCardholdersName;
}

-(NSString*)decryptedExpiryDate{
    if (!_decryptedExpiryDate) {
        NSString * decryptedExpiry = [self decryptDataToUTF8String:self.expiryDate];
        _decryptedExpiryDate = decryptedExpiry;
    }
    
    return _decryptedExpiryDate;
}

-(void)setDecryptedExpiryDate:(NSString *)decryptedExpiryDate{
    
    self.expiryDate = [self encryptedDataFromUTF8String:decryptedExpiryDate];
    _decryptedExpiryDate = decryptedExpiryDate;
}

-(NSString*)decryptedNote{
    
    if (!_decryptedNote) {
        NSString * decryptedNote = [self decryptDataToUTF8String:self.note];
        _decryptedNote = decryptedNote;
    }
    
    return _decryptedNote;
}

-(void)setDecryptedNote:(NSString *)decryptedNote{
    self.note = [self encryptedDataFromUTF8String:decryptedNote];
    _decryptedNote = decryptedNote;
}

-(NSString*)decryptedNumber{
    
    if (!_decryptedNumber) {
        NSString * decryptedNumber = [self decryptDataToUTF8String:self.number];
        _decryptedNumber = decryptedNumber;
    }
    
    return _decryptedNumber;
}

-(void)setDecryptedNumber:(NSString *)decryptedNumber{
    
    self.number = [self encryptedDataFromUTF8String:decryptedNumber];
    _decryptedNumber = decryptedNumber;
}

-(NSString*)decryptedPin{
    
    if (!_decryptedPin) {
        NSString * decryptedPin = [self decryptDataToUTF8String:self.pin];
        _decryptedPin = decryptedPin;
    }
    
    return _decryptedPin;
}

-(void)setDecryptedPin:(NSString *)decryptedPin{
    
    self.pin = [self encryptedDataFromUTF8String:decryptedPin];
    _decryptedPin = decryptedPin;
}

-(NSString*)decryptedVerificationcode{
    if (!_decryptedVerificationcode) {
        NSString * decryptedCVV = [self decryptDataToUTF8String:self.verificationCode];
        _decryptedVerificationcode = decryptedCVV;
    }
    return _decryptedVerificationcode;
}

-(void)setDecryptedVerificationcode:(NSString *)decryptedVerificationcode{
    
    self.verificationCode = [self encryptedDataFromUTF8String:decryptedVerificationcode];
    _decryptedVerificationcode = decryptedVerificationcode;
}



@end

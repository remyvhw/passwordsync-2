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
    return [self decryptDataToUTF8String:self.cardholdersName];
}

-(void)setDecryptedCardholdersName:(NSString *)decryptedCardholdersName{
    
    self.cardholdersName = [self encryptedDataFromUTF8String:decryptedCardholdersName];
}

-(NSString*)decryptedExpiryDate{
    return [self decryptDataToUTF8String:self.expiryDate];
}

-(void)setDecryptedExpiryDate:(NSString *)decryptedExpiryDate{
    
    self.expiryDate = [self encryptedDataFromUTF8String:decryptedExpiryDate];
}

-(NSString*)decryptedNote{
    return [self decryptDataToUTF8String:self.note];
}

-(void)setDecryptedNote:(NSString *)decryptedNote{
    
    self.note = [self encryptedDataFromUTF8String:decryptedNote];
}

-(NSString*)decryptedNumber{
    return [self decryptDataToUTF8String:self.number];
}

-(void)setDecryptedNumber:(NSString *)decryptedNumber{
    
    self.number = [self encryptedDataFromUTF8String:decryptedNumber];
}

-(NSString*)decryptedPin{
    return [self decryptDataToUTF8String:self.pin];
}

-(void)setDecryptedPin:(NSString *)decryptedPin{
    
    self.pin = [self encryptedDataFromUTF8String:decryptedPin];
}

-(NSString*)decryptedVerificationcode{
    return [self decryptDataToUTF8String:self.verificationCode];
}

-(void)setDecryptedVerificationcode:(NSString *)decryptedVerificationcode{
    
    self.verificationCode = [self encryptedDataFromUTF8String:decryptedVerificationcode];
}



@end

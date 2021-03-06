//
//  PSSCreditCardVersion.h
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-06-27.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "PSSBaseObjectVersion.h"
#import "CardIO.h"

@interface PSSCreditCardVersion : PSSBaseObjectVersion

@property (nonatomic, retain) NSString * bankPhoneNumber;
@property (nonatomic, retain) NSString * bankWebsite;
@property (nonatomic, retain) NSData * cardholdersName;
@property (nonatomic, retain) NSString * cardType;
@property (nonatomic, retain) NSData * expiryDate;
@property (nonatomic, retain) NSString * issuingBank;
@property (nonatomic, retain) NSData * note;
@property (nonatomic, retain) NSData * number;
@property (nonatomic, retain) NSData * pin;
@property (nonatomic, retain) NSString * unencryptedLastDigits;
@property (nonatomic, retain) NSData * verificationCode;

@property (nonatomic, strong) NSString * decryptedCardholdersName;
@property (nonatomic, strong) NSString * decryptedExpiryDate;
@property (nonatomic, strong) NSString * decryptedNote;
@property (nonatomic, strong) NSString * decryptedNumber;
@property (nonatomic, strong) NSString * decryptedPin;
@property (nonatomic, strong) NSString * decryptedVerificationcode;

@property CardIOCreditCardType rawCardType;


-(NSString*)localizedCardType;
-(UIImage*)imageForCardType;

@end

//
//  PSSLocationVersion.m
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-07-18.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import "PSSLocationVersion.h"


@implementation PSSLocationVersion
@synthesize decryptedNotes = _decryptedNotes;
@synthesize decryptedPassword = _decryptedPassword;
@synthesize decryptedUsername = _decryptedUsername;

@dynamic latitude;
@dynamic longitude;
@dynamic displayName;
@dynamic username;
@dynamic password;
@dynamic notes;
@dynamic radius;
@dynamic cllocation;

-(NSString*)decryptedUsername{
    return [self decryptDataToUTF8String:self.username];
}

-(void)setDecryptedUsername:(NSString *)decryptedUsername{
    
    self.username = [self encryptedDataFromUTF8String:decryptedUsername];
}

-(NSString*)decryptedPassword{
    return [self decryptDataToUTF8String:self.password];
}

-(void)setDecryptedPassword:(NSString *)decryptedPassword{
    
    self.password = [self encryptedDataFromUTF8String:decryptedPassword];
}

-(NSString*)decryptedNotes{
    return [self decryptDataToUTF8String:self.notes];
}

-(void)setDecryptedNotes:(NSString *)decryptedNotes{
    self.notes = [self encryptedDataFromUTF8String:decryptedNotes];
}


@end

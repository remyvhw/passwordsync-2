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
@dynamic address;

-(NSString*)decryptedUsername{
    
    if (_decryptedUsername) {
        return _decryptedUsername;
    }
    
    NSString * decryptedUsername = [self decryptDataToUTF8String:self.username];
    
    _decryptedUsername = decryptedUsername;
    return _decryptedUsername;
}

-(void)setDecryptedUsername:(NSString *)decryptedUsername{
    _decryptedUsername = decryptedUsername;
    self.username = [self encryptedDataFromUTF8String:decryptedUsername];
}

-(NSString*)decryptedPassword{
    
    if (_decryptedPassword) {
        return _decryptedPassword;
    }
    
    NSString * decryptedPassword = [self decryptDataToUTF8String:self.password];
    _decryptedPassword = decryptedPassword;
    return decryptedPassword;
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

-(void)reencryptAllContainedObjectsWithPasswordHash:(NSString *)newPasswordHash{
    [super reencryptAllContainedObjectsWithPasswordHash:newPasswordHash];
    
    self.username = [self reencryptData:self.username withPassword:newPasswordHash];
    self.password = [self reencryptData:self.password withPassword:newPasswordHash];
    self.notes = [self reencryptData:self.notes withPassword:newPasswordHash];
}

@end

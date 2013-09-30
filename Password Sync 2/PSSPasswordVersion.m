//
//  PSSPasswordVersion.m
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-06-27.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import "PSSPasswordVersion.h"

@implementation PSSPasswordVersion
@synthesize decryptedNotes = _decryptedNotes;
@synthesize decryptedPassword = _decryptedPassword;
@synthesize decryptedUsername = _decryptedUsername;

@dynamic notes;
@dynamic password;
@dynamic username;
@dynamic displayName;


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

-(void)reencryptAllContainedObjectsWithPasswordHash:(NSString *)newPasswordHash{
    [super reencryptAllContainedObjectsWithPasswordHash:newPasswordHash];
    
    self.username = [self reencryptData:self.username withPassword:newPasswordHash];
    self.password = [self reencryptData:self.password withPassword:newPasswordHash];
    self.notes = [self reencryptData:self.notes withPassword:newPasswordHash];
}

@end

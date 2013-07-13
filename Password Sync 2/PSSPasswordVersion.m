//
//  PSSPasswordVersion.m
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-06-27.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import "PSSPasswordVersion.h"

@implementation PSSPasswordVersion

@dynamic notes;
@dynamic password;
@dynamic username;


-(NSString*)decryptedUsername{
    return [self decryptDataToUTF8String:self.username];
}


-(NSString*)decryptedPassword{
    return [self decryptDataToUTF8String:self.password];
}


-(NSString*)decryptedNotes{
    return [self decryptDataToUTF8String:self.notes];
}

@end

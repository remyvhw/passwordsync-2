//
//  PSSPasswordBaseObject.m
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-06-27.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import "PSSPasswordBaseObject.h"
#import "PSSPasswordVersion.h"
#import "PSSEncryptor.h"

@implementation PSSPasswordBaseObject
@synthesize currentVersion = _currentVersion;


@dynamic autofill;
@dynamic favicon;
@dynamic hostname;


-(PSSPasswordVersion*)currentVersion{
    
    if (_currentVersion) {
        return _currentVersion;
    }
    
    NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"PSSPasswordVersion"];
    NSSortDescriptor *dateSort = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:NO];
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"(encryptedObject == %@)", self];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:dateSort]];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setFetchLimit:1];
    
    NSError * error;
    NSArray * results = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (error || [results count] == 0) {
        return nil;
    }
    
    return [results objectAtIndex:0];
}



-(NSString*)notes{
    
    NSData * encryptorData = [PSSEncryptor decryptData:self.currentVersion.notes];
    
    if (!encryptorData) {
        return @"••••••••••";
    }
    
    
    return [NSString stringWithUTF8String:[encryptorData bytes]];
    
}

-(NSString*)password{
    
    NSData * encryptorData = [PSSEncryptor decryptData:self.currentVersion.password];
    
    if (!encryptorData) {
        return @"••••••••••";
    }
    
    
    return [NSString stringWithUTF8String:[encryptorData bytes]];
    
}

-(NSString*)username{
    
    NSData * encryptorData = [PSSEncryptor decryptData:self.currentVersion.username];
    
    if (!encryptorData) {
        return @"••••••••••";
    }
    
    
    return [NSString stringWithUTF8String:[encryptorData bytes]];
    
}


@end

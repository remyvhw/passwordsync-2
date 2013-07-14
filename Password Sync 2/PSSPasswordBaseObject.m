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
#import "PSSPasswordDomain.h"

@implementation PSSPasswordBaseObject
@synthesize currentVersion = _currentVersion;


@dynamic autofill;
@dynamic favicon;
@dynamic domains;


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


-(PSSPasswordDomain*)insertNewDomainInManagedObjectWithURLString:(NSString*)urlString{
    
    
    // Look up for a similar URL
    NSFetchRequest * fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"PSSPasswordDomain"];
    
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"original_url like[cd] %@", urlString]];
    [fetchRequest setFetchBatchSize:1];
    
    NSArray * existingDomainsWithSameURL = [self.managedObjectContext executeFetchRequest:fetchRequest error:NULL];
    
    if ([existingDomainsWithSameURL count]) {
        // Already exists
        return [existingDomainsWithSameURL objectAtIndex:0];
    }
    
    // No such object, create one
    
    PSSPasswordDomain *newManagedObject = (PSSPasswordDomain*)[NSEntityDescription insertNewObjectForEntityForName:@"PSSPasswordDomain" inManagedObjectContext:self.managedObjectContext];
    
    // We'll automatically timestamp it
    newManagedObject.timestamp = [NSDate date];
    newManagedObject.original_url = urlString;
    newManagedObject.hostname = [newManagedObject cleanUpHostname:urlString];
    
    return newManagedObject;
}

-(void)setMainDomainFromString:(NSString *)originalStringDomain{
    
    
    NSString * mainDomain = nil;
    if ([originalStringDomain length] && [originalStringDomain rangeOfString:@"://"].location == NSNotFound) {
        
        // URL Exists but does not contains @"http://", @"ftp://", @"ssh://", @"pop3.", @"imap.",  insert it.
        mainDomain = [[NSString alloc] initWithFormat:@"http://%@", originalStringDomain];
    } else {
        mainDomain = originalStringDomain;
    }

    
    if (![self.domains count] && ![mainDomain isEqualToString:@""]) {
        // There are no domains yet and user provided a domain, find the same URL in the datastore just in case. If we can't find any, create a new domain.
        PSSPasswordDomain * domain = [self insertNewDomainInManagedObjectWithURLString:mainDomain];
        NSMutableSet * mutableSet = [NSMutableSet setWithSet:domain.passwords];
        [mutableSet addObject:self];
        domain.passwords = (NSSet*)mutableSet;
        
    } else if ([self.domains count] ){
        // There a domains in the password list
        
        if ([mainDomain isEqualToString:@""]) {
            // User deleted hostname. Delete all hostnames
            
            self.domains = nil;
            
        } else if (![mainDomain isEqualToString:[[self mainDomain] original_url]]) {
            // Maindomains are differents
            
            PSSPasswordDomain * domain = [self insertNewDomainInManagedObjectWithURLString:mainDomain];
            NSMutableSet * mutableSet = [NSMutableSet setWithSet:domain.passwords];
            [mutableSet addObject:self];
            domain.passwords = (NSSet*)mutableSet;
            
        }
        
    }
    
}

-(PSSPasswordDomain*)mainDomain{
    
    NSSortDescriptor * timestampDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:NO];
    NSArray * allDomains = [self.domains sortedArrayUsingDescriptors:@[timestampDescriptor]];
    
    if ([allDomains count]) {
        return [allDomains objectAtIndex:0];
    }
    return nil;
}

@end

//
//  PSSLocationBaseObject.m
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-07-18.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import "PSSLocationBaseObject.h"
#import "PSSLocationVersion.h"

@implementation PSSLocationBaseObject
@synthesize currentVersion = _currentVersion;

@dynamic shouldGeofence;
@dynamic address;

-(PSSLocationVersion*)currentVersion{
    
    if (_currentVersion) {
        return _currentVersion;
    }
    
    NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"PSSLocationVersion"];
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

@end

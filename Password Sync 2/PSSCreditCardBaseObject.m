//
//  PSSCreditCardBaseObject.m
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-06-27.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import "PSSCreditCardBaseObject.h"
#import "PSSCreditCardVersion.h"

@implementation PSSCreditCardBaseObject
@synthesize currentVersion = _currentVersion;
@dynamic autofill;

-(PSSCreditCardVersion*)currentVersion{
    
    if (_currentVersion) {
        return _currentVersion;
    }
    
    NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"PSSCreditCardVersion"];
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
    
    PSSCreditCardVersion * currentVersion = [results objectAtIndex:0];
    _currentVersion = currentVersion;
    return currentVersion;
}




@end

//
//  PSSPasswordDomain.h
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-07-13.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class PSSPasswordBaseObject;

@interface PSSPasswordDomain : NSManagedObject

@property (nonatomic, retain) NSString * hostname;
@property (nonatomic, retain) NSDate * timestamp;
@property (nonatomic, retain) NSString * original_url;
@property (nonatomic, retain) NSSet *passwords;
@end

@interface PSSPasswordDomain (CoreDataGeneratedAccessors)

- (void)addPasswordsObject:(PSSPasswordBaseObject *)value;
- (void)removePasswordsObject:(PSSPasswordBaseObject *)value;
- (void)addPasswords:(NSSet *)values;
- (void)removePasswords:(NSSet *)values;

-(NSString*)cleanUpHostname:(NSString*)dirtyHost;

@end

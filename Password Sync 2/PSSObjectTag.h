//
//  PSSObjectTag.h
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-06-27.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class PSSBaseGenericObject;

@interface PSSObjectTag : NSManagedObject

@property (nonatomic, retain) id color;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *encryptedObjects;
@end

@interface PSSObjectTag (CoreDataGeneratedAccessors)

- (void)addEncryptedObjectsObject:(PSSBaseGenericObject *)value;
- (void)removeEncryptedObjectsObject:(PSSBaseGenericObject *)value;
- (void)addEncryptedObjects:(NSSet *)values;
- (void)removeEncryptedObjects:(NSSet *)values;

@end

//
//  PSSObjectCategory.h
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-06-27.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class PSSBaseGenericObject, PSSObjectCategory;

@interface PSSObjectCategory : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *children;
@property (nonatomic, retain) NSSet *encryptedObjects;
@property (nonatomic, retain) PSSObjectCategory *parent;
@end

@interface PSSObjectCategory (CoreDataGeneratedAccessors)

- (void)addChildrenObject:(PSSObjectCategory *)value;
- (void)removeChildrenObject:(PSSObjectCategory *)value;
- (void)addChildren:(NSSet *)values;
- (void)removeChildren:(NSSet *)values;

- (void)addEncryptedObjectsObject:(PSSBaseGenericObject *)value;
- (void)removeEncryptedObjectsObject:(PSSBaseGenericObject *)value;
- (void)addEncryptedObjects:(NSSet *)values;
- (void)removeEncryptedObjects:(NSSet *)values;

@end

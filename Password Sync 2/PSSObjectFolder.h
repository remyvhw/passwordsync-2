//
//  PSSObjectFolder.h
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-08-15.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class PSSBaseGenericObject, PSSObjectFolder;

@interface PSSObjectFolder : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *children;
@property (nonatomic, retain) NSSet *encryptedObjects;
@property (nonatomic, retain) PSSObjectFolder *parent;
@end

@interface PSSObjectFolder (CoreDataGeneratedAccessors)

- (void)addChildrenObject:(PSSObjectFolder *)value;
- (void)removeChildrenObject:(PSSObjectFolder *)value;
- (void)addChildren:(NSSet *)values;
- (void)removeChildren:(NSSet *)values;

- (void)addEncryptedObjectsObject:(PSSBaseGenericObject *)value;
- (void)removeEncryptedObjectsObject:(PSSBaseGenericObject *)value;
- (void)addEncryptedObjects:(NSSet *)values;
- (void)removeEncryptedObjects:(NSSet *)values;

@end

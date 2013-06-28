//
//  PSSBaseGenericObject.h
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-06-27.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class PSSBaseGenericObject, PSSBaseObjectVersion, PSSObjectCategory, PSSObjectDecorativeImage, PSSObjectTag;

@interface PSSBaseGenericObject : NSManagedObject

@property (nonatomic, retain) NSDate * created;
@property (nonatomic, retain) NSString * displayName;
@property (nonatomic, retain) PSSObjectCategory *category;
@property (nonatomic, retain) PSSBaseGenericObject *children;
@property (nonatomic, retain) NSSet *decorativeImage;
@property (nonatomic, retain) PSSBaseGenericObject *parent;
@property (nonatomic, retain) NSSet *tags;
@property (nonatomic, retain) NSSet *versions;
@end

@interface PSSBaseGenericObject (CoreDataGeneratedAccessors)

- (void)addDecorativeImageObject:(PSSObjectDecorativeImage *)value;
- (void)removeDecorativeImageObject:(PSSObjectDecorativeImage *)value;
- (void)addDecorativeImage:(NSSet *)values;
- (void)removeDecorativeImage:(NSSet *)values;

- (void)addTagsObject:(PSSObjectTag *)value;
- (void)removeTagsObject:(PSSObjectTag *)value;
- (void)addTags:(NSSet *)values;
- (void)removeTags:(NSSet *)values;

- (void)addVersionsObject:(PSSBaseObjectVersion *)value;
- (void)removeVersionsObject:(PSSBaseObjectVersion *)value;
- (void)addVersions:(NSSet *)values;
- (void)removeVersions:(NSSet *)values;

@end

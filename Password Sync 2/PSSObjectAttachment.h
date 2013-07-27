//
//  PSSObjectAttachment.h
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-07-25.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class PSSBaseObjectVersion, PSSObjectDecorativeImage;

@interface PSSObjectAttachment : NSManagedObject

@property (nonatomic, retain) NSData * binaryContent;
@property (nonatomic, retain) NSData * name;
@property (nonatomic, retain) NSDate * timestamp;
@property (nonatomic, retain) NSSet *encryptedObjectVersions;
@property (nonatomic, retain) NSString * fileExtension;
@property (nonatomic, retain) PSSObjectDecorativeImage *thumbnail;

@property (nonatomic, retain) NSData * decryptedBinaryContent;


@end

@interface PSSObjectAttachment (CoreDataGeneratedAccessors)

- (void)addEncryptedObjectVersionsObject:(PSSBaseObjectVersion *)value;
- (void)removeEncryptedObjectVersionsObject:(PSSBaseObjectVersion *)value;
- (void)addEncryptedObjectVersions:(NSSet *)values;
- (void)removeEncryptedObjectVersions:(NSSet *)values;

@end

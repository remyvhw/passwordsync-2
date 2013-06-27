//
//  PSSBaseObjectVersion.h
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-06-27.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class PSSBaseGenericObject, PSSObjectAttachment;

@interface PSSBaseObjectVersion : NSManagedObject

@property (nonatomic, retain) NSData * additionalJSONfields;
@property (nonatomic, retain) NSString * displayName;
@property (nonatomic, retain) NSDate * timestamp;
@property (nonatomic, retain) NSSet *attachments;
@property (nonatomic, retain) PSSBaseGenericObject *encryptedObject;
@end

@interface PSSBaseObjectVersion (CoreDataGeneratedAccessors)

- (void)addAttachmentsObject:(PSSObjectAttachment *)value;
- (void)removeAttachmentsObject:(PSSObjectAttachment *)value;
- (void)addAttachments:(NSSet *)values;
- (void)removeAttachments:(NSSet *)values;

@end

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
@property (nonatomic, retain) NSDate * timestamp;
@property (nonatomic, retain) NSSet *attachments;
@property (nonatomic, retain) PSSBaseGenericObject *encryptedObject;
@property (nonatomic, retain) PSSBaseGenericObject *currentOwningBaseObject;

@property (nonatomic, strong) NSData * decryptedAdditionalJSONfields;
-(NSString*)decryptDataToUTF8String:(NSData*)encryptedString;
-(NSData*)encryptedDataFromUTF8String:(NSString*)string;

-(NSData*)reencryptData:(NSData*)data withPassword:(NSString*)password;

-(void)reencryptAllContainedObjectsWithPasswordHash:(NSString*)newPasswordHash;

@end

@interface PSSBaseObjectVersion (CoreDataGeneratedAccessors)

- (void)addAttachmentsObject:(PSSObjectAttachment *)value;
- (void)removeAttachmentsObject:(PSSObjectAttachment *)value;
- (void)addAttachments:(NSSet *)values;
- (void)removeAttachments:(NSSet *)values;



@end

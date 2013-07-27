//
//  PSSObjectDecorativeImage.h
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-07-27.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class PSSBaseGenericObject, PSSDocumentBaseObject, PSSObjectAttachment;

@interface PSSObjectDecorativeImage : NSManagedObject

@property (nonatomic, retain) NSData * data;
@property (nonatomic, retain) NSDate * timestamp;
@property (nonatomic, retain) NSString * viewportIdentifier;
@property (nonatomic, retain) PSSObjectAttachment *attachment;
@property (nonatomic, retain) PSSBaseGenericObject *encryptedObject;
@property (nonatomic, retain) PSSDocumentBaseObject *noteBaseObject;

@property (nonatomic, strong, readonly) UIImage * imageNormal;
@property (nonatomic, strong, readonly) UIImage * imageLightEffect;

@end

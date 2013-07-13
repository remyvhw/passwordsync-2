//
//  PSSPasswordBaseObject.h
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-06-27.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "PSSBaseGenericObject.h"

@class PSSPasswordVersion;

@interface PSSPasswordBaseObject : PSSBaseGenericObject

@property (nonatomic, retain) NSNumber * autofill;
@property (nonatomic, retain) NSData * favicon;
@property (nonatomic, retain) NSString * hostname;

@property (strong, nonatomic) PSSPasswordVersion * currentVersion;
@property (readonly, nonatomic) NSString * notes;
@property (nonatomic, readonly) NSString * password;
@property (readonly, nonatomic) NSString * username;
@property (nonatomic, retain) NSSet *domains;


@end

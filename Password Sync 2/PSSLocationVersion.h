//
//  PSSLocationVersion.h
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-07-18.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "PSSBaseObjectVersion.h"


@interface PSSLocationVersion : PSSBaseObjectVersion

@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSString * displayName;
@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSData * username;
@property (nonatomic, retain) NSData * password;
@property (nonatomic, retain) NSData * notes;
@property (nonatomic, retain) NSNumber * radius;

@property (strong, nonatomic) NSString * decryptedUsername;
@property (strong, nonatomic) NSString * decryptedPassword;
@property (strong, nonatomic) NSString * decryptedNotes;

@end

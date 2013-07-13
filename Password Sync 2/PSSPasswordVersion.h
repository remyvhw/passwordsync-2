//
//  PSSPasswordVersion.h
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-06-27.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "PSSBaseObjectVersion.h"


@interface PSSPasswordVersion : PSSBaseObjectVersion

@property (nonatomic, retain) NSData * notes;
@property (nonatomic, retain) NSData * password;
@property (nonatomic, retain) NSData * username;

-(NSString*)decryptedUsername;
-(NSString*)decryptedPassword;
-(NSString*)decryptedNotes;

@end

//
//  PSSNoteVersion.h
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-07-18.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "PSSBaseObjectVersion.h"


@interface PSSNoteVersion : PSSBaseObjectVersion

@property (nonatomic, retain) NSData * noteTextContent;
@property (nonatomic, retain) NSString * displayName;

@property (strong, nonatomic) NSString * decryptedNoteTextContent;


@end

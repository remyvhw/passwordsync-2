//
//  PSSNoteBaseObject.h
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-06-27.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "PSSBaseGenericObject.h"
#import "PSSObjectDecorativeImage.h"

@interface PSSNoteBaseObject : PSSBaseGenericObject

@property (nonatomic, retain) PSSObjectDecorativeImage * thumbnail;

@end

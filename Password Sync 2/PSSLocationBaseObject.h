//
//  PSSLocationBaseObject.h
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-07-18.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "PSSBaseGenericObject.h"

@class PSSLocationVersion;
@interface PSSLocationBaseObject : PSSBaseGenericObject

@property (strong, nonatomic) PSSLocationVersion * currentVersion;

@end

//
//  PSSCreditCardBaseObject.h
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-06-27.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "PSSBaseGenericObject.h"

@class PSSCreditCardVersion;
@interface PSSCreditCardBaseObject : PSSBaseGenericObject

@property (nonatomic, retain) NSNumber * autofill;
@property (nonatomic, strong) PSSCreditCardVersion * currentVersion;

@end

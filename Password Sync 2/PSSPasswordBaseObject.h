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
@class PSSPasswordDomain;

@interface PSSPasswordBaseObject : PSSBaseGenericObject {
    PSSPasswordDomain * _mainDomain;
}

@property (nonatomic, retain) NSNumber * autofill;
@property (nonatomic, retain) NSData * favicon;

@property (strong, nonatomic) PSSPasswordVersion * currentVersion;

@property (nonatomic, retain) NSSet *domains;
@property (nonatomic, retain) NSArray * fetchedDomains;


-(PSSPasswordDomain*)mainDomain;
-(void)setMainDomainFromString:(NSString *)mainDomain;

@end

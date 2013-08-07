//
//  PSSVersionFlowPasswordCollectionViewController.h
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-08-06.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import "PSSVersionFlowGenericControllerViewController.h"
#import "PSSPasswordBaseObject.h"

@interface PSSVersionFlowPasswordCollectionViewController : PSSVersionFlowGenericControllerViewController

@property (strong, nonatomic) PSSPasswordBaseObject * detailItem;

@end

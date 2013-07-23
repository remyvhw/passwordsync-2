//
//  PSSLocationDetailViewController.h
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-07-23.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import "PSSGenericDetailViewController.h"
#import "PSSLocationBaseObject.h"

@interface PSSLocationDetailViewController : PSSGenericDetailViewController

@property (strong, nonatomic) PSSLocationBaseObject * detailItem;

@end

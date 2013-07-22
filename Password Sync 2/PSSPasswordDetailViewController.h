//
//  PSSPasswordDetailViewController.h
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-07-21.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import "PSSGenericDetailViewController.h"

@class PSSPasswordBaseObject;
@interface PSSPasswordDetailViewController : PSSGenericDetailViewController <UIWebViewDelegate>

@property (strong, nonatomic) PSSPasswordBaseObject * detailItem;

@end

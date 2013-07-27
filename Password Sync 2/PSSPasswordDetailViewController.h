//
//  PSSPasswordDetailViewController.h
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-07-21.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import "PSSGenericDetailTableViewController.h"

@class PSSPasswordBaseObject;
@interface PSSPasswordDetailViewController : PSSGenericDetailTableViewController <UIWebViewDelegate>

@property (strong, nonatomic) PSSPasswordBaseObject * detailItem;

@end

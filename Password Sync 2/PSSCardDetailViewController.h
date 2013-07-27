//
//  PSSCardDetailViewController.h
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-07-22.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import "PSSGenericDetailTableViewController.h"
#import "PSSCreditCardBaseObject.h"

@interface PSSCardDetailViewController : PSSGenericDetailTableViewController

@property (strong, nonatomic) PSSCreditCardBaseObject * detailItem;

@end

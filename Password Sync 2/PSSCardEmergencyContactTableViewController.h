//
//  PSSCardEmergencyContactTableViewController.h
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-07-22.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSSCreditCardBaseObject.h"

@interface PSSCardEmergencyContactTableViewController : UITableViewController <UIActionSheetDelegate>

@property (strong, nonatomic) PSSCreditCardBaseObject * detailItem;

@end

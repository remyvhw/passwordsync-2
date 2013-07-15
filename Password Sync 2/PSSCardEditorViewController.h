//
//  PSSCardEditorViewController.h
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-07-13.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CardIO.h"
@class PSSCreditCardBaseObject;
@interface PSSCardEditorViewController : UITableViewController <CardIOPaymentViewControllerDelegate>

@property (strong, nonatomic) PSSCreditCardBaseObject * cardBaseObject;

@end

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
@protocol PSSCardsEditorCardTypeSelectorProtocol;
@interface PSSCardEditorViewController : UITableViewController <CardIOPaymentViewControllerDelegate, PSSCardsEditorCardTypeSelectorProtocol>

@property (strong, nonatomic) PSSCreditCardBaseObject * cardBaseObject;

@end

//
//  PSSCardsEditorCardTypeSelectorTableViewController.h
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-07-15.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CardIO.h"

@protocol PSSCardsEditorCardTypeSelectorProtocol;

@interface PSSCardsEditorCardTypeSelectorTableViewController : UITableViewController

@property (strong) id<PSSCardsEditorCardTypeSelectorProtocol> cardEditorDelegate;
@property CardIOCreditCardType selectedCardType;

@end

@protocol PSSCardsEditorCardTypeSelectorProtocol <NSObject>

-(void)cardSelector:(PSSCardsEditorCardTypeSelectorTableViewController*)cardSelector finishedWithCardType:(CardIOCreditCardType)cardType;

@end
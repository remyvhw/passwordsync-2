//
//  PSSCardsSplitViewDetailViewController.h
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-08-03.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import "PSSSplitViewGenericDetailNavigationViewController.h"
#import "PSSCreditCardBaseObject.h"

@interface PSSCardsSplitViewDetailViewController : PSSSplitViewGenericDetailNavigationViewController

-(void)presentViewControllerForCardEntity:(PSSCreditCardBaseObject *)cardBaseObject;

@end

//
//  PSSPasswordSplitViewDetailViewController.h
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-08-03.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import "PSSSplitViewGenericDetailNavigationViewController.h"
#import "PSSPasswordBaseObject.h"


@interface PSSPasswordSplitViewDetailViewController : PSSSplitViewGenericDetailNavigationViewController

-(void)presentViewControllerForPasswordEntity:(PSSPasswordBaseObject*)passwordBaseObject;


@end

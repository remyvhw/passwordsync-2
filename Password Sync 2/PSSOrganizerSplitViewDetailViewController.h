//
//  PSSOrganizerSplitViewDetailViewController.h
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-08-17.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import "PSSSplitViewGenericDetailNavigationViewController.h"
#import "PSSObjectTag.h"

@interface PSSOrganizerSplitViewDetailViewController : PSSSplitViewGenericDetailNavigationViewController

-(void)presentViewControllerForTagEntity:(PSSObjectTag*)tagBaseObject;
-(void)forcePopToRoot;

@end

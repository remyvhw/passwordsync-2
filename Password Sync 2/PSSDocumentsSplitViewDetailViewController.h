//
//  PSSDocumentsSplitViewDetailViewController.h
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-08-04.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import "PSSSplitViewGenericDetailNavigationViewController.h"
#import "PSSDocumentBaseObject.h"

@interface PSSDocumentsSplitViewDetailViewController : PSSSplitViewGenericDetailNavigationViewController

-(void)presentViewControllerForDocumentEntity:(PSSDocumentBaseObject *)documentBaseObject;


@end

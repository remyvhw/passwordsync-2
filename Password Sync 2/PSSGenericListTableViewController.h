//
//  PSSGenericListTableViewController.h
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-08-18.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

@import UIKit;

@class PSSPasswordBaseObject;
@interface PSSGenericListTableViewController : UITableViewController

-(void)deselectAllRowsAnimated:(BOOL)animated;
-(void)selectRowForBaseObject:(PSSPasswordBaseObject *)baseObject;

@end

//
//  PSSDetailViewController.h
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-06-26.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import "SVProgressHUD.h"
#import "PSSGenericDetailViewController.h"

@interface PSSGenericDetailTableViewController : PSSGenericDetailViewController <UISplitViewControllerDelegate, UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate>

@property (strong, nonatomic) IBOutlet UITableView * tableView;

-(UIView*)lockedImageAccessoryView;
-(UIView*)copyImageAccessoryView;

@end

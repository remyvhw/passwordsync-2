//
//  PSSDetailViewController.h
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-06-26.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

@import UIKit;
#import "PSSObjectEditorProtocol.h"
#import "SVProgressHUD.h"


@interface PSSGenericDetailViewController : UIViewController <UISplitViewControllerDelegate, UITableViewDataSource, UITableViewDelegate, PSSObjectEditorProtocol, UIActionSheetDelegate>

@property (strong, nonatomic) id detailItem;
@property (strong, nonatomic) IBOutlet UITableView * tableView;
@property BOOL isPasscodeUnlocked;

-(void)showUnlockingViewController;
-(void)userDidUnlockWithPasscode;
-(void)editorAction:(id)sender;
-(void)lockUIAction:(id)notification;

-(UIView*)lockedImageAccessoryView;
-(UIView*)copyImageAccessoryView;

@end

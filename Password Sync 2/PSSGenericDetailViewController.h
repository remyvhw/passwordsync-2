//
//  PSSGenericDetailViewController.h
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-07-27.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

@import UIKit;
#import "PSSObjectEditorProtocol.h"
#import "PSSBaseGenericObject.h"

@interface PSSGenericDetailViewController : UIViewController <PSSObjectEditorProtocol, UISplitViewControllerDelegate>

@property (strong, nonatomic) PSSBaseGenericObject* detailItem;
@property BOOL isPasscodeUnlocked;

-(void)showUnlockingViewController;
-(void)userDidUnlockWithPasscode;
-(void)editorAction:(id)sender;
-(void)lockUIAction:(id)notification;
-(void)presentVersionsBrowser:(id)sender;

-(void)presentTagsBrowser:(id)sender;


-(void)toggleFavorite;


@end

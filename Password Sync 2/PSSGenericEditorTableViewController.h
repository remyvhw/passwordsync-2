//
//  PSSGenericEditorTableViewController.h
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-07-25.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PSSGenericEditorTableViewController : UITableViewController

@property (strong, nonatomic) id baseObject;

-(void)cancelAction:(id)sender;

@end

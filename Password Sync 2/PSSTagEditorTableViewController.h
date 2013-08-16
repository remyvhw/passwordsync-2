//
//  PSSTagEditorTableViewController.h
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-08-15.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSSObjectTag.h"
#import "PSSTagColorPickerViewController.h"

@interface PSSTagEditorTableViewController : UITableViewController <PSSTagColorPickerViewControllerDelegate>

@property (strong, nonatomic) PSSObjectTag * baseObject;

@end

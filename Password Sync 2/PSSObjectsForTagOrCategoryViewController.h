//
//  PSSObjectsForTagViewController.h
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-08-16.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSSObjectTag.h"
#import "PSSObjectFolder.h"

@interface PSSObjectsForTagOrCategoryViewController : UITableViewController

@property (strong, nonatomic) PSSObjectTag * selectedTag;
@property (strong, nonatomic) PSSObjectFolder * selectedFolder;

@end

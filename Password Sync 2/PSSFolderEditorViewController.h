//
//  PSSFolderEditorViewController.h
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-08-15.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSSObjectFolder.h"

@interface PSSFolderEditorViewController : UITableViewController

@property (strong, nonatomic) PSSObjectFolder *baseObject;
@property (strong, nonatomic) PSSObjectFolder *parentFolder;

@end

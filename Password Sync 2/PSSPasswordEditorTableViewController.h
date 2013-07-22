//
//  PSSPasswordEditorTableViewController.h
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-07-10.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSSPasswordGeneratorTableViewController.h"
#import "PSSObjectEditorProtocol.h"

@class PSSPasswordBaseObject;

@interface PSSPasswordEditorTableViewController : UITableViewController <PSSPasswordGeneratorTableViewControllerProtocol>

@property (strong) PSSPasswordBaseObject * passwordBaseObject;
@property (weak) id<PSSObjectEditorProtocol> editorDelegate;

@end

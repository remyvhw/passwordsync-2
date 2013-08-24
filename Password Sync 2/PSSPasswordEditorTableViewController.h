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
#import "PSSGenericEditorTableViewController.h"

@class PSSPasswordBaseObject;

@interface PSSPasswordEditorTableViewController : PSSGenericEditorTableViewController <PSSPasswordGeneratorTableViewControllerProtocol>

@property (strong, nonatomic) PSSPasswordBaseObject * baseObject;

@end

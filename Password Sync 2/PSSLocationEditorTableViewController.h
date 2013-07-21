//
//  PSSLocationEditorTableViewController.h
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-07-18.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSSLocationBaseObject.h"

@protocol PSSPasswordGeneratorTableViewControllerProtocol;

@interface PSSLocationEditorTableViewController : UITableViewController <PSSPasswordGeneratorTableViewControllerProtocol>

@property (strong, nonatomic) PSSLocationBaseObject * locationBaseObject;

@end

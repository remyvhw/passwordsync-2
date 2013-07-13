//
//  PSSPasswordGeneratorTableViewController.h
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-07-12.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PSSPasswordGeneratorTableViewControllerProtocol;

@interface PSSPasswordGeneratorTableViewController : UITableViewController

@property (strong) id<PSSPasswordGeneratorTableViewControllerProtocol> generatorDelegate;

@end

@protocol PSSPasswordGeneratorTableViewControllerProtocol

-(void)passwordGenerator:(PSSPasswordGeneratorTableViewController*)generator finishedWithPassword:(NSString*)randomPassword;

@end
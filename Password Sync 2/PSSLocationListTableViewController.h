//
//  PSSLocationListTableViewController.h
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-07-18.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

@import UIKit;
@import CoreData;
#import "PSSGenericListTableViewController.h"

@class PSSBaseGenericObject;
@interface PSSLocationListTableViewController : PSSGenericListTableViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;


@end

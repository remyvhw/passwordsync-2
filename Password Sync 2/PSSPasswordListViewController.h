//
//  PSSMasterViewController.h
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-06-26.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

@import UIKit;
@import CoreData;

@class PSSGenericDetailViewController;


@interface PSSPasswordListViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) PSSGenericDetailViewController *detailViewController;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end

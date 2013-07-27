//
//  PSSNotesListTableViewController.h
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-07-25.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

@import UIKit;
@import CoreData;
@class PSSGenericDetailTableViewController;

@interface PSSNotesListTableViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) PSSGenericDetailTableViewController *detailViewController;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end

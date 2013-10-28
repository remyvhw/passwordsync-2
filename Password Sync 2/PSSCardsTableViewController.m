//
//  PSSCardsTableViewController.m
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-07-13.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import "PSSCardsTableViewController.h"
#import "PSSCardEditorViewController.h"
#import "PSSAppDelegate.h"
#import "PSSCreditCardBaseObject.h"
#import "PSSCreditCardVersion.h"
#import "PSSCardDetailViewController.h"
#import "PSSCardsSplitViewDetailViewController.h"
#import "PSSUpgradePurchasesAppViewController.h"

@interface PSSCardsTableViewController ()

@end

@implementation PSSCardsTableViewController

-(void)deselectAllRowsAnimated:(BOOL)animated{
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:animated];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)newCardAction:(id)sender{
    
    if (APP_DELEGATE.shouldAllowNewData) {
            PSSCardEditorViewController * cardEditor = [[PSSCardEditorViewController alloc] initWithStyle:UITableViewStyleGrouped];
    UINavigationController * editorNavController = [[UINavigationController alloc] initWithRootViewController:cardEditor];
    [self.navigationController presentViewController:editorNavController animated:YES completion:^{}];

    } else {
        
        PSSUpgradePurchasesAppViewController * updateAppViewcontroller = [[PSSUpgradePurchasesAppViewController alloc] initWithNibName:@"PSSUpgradePurchasesAppViewController" bundle:[NSBundle mainBundle]];
        [self.navigationController pushViewController:updateAppViewcontroller animated:YES];
        
    }
    
    
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        self.navigationController.tabBarItem.selectedImage = [UIImage imageNamed:@"CardsIcon-Selected"];
    } else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.navigationController.parentViewController.tabBarItem.selectedImage = [UIImage imageNamed:@"CardsIcon-Selected"];
    }
    
    
    
    PSSAppDelegate *appDelegate = (PSSAppDelegate*)[[UIApplication sharedApplication] delegate];
    self.managedObjectContext = appDelegate.managedObjectContext;

    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        // Special iPhone stuff
        UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(newCardAction:)];
        
        self.navigationItem.rightBarButtonItem = addButton;
        
    } else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        
        [self setClearsSelectionOnViewWillAppear:NO];
    }

    
   

    
    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"cardDetailViewControllerSegue"]) {
        
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSManagedObject *object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        
        [[segue destinationViewController] setDetailItem:object];
        
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cardCell" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        
        [context performBlockAndWait:^{
            [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
            
            
            NSError *error = nil;
            if (![context save:&error]) {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                abort();
            }

        }];
    }
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // The table view should not be re-orderable.
    return NO;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        // On the iPad, we won't rely on a  segue to show the selected object in the detail view controller but, instead, intercept the tap and send the open detail view to the split view' detail navigation controller's child.
        // CardsList ↑ Splitview ↓ Detail view ↓ NavController
        
        PSSCardsSplitViewDetailViewController * detailController = (PSSCardsSplitViewDetailViewController*)[self.splitViewController.viewControllers lastObject];
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        PSSCreditCardBaseObject *object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        [detailController presentViewControllerForCardEntity:object];
        
    }
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"PSSCreditCardBaseObject" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"created" ascending:NO];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Cards"];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return _fetchedResultsController;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

/*
 // Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed.
 
 - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
 {
 // In the simplest, most efficient, case, reload the table view.
 [self.tableView reloadData];
 }
 */

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    PSSCreditCardBaseObject *object = (PSSCreditCardBaseObject*)[self.fetchedResultsController objectAtIndexPath:indexPath];
    
    NSString * cardNumber;
    if ([[object displayName] length] == 16) {
        cardNumber = [NSString stringWithFormat:@"•••• •••• •••• %@", [object.displayName stringByReplacingOccurrencesOfString:@"•" withString:@""]];
    } else {
        // Not a credit card
        cardNumber = object.displayName;
    }
    
    cell.textLabel.font = [UIFont fontWithName:@"OCRA" size:15.];
    
    cell.textLabel.text = cardNumber;
    if (!object.cardName || [object.cardName isEqualToString:@""]) {
        cell.detailTextLabel.text = NSLocalizedString(@"Other", nil);
    } else {
        cell.detailTextLabel.text = object.cardName;
    }
    
    
}


@end

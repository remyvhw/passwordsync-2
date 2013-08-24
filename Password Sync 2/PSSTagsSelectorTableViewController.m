//
//  PSSTagsSelectorTableViewController.m
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-08-16.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import "PSSTagsSelectorTableViewController.h"
#import "PSSObjectTag.h"
#import "PSSAppDelegate.h"
#import "UIColor+PSSDictionaryCoding.h"
#import "PSSObjectsForTagOrCategoryViewController.h"

@interface PSSTagsSelectorTableViewController ()

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSFetchedResultsController *searchFetchedResultsController;
@property (nonatomic, retain) NSArray * arrayOfArrangedTabObjects;

@end

@implementation PSSTagsSelectorTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    if (self.detailItem && self.editionMode) {
        self.selectionSet = [[NSMutableSet alloc] initWithSet:self.detailItem.tags];
    } else if (self.editionMode) {
        self.selectionSet = [[NSMutableSet alloc] init];
    } else {
        NSSortDescriptor * sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"position" ascending:YES];
        NSArray * arrayOfTags = [self.detailItem.tags sortedArrayUsingDescriptors:@[sortDescriptor]];
        self.arrayOfArrangedTabObjects = arrayOfTags;
    }
    
    
    
    self.title = NSLocalizedString(@"Tags", nil);
    
    self.managedObjectContext = APP_DELEGATE.managedObjectContext;
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"tagCell"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillDisappear:(BOOL)animated{
    if (self.tagsSelectorDelegate) {
        [self.tagsSelectorDelegate tagsSelector:self didFinishWithSelection:self.selectionSet];
    };
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (!self.editionMode) {
        return 1;
    }
    
    NSInteger count = [[[self fetchedResultsControllerForTableView:tableView] sections] count];
    
    return count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (!self.editionMode) {
        return [self.arrayOfArrangedTabObjects count];
    }
    
    NSInteger numberOfRows = 0;
    NSFetchedResultsController *fetchController = [self fetchedResultsControllerForTableView:tableView];
    NSArray *sections = fetchController.sections;
    if(sections.count > 0)
    {
        id <NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:section];
        numberOfRows = [sectionInfo numberOfObjects];
    }
    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell;
    cell = [self.tableView dequeueReusableCellWithIdentifier:@"tagCell" forIndexPath:indexPath];
    
    [self configureCell:cell atIndexPath:indexPath forTableView:tableView];
    
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath forTableView:(UITableView*)tableView
{
    PSSObjectTag *object;
    // Configure tags cells
    if (self.editionMode) {
        object = (PSSObjectTag*)[[self fetchedResultsControllerForTableView:tableView] objectAtIndexPath:indexPath];
    } else {
        object = (PSSObjectTag*)[self.arrayOfArrangedTabObjects objectAtIndex:indexPath.row];
    }
    
    
    cell.textLabel.text = object.name;
    cell.imageView.image = [UIColor imageWithColorDictionary:object.color];
    
    CALayer *mask = [CALayer layer];
    mask.contents = (id)[[UIImage imageNamed:@"TableViewSquircleMask"] CGImage];
    mask.frame = CGRectMake(0, 0, 40, 40);
    
    cell.imageView.layer.mask = mask;
    cell.imageView.layer.masksToBounds = YES;
    
    if (self.editionMode) {
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        // In edition mode, we'll add a checkmark next to the selected objects
        
        if ([self.selectionSet containsObject:object]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        
        
        
    }
    
    
}

#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PSSObjectTag * selectedTag = [[self fetchedResultsControllerForTableView:tableView] objectAtIndexPath:indexPath];
    
    if (self.editionMode) {
        
        if ([self.selectionSet containsObject:selectedTag]) {
            // Object is in newly selected set already, remove it
            
            [self.selectionSet removeObject:selectedTag];
            
        } else {
            // Add object to newly selected set
            
            [self.selectionSet addObject:selectedTag];
            
        }
        
        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
    } else {
        
        // Not in edition mode
        
        UIStoryboard * mainStoryboard;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            mainStoryboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:[NSBundle mainBundle]];
        } else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            mainStoryboard = [UIStoryboard storyboardWithName:@"Main_iPad" bundle:[NSBundle mainBundle]];
        }
        
        
        PSSObjectsForTagOrCategoryViewController * objectsForTagViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"objectsForTagControllerSegue"];
        
        objectsForTagViewController.selectedTag = selectedTag;
        
        [self.navigationController pushViewController:objectsForTagViewController animated:YES];
        
        
    }
    
    
    
}
 

#pragma mark - NSFetchedResultsController

- (NSFetchedResultsController *)searchFetchedResultsController
{
    if (_searchFetchedResultsController != nil) {
        return _searchFetchedResultsController;
    }
    
    
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity;
   
    entity = [NSEntityDescription entityForName:@"PSSObjectTag" inManagedObjectContext:self.managedObjectContext];
    
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptor];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    
    NSString * searchString = self.searchDisplayController.searchBar.text;
    if(searchString.length)
    {
        // your search predicate(s) are added to this array
        if (self.editionMode) {
            [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"name contains[cd] %@", searchString]];
        } else {
            [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"(SELF IN %@) AND (name contains[cd] %@)", self.detailItem.tags, searchString]];
        }
        
    }
    
    
    
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    aFetchedResultsController.delegate = self;
    _searchFetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![_searchFetchedResultsController performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	}
    
    
    return _searchFetchedResultsController;
}

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"PSSObjectTag" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"position" ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Tags"];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![aFetchedResultsController performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return _fetchedResultsController;
}


- (NSFetchedResultsController *)fetchedResultsControllerForTableView:(UITableView *)tableView
{
    // Which fetch results controller to use?
    return tableView == self.tableView ? self.fetchedResultsController : self.searchFetchedResultsController;
}

#pragma mark Delegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    UITableView *tableView = controller == self.fetchedResultsController ? self.tableView : self.searchDisplayController.searchResultsTableView;
    [tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    UITableView *tableView = controller == self.fetchedResultsController ? self.tableView : self.searchDisplayController.searchResultsTableView;
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = controller == self.fetchedResultsController ? self.tableView : self.searchDisplayController.searchResultsTableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath forTableView:tableView];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    UITableView *tableView = controller == self.fetchedResultsController ? self.tableView : self.searchDisplayController.searchResultsTableView;
    [tableView endUpdates];
}






#pragma mark - Content Filtering
- (void)filterContentForSearchText:(NSString*)searchText scope:(NSInteger)scope
{
    // update the filter, in this case just blow away the FRC and let lazy evaluation create another with the relevant search info
    self.searchFetchedResultsController.delegate = nil;
    self.searchFetchedResultsController = nil;
    // if you care about the scope save off the index to be used by the serchFetchedResultsController
    self.savedScopeButtonIndex = scope;
}

#pragma mark -
#pragma mark Search Bar

-(void)searchDisplayController:(UISearchDisplayController *)controller willHideSearchResultsTableView:(UITableView *)tableView{
    [self.tableView reloadData];
}

- (void)searchDisplayController:(UISearchDisplayController *)controller willUnloadSearchResultsTableView:(UITableView *)tableView;
{
    // search is done so get rid of the search FRC and reclaim memory
    self.searchFetchedResultsController.delegate = nil;
    self.searchFetchedResultsController = nil;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString
                               scope:[self.searchDisplayController.searchBar selectedScopeButtonIndex]];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    [self filterContentForSearchText:[self.searchDisplayController.searchBar text]
                               scope:[self.searchDisplayController.searchBar selectedScopeButtonIndex]];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}


@end

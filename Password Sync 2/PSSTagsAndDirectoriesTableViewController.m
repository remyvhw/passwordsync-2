//
//  PSSTagsAndDirectoriesTableViewController.m
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-08-14.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import "PSSTagsAndDirectoriesTableViewController.h"
#import "PSSUnlockPromptViewController.h"
#import "PSSObjectTag.h"
#import "PSSObjectFolder.h"
#import "PSSAppDelegate.h"
#import "UIColor+PSSDictionaryCoding.h"

typedef enum {
    PSSTagsAndDirectoriesPresentationModeTags,
    PSSTagsAndDirectoriesPresentationModeFolders
} PSSTagsAndDirectoriesPresentationMode;

@interface PSSTagsAndDirectoriesTableViewController ()
@property (weak, nonatomic) IBOutlet UISegmentedControl *tagsFoldersSegmentedControl;
@property (strong, nonatomic) NSFetchedResultsController *tagsFetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSFetchedResultsController * foldersFetchedResultsController;
@property (nonatomic, strong) NSFetchedResultsController *searchFetchedResultsController;

@property (nonatomic) PSSTagsAndDirectoriesPresentationMode presentationMode;
- (IBAction)segmentedControlToggle:(UISegmentedControl *)sender;



@end

@implementation PSSTagsAndDirectoriesTableViewController




-(void)setEditing:(BOOL)editing animated:(BOOL)animated{
    [super setEditing:editing animated:animated];
    
    if (editing) {
        [self showNewButtonAnimated:YES];
        [UIView animateWithDuration:0.2 animations:^{
            [self.tagsFoldersSegmentedControl setAlpha:0.0];
        } completion:^(BOOL finished) {
            [self.tagsFoldersSegmentedControl setHidden:YES];
        }];
    } else {
        [self.tagsFoldersSegmentedControl setHidden:NO];
        [UIView animateWithDuration:0.2 animations:^{
            [self.tagsFoldersSegmentedControl setAlpha:1.0];
        }];
        [self showSettingsButtonAnimated:YES];
    }
    
}

-(void)showNewButtonAnimated:(BOOL)animated{
    UIBarButtonItem * newButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addAction:)];
    [self.navigationItem setLeftBarButtonItem:newButton animated:animated];
}

-(void)showSettingsButtonAnimated:(BOOL)animated{
    UIBarButtonItem * settingsButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Settings", nil) style:UIBarButtonItemStylePlain target:self action:@selector(presentSettingsViewAction:)];
    
    
    
    [self.navigationItem setLeftBarButtonItem:settingsButton animated:animated];
}


- (IBAction)segmentedControlToggle:(UISegmentedControl *)sender {
    
    PSSTagsAndDirectoriesPresentationMode newPresentationMode;
    if (sender.selectedSegmentIndex == 0) {
        
        newPresentationMode = PSSTagsAndDirectoriesPresentationModeTags;
        
    } else {
        newPresentationMode = PSSTagsAndDirectoriesPresentationModeFolders;
    }
    
    if (self.presentationMode == newPresentationMode) {
        // User tapped on the already selected segment.
        return;
    }
    
    self.presentationMode = newPresentationMode;
    
    
    [UIView animateWithDuration:0.2 animations:^{
        [self.tableView setAlpha:0.0];
    } completion:^(BOOL finished) {
        [self.tableView reloadData];
        
        [UIView animateWithDuration:0.2 animations:^{
            [self.tableView setAlpha:1.0];
        }];
        
    }];
    
    
}

-(void)addAction:(id)sender{
    
    if (self.presentationMode == PSSTagsAndDirectoriesPresentationModeTags) {
        // New tags
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            [self performSegueWithIdentifier:@"presentNewTagEditorSegue" sender:self];
        }
        
        
    }
    
    
    
}

-(void)presentSettingsViewAction:(id)sender{
    
    UIStoryboard * unlockStoryboard = [UIStoryboard storyboardWithName:@"UnlockPrompt" bundle:[NSBundle mainBundle]];
    PSSUnlockPromptViewController * unlockController = (PSSUnlockPromptViewController*)[unlockStoryboard instantiateInitialViewController];
    
    [self.navigationController presentViewController:[unlockController promptForPasscodeBlockingView:NO completion:^{
        // We only run the refresh if the UI was locked to prevent double reloads
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            
        } else {
            [self performSegueWithIdentifier:@"showSettingsSegue" sender:self];
        }
        
        
    } cancelation:^{
        
    }] animated:YES completion:^{
        
    }];

    
    
}

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

    userDrivenDataModelChange = NO;
    self.managedObjectContext = APP_DELEGATE.managedObjectContext;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self showSettingsButtonAnimated:NO];
    
    
    self.presentationMode = PSSTagsAndDirectoriesPresentationModeTags;
    
    if (self.savedSearchTerm)
    {
        [self.searchDisplayController setActive:self.searchWasActive];
        [self.searchDisplayController.searchBar setSelectedScopeButtonIndex:self.savedScopeButtonIndex];
        [self.searchDisplayController.searchBar setText:self.savedSearchTerm];
        
        self.savedSearchTerm = nil;
    }
    
    
    
    
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    // save the state of the search UI so that it can be restored if the view is re-created
    self.searchWasActive = [self.searchDisplayController isActive];
    self.savedSearchTerm = [self.searchDisplayController.searchBar text];
    self.savedScopeButtonIndex = [self.searchDisplayController.searchBar selectedScopeButtonIndex];
}

- (void)didReceiveMemoryWarning
{
    
    self.searchWasActive = [self.searchDisplayController isActive];
    self.savedSearchTerm = [self.searchDisplayController.searchBar text];
    self.savedScopeButtonIndex = [self.searchDisplayController.searchBar selectedScopeButtonIndex];
    
    _searchFetchedResultsController = nil;

    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    if (tableView == self.tableView) {
        return YES;
    }
    return NO;
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        
        
        NSManagedObjectContext *context = self.managedObjectContext;
        if (self.presentationMode == PSSTagsAndDirectoriesPresentationModeTags) {
            [context deleteObject:[self.tagsFetchedResultsController objectAtIndexPath:indexPath]];
        }
        
        NSError *error = nil;
        if (![context save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            
            abort();
        }
        
        
        
        
    }   

}



// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    // Prevent changes to call our NSFetchedResultsControllerDelegate methods
    userDrivenDataModelChange = YES;
    
    NSMutableArray * newOrderedArray = [NSMutableArray arrayWithArray:self.tagsFetchedResultsController.fetchedObjects];
    
    [newOrderedArray removeObjectAtIndex:fromIndexPath.row];
    [newOrderedArray insertObject:[self.tagsFetchedResultsController objectAtIndexPath:fromIndexPath] atIndex:toIndexPath.row];
    
    for (PSSObjectTag * tag in self.tagsFetchedResultsController.fetchedObjects) {
        
        tag.position = [NSNumber numberWithInteger:[newOrderedArray indexOfObject:tag]];
        
        
    }
    
    [self.managedObjectContext save:NULL];
    
    
    
    userDrivenDataModelChange = NO;
}



- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.presentationMode == PSSTagsAndDirectoriesPresentationModeTags) {
        return YES;
    }
    // We cannot reorder folders
    return NO;
}


#pragma mark - UITableViewDelegate


/*-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
  
}*/


/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */



#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger count = [[[self fetchedResultsControllerForTableView:tableView] sections] count];
    
    return count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
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
    if (self.presentationMode == PSSTagsAndDirectoriesPresentationModeTags) {
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"tagCell" forIndexPath:indexPath];
        
    } else {
        // Folder Cell
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"folderCell" forIndexPath:indexPath];
    }
    
    [self configureCell:cell atIndexPath:indexPath tableView:tableView];
    
    return cell;
}



#pragma mark - Fetched results controllers

- (NSFetchedResultsController *)fetchedResultsControllerForTableView:(UITableView *)tableView
{
    // Which fetch results controller to use?
    
    if (tableView == self.tableView) {
        if (self.presentationMode == PSSTagsAndDirectoriesPresentationModeTags) {
            return self.tagsFetchedResultsController;
        } else if (self.presentationMode == PSSTagsAndDirectoriesPresentationModeFolders){
            return self.foldersFetchedResultsController;
        }
    } else {
        return self.searchFetchedResultsController;
    }
    
    return nil;
}





- (NSFetchedResultsController *)searchFetchedResultsController
{
    if (_searchFetchedResultsController != nil) {
        return _searchFetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity;
    if (self.presentationMode==PSSTagsAndDirectoriesPresentationModeTags) {
        entity = [NSEntityDescription entityForName:@"PSSObjectTag" inManagedObjectContext:self.managedObjectContext];
    } else {
        entity = [NSEntityDescription entityForName:@"PSSObjectFolder" inManagedObjectContext:self.managedObjectContext];
    }

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
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"name contains[cd] %@", searchString]];
        
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

- (NSFetchedResultsController *)tagsFetchedResultsController
{
    if (_tagsFetchedResultsController != nil) {
        return _tagsFetchedResultsController;
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
    self.tagsFetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![aFetchedResultsController performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return _tagsFetchedResultsController;
}

- (NSFetchedResultsController *)foldersFetchedResultsController
{
    if (_foldersFetchedResultsController != nil) {
        return _foldersFetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"PSSObjectFolder" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Folders"];
    aFetchedResultsController.delegate = self;
    self.foldersFetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![aFetchedResultsController performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return _foldersFetchedResultsController;
}

#pragma mark Delegate methods

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    if (userDrivenDataModelChange) {
        return;
    }
    
    if ((controller == self.tagsFetchedResultsController && self.presentationMode != PSSTagsAndDirectoriesPresentationModeTags) || (controller == self.foldersFetchedResultsController && self.presentationMode != PSSTagsAndDirectoriesPresentationModeFolders)) {
        // The currently displayed table view is NOT the one we're interested in
        return;
    }
    
    UITableView *tableView = controller == self.searchFetchedResultsController ? self.searchDisplayController.searchResultsTableView : self.tableView;
    [tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    if (userDrivenDataModelChange) {
        return;
    }
    
    if ((controller == self.tagsFetchedResultsController && self.presentationMode != PSSTagsAndDirectoriesPresentationModeTags) || (controller == self.foldersFetchedResultsController && self.presentationMode != PSSTagsAndDirectoriesPresentationModeFolders)) {
        // The currently displayed table view is NOT the one we're interested in
        return;
    }
    
    UITableView *tableView = controller == self.searchFetchedResultsController ? self.searchDisplayController.searchResultsTableView : self.tableView;
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
    
    if (userDrivenDataModelChange) {
        return;
    }
    
    if ((controller == self.tagsFetchedResultsController && self.presentationMode != PSSTagsAndDirectoriesPresentationModeTags) || (controller == self.foldersFetchedResultsController && self.presentationMode != PSSTagsAndDirectoriesPresentationModeFolders)) {
        // The currently displayed table view is NOT the one we're interested in
        return;
    }
    
    UITableView *tableView = controller == self.searchFetchedResultsController ? self.searchDisplayController.searchResultsTableView : self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath tableView:tableView];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    if (userDrivenDataModelChange) {
        return;
    }
    
    if ((controller == self.tagsFetchedResultsController && self.presentationMode != PSSTagsAndDirectoriesPresentationModeTags) || (controller == self.foldersFetchedResultsController && self.presentationMode != PSSTagsAndDirectoriesPresentationModeFolders)) {
        // The currently displayed table view is NOT the one we're interested in
        return;
    }
    
    UITableView *tableView = controller == self.searchFetchedResultsController ? self.searchDisplayController.searchResultsTableView : self.tableView;
    [tableView endUpdates];
}





- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath tableView:(UITableView*)tableView
{
    
    NSFetchedResultsController * controller;
    
    if (tableView == self.tableView && self.presentationMode == PSSTagsAndDirectoriesPresentationModeTags) {
        controller = self.tagsFetchedResultsController;
    } else if (tableView == self.tableView && self.presentationMode == PSSTagsAndDirectoriesPresentationModeFolders) {
        controller = self.foldersFetchedResultsController;
    } else {
        controller = self.searchFetchedResultsController;
    }
    
    
    if (self.presentationMode == PSSTagsAndDirectoriesPresentationModeTags) {
        // Configure tags cells
        PSSObjectTag *object = (PSSObjectTag*)[controller objectAtIndexPath:indexPath];

        cell.textLabel.text = object.name;
        cell.imageView.image = [UIColor imageWithColorDictionary:object.color];
        
    } else if (self.presentationMode == PSSTagsAndDirectoriesPresentationModeFolders) {
        // Configure a folder cell
        PSSObjectFolder *object = (PSSObjectFolder*)[controller objectAtIndexPath:indexPath];
        
        cell.textLabel.text = object.name;
        
    }
    
    
    
    
    
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

//
//  PSSMasterViewController.m
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-06-26.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import "PSSPasswordListViewController.h"
#import "PSSPasswordEditorTableViewController.h"
#import "PSSPasswordBaseObject.h"
#import "PSSPasswordDomain.h"
#import "PSSPasswordDetailViewController.h"
#import "PSSPasswordSplitViewDetailViewController.h"
#import "SLColorArt.h"
#import "UIImage+ImageEffects.h"
#import "PSSDeviceCapacity.h"
#import "PSSAppDelegate.h"
#import "PSSUpgradePurchasesAppViewController.h"

@interface PSSPasswordListViewController ()
@property (nonatomic, strong) NSFetchedResultsController *searchFetchedResultsController;

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@end

@implementation PSSPasswordListViewController
@synthesize searchFetchedResultsController = _searchFetchedResultsController;
dispatch_queue_t backgroundQueue;



-(void)userUnlockedDatabase:(id)sender{
    
    [self.tableView reloadData];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    
    self.managedObjectContext = APP_DELEGATE.managedObjectContext;
    
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        self.navigationController.tabBarItem.selectedImage = [UIImage imageNamed:@"Browser-Selected"];
    } else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.navigationController.parentViewController.tabBarItem.selectedImage = [UIImage imageNamed:@"Browser-Selected"];
    }
    
    backgroundQueue = dispatch_queue_create([[NSString stringWithFormat:@"%@.WebsitesTableViewImageRenderingThread", [[NSBundle mainBundle] bundleIdentifier]] cStringUsingEncoding:NSUTF8StringEncoding], NULL);
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        // Special iPhone stuff
        UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
        
        self.navigationItem.rightBarButtonItem = addButton;
        
    } else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        
        [self setClearsSelectionOnViewWillAppear:NO];
        
        // Set the search bar as a top navigation bar view
        //self.searchDisplayController.displaysSearchBarInNavigationBar = YES;
    }
    
    
    // Register to unlock notification so we can replace the "dots" on the username field.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userUnlockedDatabase:) name:PSSGlobalUnlockNotification object:nil];
    
    // Register search cell
    [self.tableView registerNib:[UINib nibWithNibName:@"PSSPasswordListSearchResultCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"SearchPasswordCell"];
    
    
    // Restore search view in case of a memory warning clearing the view
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

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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



- (void)insertNewObject:(id)sender
{
    
    if (!APP_DELEGATE.shouldAllowNewData) {
        
        PSSUpgradePurchasesAppViewController * updateAppViewcontroller = [[PSSUpgradePurchasesAppViewController alloc] initWithNibName:@"PSSUpgradePurchasesAppViewController" bundle:[NSBundle mainBundle]];
        [self.navigationController pushViewController:updateAppViewcontroller animated:YES];
        return;
    }
    
    UIStoryboard * storyboardContainingEditor = [UIStoryboard storyboardWithName:@"PSSNewPasswordObjectStoryboard_iPhone" bundle:[NSBundle mainBundle]];
    UINavigationController * passwordEditorNavController = [storyboardContainingEditor instantiateInitialViewController];
    [self.navigationController presentViewController:passwordEditorNavController animated:YES completion:^{
        
    }];
    
    
    
}

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
    if (tableView == self.tableView) {
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"PasswordCell" forIndexPath:indexPath];
        [self configureCell:cell atIndexPath:indexPath];
    } else {
        // Search Table View
        
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"SearchPasswordCell" forIndexPath:indexPath];
        [self configureSearchCell:cell atIndexPath:indexPath];
        
    }

    
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
        if ([self.fetchedResultsController objectAtIndexPath:indexPath]) {
            [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
        }
        
        
        
        [context performBlockAndWait:^{
            NSError *error = nil;
            if (![context save:&error]) {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"An Error Occured", nil) message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
                [alertView show];
            }
        }];
    }
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // The table view should not be re-orderable.
    return NO;
}



- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"passwordDetailViewControllerSegue"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        PSSBaseGenericObject *object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        [[segue destinationViewController] setDetailItem:object];
    }
}

#pragma mark - Fetched results controllers

- (NSFetchedResultsController *)fetchedResultsControllerForTableView:(UITableView *)tableView
{
    // Which fetch results controller to use?
    return tableView == self.tableView ? self.fetchedResultsController : self.searchFetchedResultsController;
}





- (NSFetchedResultsController *)searchFetchedResultsController
{
    if (_searchFetchedResultsController != nil) {
        return _searchFetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"PSSPasswordBaseObject" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"displayName" ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptor];
    [fetchRequest setSortDescriptors:sortDescriptors];


    NSString * searchString = self.searchDisplayController.searchBar.text;
    if(searchString.length)
    {
        // your search predicate(s) are added to this array
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"(displayName contains[cd] %@) OR (ANY domains.hostname contains[cd] %@)", searchString, searchString]];
        
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
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"PSSPasswordBaseObject" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"displayName" ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Passwords"];
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
    UITableView *tableView = controller == self.fetchedResultsController ? self.tableView : self.searchDisplayController.searchResultsTableView;
    [tableView endUpdates];
}



-(void)configureSearchCell:(UITableViewCell*)cell atIndexPath:(NSIndexPath*)indexPath{
    
    
    
    PSSPasswordBaseObject *object = (PSSPasswordBaseObject*)[self.searchFetchedResultsController objectAtIndexPath:indexPath];
    
    NSMutableAttributedString * attributedTitle = [[NSMutableAttributedString alloc] initWithString:object.displayName];
    [attributedTitle addAttribute:NSBackgroundColorAttributeName value:[UIColor yellowColor] range:[object.displayName rangeOfString:self.searchDisplayController.searchBar.text options:NSCaseInsensitiveSearch]];
    cell.textLabel.attributedText = attributedTitle;
    
    if (object.mainDomain.hostname) {
        NSMutableAttributedString * attributedDomain = [[NSMutableAttributedString alloc] initWithString:object.mainDomain.hostname];
        [attributedDomain addAttribute:NSBackgroundColorAttributeName value:[UIColor yellowColor] range:[object.mainDomain.hostname rangeOfString:self.searchDisplayController.searchBar.text options:NSCaseInsensitiveSearch]];
        cell.detailTextLabel.attributedText = attributedDomain;
    }
    
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    
    PSSPasswordBaseObject *object = (PSSPasswordBaseObject*)[self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = object.displayName;
    
    
    UIImage * favicon = [UIImage imageWithData:object.favicon];
    
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    cell.imageView.image = [UIImage imageNamed:@"WebsiteSmallPlaceholder"];
    cell.contentView.layer.backgroundColor = [UIColor whiteColor].CGColor;
    cell.backgroundColor = [UIColor whiteColor];
    cell.backgroundView.layer.backgroundColor = [UIColor whiteColor].CGColor;
    cell.textLabel.textColor = [UIColor darkTextColor];
    cell.detailTextLabel.textColor = [UIColor darkGrayColor];
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.detailTextLabel.backgroundColor = [UIColor clearColor];
    
    
    if (favicon) {
        if ([PSSDeviceCapacity shouldRunAdvancedFeatures]) {
            cell.alpha = 0.1;
            dispatch_async(backgroundQueue, ^(void) {
                
                
                // Replace any transparency in the favicon by white so we don't end up with black cells (unless we have a black favicon)
                UIImage *bottomImage = [UIImage imageNamed:@"WhiteOpaque"];
                UIImage *topImage = favicon;
                
                CGSize newSize = CGSizeMake(topImage.size.width, topImage.size.height);
                UIGraphicsBeginImageContext( newSize );
                
                // Use existing opacity as is
                [bottomImage drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
                // Apply supplied opacity
                [topImage drawInRect:CGRectMake(0,0,newSize.width,newSize.height) blendMode:kCGBlendModeNormal alpha:1.0];
                
                UIImage *nonTransparentFavicon = UIGraphicsGetImageFromCurrentImageContext();
                
                UIGraphicsEndImageContext();
                
                
                
                SLColorArt *colorArt;
                
                CGFloat squareLenght = 40 * [[UIScreen mainScreen] scale];
                
                colorArt = [[SLColorArt alloc] initWithImage:nonTransparentFavicon scaledSize:CGSizeMake(squareLenght, squareLenght)];
                
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    if (favicon.size.height<39 || favicon.size.width<39) {
                        
                    } else {
                        UIImage * scaledImage = colorArt.scaledImage;;
                        cell.imageView.image = scaledImage;
                    }
                    cell.backgroundColor = colorArt.backgroundColor;
                    cell.contentView.backgroundColor = colorArt.backgroundColor;
                    cell.detailTextLabel.textColor = colorArt.secondaryColor;
                    cell.textLabel.textColor = colorArt.primaryColor;

                    [UIView animateWithDuration:0.7 animations:^{
                        
                        cell.contentView.layer.backgroundColor = colorArt.backgroundColor.CGColor;
                        cell.backgroundView.layer.backgroundColor = colorArt.backgroundColor.CGColor;
                        
                        
                        cell.alpha = 1.0;
                    } completion:^(BOOL finished) {
                        
                    }];
                    
                    
                });
                
            });
            // End of background thread
        } else {
            // iPhone 4 or other single cpu device; just set the favicon
            
            cell.imageView.image = favicon;
        }

        
        
        
        
    }

    


}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSFetchedResultsController * fetchedResultsController = [self fetchedResultsControllerForTableView:tableView];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        // On the iPad, we won't rely on a  segue to show the selected object in the detail view controller but, instead, intercept the tap and send the open detail view to the split view' detail navigation controller's child.
        // PSSPasswordListViewController ↑ Splitview ↓ Detail view ↓ NavController
        
        PSSPasswordSplitViewDetailViewController * detailController = (PSSPasswordSplitViewDetailViewController*)[self.splitViewController.viewControllers lastObject];
        PSSPasswordBaseObject *object = [fetchedResultsController objectAtIndexPath:indexPath];
        [detailController presentViewControllerForPasswordEntity:object];
        
    } else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        
        if (tableView == self.searchDisplayController.searchResultsTableView) {
            
            PSSPasswordDetailViewController * detailViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PSSPasswordDetailViewController"];
            
            detailViewController.detailItem = [fetchedResultsController objectAtIndexPath:indexPath];
            
            [self.navigationController pushViewController:detailViewController animated:YES];
            
            
        }
        
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

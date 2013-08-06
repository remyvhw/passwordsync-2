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
#import "PSSPasswordVersion.h"
#import "PSSPasswordDetailViewController.h"
#import "PSSPasswordSplitViewDetailViewController.h"
#import "SLColorArt.h"
#import "UIImage+ImageEffects.h"

@interface PSSPasswordListViewController ()
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@end

@implementation PSSPasswordListViewController
dispatch_queue_t backgroundQueue;

-(void)deselectAllRowsAnimated:(BOOL)animated{
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:animated];
}

-(void)userUnlockedDatabase:(id)sender{
    
    [self.tableView reloadData];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    backgroundQueue = dispatch_queue_create([[NSString stringWithFormat:@"%@.WebsitesTableViewImageRenderingThread", [[NSBundle mainBundle] bundleIdentifier]] cStringUsingEncoding:NSUTF8StringEncoding], NULL);
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        // Special iPhone stuff
        UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
        
        self.navigationItem.rightBarButtonItem = addButton;
        
    } else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        
        [self setClearsSelectionOnViewWillAppear:NO];
    }
    
    
    // Register to unlock notification so we can replace the "dots" on the username field.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userUnlockedDatabase:) name:PSSGlobalUnlockNotification object:nil];
    
    
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)insertNewObject:(id)sender
{
    
    UIStoryboard * storyboardContainingEditor = [UIStoryboard storyboardWithName:@"PSSNewPasswordObjectStoryboard_iPhone" bundle:[NSBundle mainBundle]];
    UINavigationController * passwordEditorNavController = [storyboardContainingEditor instantiateInitialViewController];
    [self.navigationController presentViewController:passwordEditorNavController animated:YES completion:^{
        
    }];
    
    
    
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PasswordCell" forIndexPath:indexPath];
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
        [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
        
        NSError *error = nil;
        if (![context save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }   
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // The table view should not be re-orderable.
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        // On the iPad, we won't rely on a  segue to show the selected object in the detail view controller but, instead, intercept the tap and send the open detail view to the split view' detail navigation controller's child.
        // PSSPasswordListViewController ↑ Splitview ↓ Detail view ↓ NavController
        
        PSSPasswordSplitViewDetailViewController * detailController = (PSSPasswordSplitViewDetailViewController*)[self.splitViewController.viewControllers lastObject];
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        PSSPasswordBaseObject *object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        [detailController presentViewControllerForPasswordEntity:object];
        
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"passwordDetailViewControllerSegue"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSManagedObject *object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        [[segue destinationViewController] setDetailItem:object];
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
    PSSPasswordBaseObject *object = (PSSPasswordBaseObject*)[self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = object.displayName;
    
    
    UIImage * favicon = [UIImage imageWithData:object.favicon];
    
    
    
    //cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Disclosure"]];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.imageView.image = [UIImage imageNamed:@"WebsiteSmallPlaceholder"];
    cell.contentView.layer.backgroundColor = [UIColor whiteColor].CGColor;
    cell.backgroundColor = [UIColor whiteColor];
    cell.backgroundColor = [UIColor whiteColor];
    cell.textLabel.textColor = [UIColor darkTextColor];
    cell.detailTextLabel.textColor = [UIColor darkGrayColor];
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.detailTextLabel.backgroundColor = [UIColor clearColor];
    
    if (favicon) {
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
            colorArt = [[SLColorArt alloc] initWithImage:nonTransparentFavicon scaledSize:CGSizeMake(40., 40.)];

            dispatch_async(dispatch_get_main_queue(), ^(void) {
                if (favicon.size.height<39 || favicon.size.width<39) {
                    
                } else {
                    UIImage * scaledImage = colorArt.scaledImage;;
                    cell.imageView.image = scaledImage;
                }
                
                [UIView animateWithDuration:0.07 animations:^{
                    
                    cell.contentView.layer.backgroundColor = colorArt.backgroundColor.CGColor;
                    
                    cell.textLabel.textColor = colorArt.primaryColor;
                    
                    cell.detailTextLabel.textColor = colorArt.secondaryColor;

                } completion:^(BOOL finished) {
                    cell.backgroundColor = colorArt.backgroundColor;
                    cell.contentView.backgroundColor = colorArt.backgroundColor;
                }];
                
                
            });
            
        });
        
        
        
        
    }

    


}

@end

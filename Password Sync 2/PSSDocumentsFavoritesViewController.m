//
//  PSSDocumentsFavoritesViewController.m
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-08-04.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import "PSSDocumentsFavoritesViewController.h"
#import "PSSDocumentEditorTableViewController.h"
#import "PSSDocumentListTableViewController.h"
#import "PSSAppDelegate.h"
#import "PSSDocumentBaseObject.h"
#import "PSSDocumentVersion.h"
#import "PSSDocumentsSplitViewDetailViewController.h"

@interface PSSDocumentsFavoritesViewController ()
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property BOOL isPasscodeUnlocked;

@end

@implementation PSSDocumentsFavoritesViewController
dispatch_queue_t backgroundQueue;

-(void)lockUIAction:(id)notification{
    
    
    self.isPasscodeUnlocked = NO;
    [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
}

-(void)unlockUIAction:(id)notification{
    self.isPasscodeUnlocked = YES;
    [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
}

- (void)insertNewObject:(id)sender {
    
    PSSDocumentEditorTableViewController * notesEditor = [[PSSDocumentEditorTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    UINavigationController * navController = [[UINavigationController alloc] initWithRootViewController:notesEditor];
    
    navController.modalPresentationStyle = UIModalPresentationFormSheet;
    [self.navigationController presentViewController:navController animated:YES completion:NULL];
    
}



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    backgroundQueue = dispatch_queue_create("com.pumaxprod.iOS.PasswordSync-2.favoriteDocumentCollectionViewBackgroundThread", NULL);

    
    PSSAppDelegate * appDelegate = (PSSAppDelegate*)[[UIApplication sharedApplication] delegate];
    self.managedObjectContext = appDelegate.managedObjectContext;
    
    if (appDelegate.isUnlocked) {
        self.isPasscodeUnlocked = YES;
    }
    
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
        
        self.navigationItem.rightBarButtonItem = addButton;
        
    }
    
    // Subscribe to the lock notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(lockUIAction:) name:PSSGlobalLockNotification object:nil];
    
    // Subscribe to unlock notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(unlockUIAction:) name:PSSGlobalUnlockNotification object:nil];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        UINavigationController * masterNavController = [self.splitViewController.viewControllers firstObject];
        PSSDocumentListTableViewController * mainViewController = (PSSDocumentListTableViewController*)[masterNavController.viewControllers firstObject];
        
        
        if ([mainViewController respondsToSelector:@selector(deselectAllRowsAnimated:)]) {
            [mainViewController deselectAllRowsAnimated:YES];
        }
        
    }
    
    
    
}

-(void)dealloc{
    
    
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"PSSDocumentBaseObject" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"displayName" ascending:NO];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"FavoriteDocuments"];
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



- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
 {
 // In the simplest, most efficient, case, reload the table view.
 [self.collectionView reloadData];
}


- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    PSSDocumentBaseObject *object = (PSSDocumentBaseObject*)[self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = object.displayName;
    
    
    cell.imageView.image = [UIImage imageWithData:[object.thumbnail data]];
    
}

#pragma mark - UICollectionViewDataSource methods

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.fetchedResultsController.fetchedObjects.count;
}

-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"documentCell" forIndexPath:indexPath];
    
    
    UIImageView * thumbnailView = (UIImageView*)[cell viewWithTag:1];
    UILabel * labelView = (UILabel*)[cell viewWithTag:2];
    UIImageView * lockImageView = (UIImageView*)[cell viewWithTag:3];

    PSSDocumentBaseObject * object = [self.fetchedResultsController.fetchedObjects objectAtIndex:indexPath.row];
    labelView.text = object.displayName;


    // Set the thumbnail
    PSSObjectDecorativeImage * thumbnailDecorativeImage = object.thumbnail;
    
    
    UIImage * contentImage;
    if (self.isPasscodeUnlocked) {
        [lockImageView setImage:nil];
        
        contentImage = thumbnailDecorativeImage.imageNormal;
        thumbnailView.image = contentImage;
    } else {
        
        [lockImageView setImage:[[UIImage imageNamed:@"LargeLock"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
        
        // We blur the image
        dispatch_async(backgroundQueue, ^(void) {
            
            UIImage * blurredThumbnail = thumbnailDecorativeImage.imageLightEffect;
            
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                
                [thumbnailView setAlpha:0.0];
                thumbnailView.image = blurredThumbnail;
                [UIView animateWithDuration:0.1 animations:^{
                    [thumbnailView setAlpha:1.0];
                }];
                
                
            });
            
        });
        
    }
    
    
    return cell;
    
}

#pragma mark - UICollectionViewDelegate methods

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    PSSDocumentBaseObject * baseObject = [self.fetchedResultsController.fetchedObjects objectAtIndex:indexPath.row];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        PSSDocumentsSplitViewDetailViewController * navController = (PSSDocumentsSplitViewDetailViewController*)self.navigationController;
        
        [navController presentViewControllerForDocumentEntity:baseObject];
    }
    
    
}

@end

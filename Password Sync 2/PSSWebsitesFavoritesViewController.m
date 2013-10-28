//
//  PSSWebsitesFavoritesViewController.m
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-08-03.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import "PSSWebsitesFavoritesViewController.h"
#import "PSSPasswordListViewController.h"
#import "PSSPasswordBaseObject.h"
#import "PSSAppDelegate.h"
#import "PSSObjectDecorativeImage.h"
#import "PSSPasswordSplitViewDetailViewController.h"
#import "PSSUpgradePurchasesAppViewController.h"

@interface PSSWebsitesFavoritesViewController ()
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end

@implementation PSSWebsitesFavoritesViewController

- (void)insertNewObject:(id)sender
{
    if (!APP_DELEGATE.shouldAllowNewData) {
        
        PSSUpgradePurchasesAppViewController * updateAppViewcontroller = [[PSSUpgradePurchasesAppViewController alloc] initWithNibName:@"PSSUpgradePurchasesAppViewController" bundle:[NSBundle mainBundle]];
        [self.navigationController pushViewController:updateAppViewcontroller animated:YES];
        return;
    }
    
    UIStoryboard * storyboardContainingEditor = [UIStoryboard storyboardWithName:@"PSSNewPasswordObjectStoryboard_iPhone" bundle:[NSBundle mainBundle]];
    UINavigationController * passwordEditorNavController = [storyboardContainingEditor instantiateInitialViewController];
    
    passwordEditorNavController.modalPresentationStyle = UIModalPresentationFormSheet;
    [self.navigationController presentViewController:passwordEditorNavController animated:YES completion:^{
        
    }];
    
    
    
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
	// Do any additional setup after loading the view.
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
        
        self.navigationItem.rightBarButtonItem = addButton;
        
    }
    
    PSSAppDelegate * appDelegate = (PSSAppDelegate*)[[UIApplication sharedApplication] delegate];
    self.managedObjectContext = appDelegate.managedObjectContext;
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        UINavigationController * masterNavController = [self.splitViewController.viewControllers firstObject];
        PSSPasswordListViewController * mainViewController = (PSSPasswordListViewController*)[masterNavController.viewControllers firstObject];
        
        
        if ([mainViewController respondsToSelector:@selector(deselectAllRowsAnimated:)]) {
            [mainViewController deselectAllRowsAnimated:YES];
        }

    }
    
    

    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionViewDataSource methods

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.fetchedResultsController.fetchedObjects.count;
}

-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"websiteCell" forIndexPath:indexPath];
    
    
    UIImageView * thumbnailView = (UIImageView*)[cell viewWithTag:1];
    UILabel * labelView = (UILabel*)[cell viewWithTag:2];
    
    PSSPasswordBaseObject * object = [self.fetchedResultsController.fetchedObjects objectAtIndex:indexPath.row];
    
    // Set the thumbnail
    UIImage * contentImage;
    if (object.thumbnail) {
        
        PSSObjectDecorativeImage * thumbnailDecorativeImage = object.thumbnail;
        contentImage = thumbnailDecorativeImage.imageNormal;

    } else {
        contentImage = [UIImage imageNamed:@"WebsitePlaceholder"];
    }
    thumbnailView.image = contentImage;
    labelView.text = object.displayName;

    
    

    return cell;
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
    
    // Only fetch the favorites
    NSPredicate * favoritesPredicate = [NSPredicate predicateWithFormat:@"favorite == YES"];
    
    [fetchRequest setPredicate:favoritesPredicate];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"FavoritePasswords"];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	}
    
    return _fetchedResultsController;
}

 // Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed.
 
 - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
 {
 // In the simplest, most efficient, case, reload the table view.
 [self.collectionView reloadData];

}

#pragma mark - UICollectionViewDelegate methods

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    PSSPasswordBaseObject * baseObject = [self.fetchedResultsController.fetchedObjects objectAtIndex:indexPath.row];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        PSSPasswordSplitViewDetailViewController * navController = (PSSPasswordSplitViewDetailViewController*)self.navigationController;
        
        [navController presentViewControllerForPasswordEntity:baseObject];
    }
    
    
}


@end

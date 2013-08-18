//
//  PSSCardsFavoritesViewController.m
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-08-03.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import "PSSCardsFavoritesViewController.h"
#import "PSSCardsTableViewController.h"
#import "PSSCardEditorViewController.h"
#import "PSSCreditCardBaseObject.h"
#import "PSSCreditCardVersion.h"
#import "PSSCardsSplitViewDetailViewController.h"
#import "PSSAppDelegate.h"
#import "CardIOCreditCardInfo.h"

@interface PSSCardsFavoritesViewController ()
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (strong, nonatomic) NSManagedObjectContext*managedObjectContext;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@end

@implementation PSSCardsFavoritesViewController

- (void)insertNewObject:(id)sender {
    
    PSSCardEditorViewController * cardEditor = [[PSSCardEditorViewController alloc] initWithStyle:UITableViewStyleGrouped];
    UINavigationController * editorNavController = [[UINavigationController alloc] initWithRootViewController:cardEditor];
    editorNavController.modalPresentationStyle = UIModalPresentationFormSheet;
    [self.navigationController presentViewController:editorNavController animated:YES completion:^{}];
    
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
    
    PSSAppDelegate * appDelegate = (PSSAppDelegate*)[[UIApplication sharedApplication] delegate];
    self.managedObjectContext = appDelegate.managedObjectContext;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
        
        self.navigationItem.rightBarButtonItem = addButton;
        
    }

}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        UINavigationController * masterNavController = [self.splitViewController.viewControllers firstObject];
        PSSCardsTableViewController * mainViewController = (PSSCardsTableViewController*)[masterNavController.viewControllers firstObject];
        
        
        if ([mainViewController respondsToSelector:@selector(deselectAllRowsAnimated:)]) {
            [mainViewController deselectAllRowsAnimated:YES];
        }
        
    }
    
}

#pragma mark - UICollectionViewDataSource methods

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.fetchedResultsController.fetchedObjects.count;
}

-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cardCell" forIndexPath:indexPath];
    
    cell.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"CardBackground"]];
    cell.layer.cornerRadius = 15.0;
    
    UILabel * bankNameLabel = (UILabel*)[cell viewWithTag:1];
    UILabel * cardNumberLabel = (UILabel*)[cell viewWithTag:2];
    UIImageView * companyLogoView = (UIImageView*)[cell viewWithTag:5];
    
    
    PSSCreditCardBaseObject * object = [self.fetchedResultsController.fetchedObjects objectAtIndex:indexPath.row];
    PSSCreditCardVersion * version = (PSSCreditCardVersion*)[object currentHardLinkedVersion];
    
    // Take care of the bank name
    if (version.issuingBank) {
        bankNameLabel.text = version.issuingBank;
    } else {
        bankNameLabel.text = @"";
    }
    
    // Set the card type logo
    UIImage * cardTypeLogo = nil;
    if (version.rawCardType == CardIOCreditCardTypeAmex) {
        cardTypeLogo = [UIImage imageNamed:@"AmexLogo"];
    } else if (version.rawCardType == CardIOCreditCardTypeDiscover) {
        cardTypeLogo = [UIImage imageNamed:@"DiscoverLogo"];
    } else if (version.rawCardType == CardIOCreditCardTypeMastercard){
        cardTypeLogo = [UIImage imageNamed:@"MasterCardLogo"];
    } else if (version.rawCardType == CardIOCreditCardTypeVisa) {
        cardTypeLogo = [UIImage imageNamed:@"VisaLogo"];
    }
    companyLogoView.image = cardTypeLogo;
    
    // set user's card number
    
    NSString * cardNumber;
    if ([[version unencryptedLastDigits] length] == 16) {
        cardNumber = [NSString stringWithFormat:@"0000 0000 0000 %@", [[version unencryptedLastDigits] stringByReplacingOccurrencesOfString:@"•" withString:@""]];
    } else {
        // Not a credit card
        cardNumber = [[version unencryptedLastDigits] stringByReplacingOccurrencesOfString:@"•" withString:@"0"];
    }
    
    
    cardNumberLabel.text = cardNumber;
    cardNumberLabel.font = [UIFont fontWithName:@"OCRA" size:17.];
    
    
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
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"PSSCreditCardBaseObject" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"displayName" ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"FavoriteCards"];
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
    
    PSSCreditCardBaseObject * baseObject = [self.fetchedResultsController.fetchedObjects objectAtIndex:indexPath.row];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        PSSCardsSplitViewDetailViewController * navController = (PSSCardsSplitViewDetailViewController*)self.navigationController;
        
        [navController presentViewControllerForCardEntity:baseObject];
    }
    
    
}


@end

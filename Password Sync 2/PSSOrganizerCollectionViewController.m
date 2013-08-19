//
//  PSSOrganizerCollectionViewController.m
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-08-17.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import "PSSOrganizerCollectionViewController.h"
#import "PSSOrganizerSplitViewDetailViewController.h"
#import "PSSUnlockPromptViewController.h"
#import "PSSTagsAndDirectoriesTableViewController.h"
#import "RFQuiltLayout.h"
#import "PSSAppDelegate.h"
#import "PSSObjectTag.h"
#import "UIColor+PSSDictionaryCoding.h"

@interface PSSOrganizerCollectionViewController () {
    NSUInteger _countOfGenericObjects;
}

@property (nonatomic) BOOL passcodeUnlockedForSettingsSegue;

@property (nonatomic, strong) NSFetchedResultsController * tagsFetchedResultsController;

@end

@implementation PSSOrganizerCollectionViewController


-(NSUInteger)countOfTotalGenericObjects{
    if (_countOfGenericObjects) {
        return _countOfGenericObjects;
    }
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"PSSBaseGenericObject" inManagedObjectContext:APP_DELEGATE.managedObjectContext]];
    
    [request setIncludesSubentities:YES];
    
    NSError *err;
    NSUInteger count = [APP_DELEGATE.managedObjectContext countForFetchRequest:request error:&err];
    if(count == NSNotFound) {
        //Handle error
        return 0;
    }
    
    _countOfGenericObjects = count;
    
    return _countOfGenericObjects;
}

-(UIColor *)readableForegroundColorForColor:(UIColor*)color {
    // oldColor is the UIColor to invert
    
    const CGFloat *componentColors = CGColorGetComponents(color.CGColor);

    CGFloat darknessIndice = (((componentColors[0]*255) * 299) + ((componentColors[1]*255) * 587) + ((componentColors[2]*255) * 114)) / 1000;
    
    if (darknessIndice >= 125) {
        return [UIColor blackColor];
    }
    
    return [UIColor whiteColor];
}

-(void)prepareQuiltLayoutForBounds:(CGRect)bounds{
    RFQuiltLayout* layout = (id)[self.collectionView collectionViewLayout];
    CGFloat blocksWidth = bounds.size.width / 5;
    layout.blockPixels = CGSizeMake(blocksWidth, blocksWidth);
    
}

-(CGFloat)percentOfTotalObjectsInTag:(PSSObjectTag*)objectTag{
    
    NSUInteger numberOfRelationshipsForTag = [objectTag.encryptedObjects count];
    CGFloat percentageOfTotalObjectsInTag = (float)numberOfRelationshipsForTag / [self countOfTotalGenericObjects];
    
    
    return percentageOfTotalObjectsInTag;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    RFQuiltLayout* layout = (id)[self.collectionView collectionViewLayout];
    layout.direction = UICollectionViewScrollDirectionVertical;
    layout.blockPixels = CGSizeMake(100, 100);
    
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"PSSTagCollectionViewCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"tagCell"];
    

}



-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        UINavigationController * masterNavController = [self.splitViewController.viewControllers firstObject];
        PSSTagsAndDirectoriesTableViewController * mainViewController = (PSSTagsAndDirectoriesTableViewController*)[masterNavController.viewControllers firstObject];
        
        
        if ([mainViewController respondsToSelector:@selector(deselectAllRowsAnimated:)]) {
            [mainViewController deselectAllRowsAnimated:YES];
        }
        
    }
    
    
    
    [self prepareQuiltLayoutForBounds:self.view.bounds];
    [self.collectionView reloadData];
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    
    [self prepareQuiltLayoutForBounds:self.view.bounds];
    [self.collectionView performBatchUpdates:nil completion:nil];
    
}


-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender{
    
    if ([identifier isEqualToString:@"presentSettingsPopoverSegue"]) {
        
        if (self.passcodeUnlockedForSettingsSegue) {
            return YES;
        } else {
            
            UIStoryboard * unlockStoryboard = [UIStoryboard storyboardWithName:@"UnlockPrompt" bundle:[NSBundle mainBundle]];
            PSSUnlockPromptViewController * unlockController = (PSSUnlockPromptViewController*)[unlockStoryboard instantiateInitialViewController];
            
            [self.navigationController presentViewController:[unlockController promptForPasscodeBlockingView:NO completion:^{
                
                double delayInSeconds = 0.1;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    self.passcodeUnlockedForSettingsSegue = YES;
                    [self performSegueWithIdentifier:@"presentSettingsPopoverSegue" sender:self.navigationItem.rightBarButtonItem];
                });
                
                
                
            } cancelation:^{
                
            }] animated:YES completion:^{
                
            }];
            return NO;
        }
        
    }
    
    return YES;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    
    if ([[segue identifier] isEqualToString:@"presentSettingsPopoverSegue"]) {
        self.passcodeUnlockedForSettingsSegue = NO;
    }
    
}

#pragma mark - UITableViewDelegate

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    PSSObjectTag * objectTag = [self.tagsFetchedResultsController objectAtIndexPath:indexPath];
    PSSOrganizerSplitViewDetailViewController * navController = (PSSOrganizerSplitViewDetailViewController*)self.navigationController;
    [navController presentViewControllerForTagEntity:objectTag];
}



#pragma mark - NSFetchedResultsController


- (NSFetchedResultsController *)tagsFetchedResultsController
{
    if (_tagsFetchedResultsController != nil) {
        return _tagsFetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"PSSObjectTag" inManagedObjectContext:APP_DELEGATE.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"position" ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:APP_DELEGATE.managedObjectContext sectionNameKeyPath:nil cacheName:@"Tags"];
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


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    // In the simplest, most efficient, case, reload the table view.
    [self.collectionView reloadData];
    
}


#pragma mark - UICollectionViewDatasource

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    return self.tagsFetchedResultsController.fetchedObjects.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"tagCell" forIndexPath:indexPath];
    
    PSSObjectTag * currentTag = [self.tagsFetchedResultsController objectAtIndexPath:indexPath];
    
    UILabel* label = (id)[cell viewWithTag:1];
    
    label.text = currentTag.name;
    
    UIColor * tagColor = [UIColor colorWithDictionary:currentTag.color];
    label.textColor = [self readableForegroundColorForColor:tagColor];
    cell.backgroundColor = tagColor;
    
    return cell;
}


#pragma mark - RFQuiltLayout delegate methods

- (CGSize) blockSizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    PSSObjectTag * tagObject = [self.tagsFetchedResultsController objectAtIndexPath:indexPath];
    
    CGFloat importanceInPercent = [self percentOfTotalObjectsInTag:tagObject];
    if (importanceInPercent < 0.05) {
        return CGSizeMake(1, 1);
    } else if (importanceInPercent < 0.10) {
        return CGSizeMake(2, 1);
    } else if (importanceInPercent < 0.15) {
        return CGSizeMake(2, 2);
    } else if (importanceInPercent < 0.20) {
        return CGSizeMake(3, 1);
    } else if (importanceInPercent < 0.25) {
        return CGSizeMake(2, 2);
    } else if (importanceInPercent <0.35) {
        return CGSizeMake(3, 2);
    } else if (importanceInPercent <0.50) {
        return CGSizeMake(4, 1);
    } else if (importanceInPercent < 0.75) {
        return CGSizeMake(5, 1);
    } else {
        return CGSizeMake(5, 2);
    }
    
    
    return CGSizeMake(1, 1);
    

}





@end

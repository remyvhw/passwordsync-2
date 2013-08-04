//
//  PSSLocationFavoritesViewController.m
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-08-03.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import "PSSLocationFavoritesViewController.h"
#import "PSSLocationListTableViewController.h"
#import "PSSLocationsSplitViewDetailViewController.h"
#import "PSSLocationEditorTableViewController.h"
#import "PSSAppDelegate.h"
#import "PSSLocationVersion.h"
#import "PSSLocationBaseObject.h"

#define MAP_PADDING 2.6
#define MINIMUM_VISIBLE_LATITUDE 0.01

@interface PSSLocationFavoritesViewController ()

@property (nonatomic, strong) NSFetchedResultsController * fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end


@implementation PSSLocationFavoritesViewController

-(void)showDetailViewForLocation:(PSSLocationBaseObject*)locationObject{
    
    PSSLocationsSplitViewDetailViewController * navController = (PSSLocationsSplitViewDetailViewController*)self.navigationController;
    
    [navController presentViewControllerForLocationEntity:locationObject];
    
}


-(void)updateAnnotationsAnimated:(BOOL)animated{
    
    // Clean the annotations
    [self.mapView removeAnnotations:[self.mapView annotations]];
    
    NSMutableArray * locations = [[NSMutableArray alloc] initWithCapacity:self.fetchedResultsController.fetchedObjects.count];
    
    double minLatitude = 0;
    double maxLatitude = 0;
    double minLongitude = 0;
    double maxLongitude = 0;
    
    for (PSSLocationBaseObject * location in self.fetchedResultsController.fetchedObjects) {
        
        PSSLocationVersion * currentVersion = (PSSLocationVersion*)location.currentHardLinkedVersion;
        MKPointAnnotation *newAnnotation = [[MKPointAnnotation alloc] init];
        
        double latitude = [[currentVersion latitude] doubleValue];
        double longitude = [[currentVersion longitude] doubleValue];
        
        [newAnnotation setCoordinate:CLLocationCoordinate2DMake(latitude, longitude)];
        
        newAnnotation.title = currentVersion.displayName;
        newAnnotation.subtitle  = currentVersion.address;
        [locations addObject:newAnnotation];
        
        
        if (minLatitude == 0 && maxLatitude == 0 && minLongitude == 0 && maxLatitude == 0) {
            // First run in the loop
            minLatitude = latitude;
            maxLatitude = latitude;
            minLongitude = longitude;
            maxLongitude = longitude;
            
        } else {
            
            if (latitude < minLatitude) {
                minLatitude = latitude;
            }
            
            if (latitude > maxLatitude) {
                maxLatitude = latitude;
            }
            
            if (longitude < minLongitude) {
                minLongitude = longitude;
            }
            
            if (longitude > maxLongitude) {
                maxLongitude = longitude;
            }
            
            
        }
        
        
        
    }
    
    [self.mapView addAnnotations:locations];
    
    // Update the region showed on map
    MKCoordinateRegion region;
    region.center.latitude = (minLatitude + maxLatitude) / 2;
    region.center.longitude = (minLongitude + maxLongitude) / 2;
    
    region.span.latitudeDelta = (maxLatitude - minLatitude) * MAP_PADDING;
    
    region.span.latitudeDelta = (region.span.latitudeDelta < MINIMUM_VISIBLE_LATITUDE)
    ? MINIMUM_VISIBLE_LATITUDE
    : region.span.latitudeDelta;
    
    region.span.longitudeDelta = (maxLongitude - minLongitude) * MAP_PADDING;
    
    MKCoordinateRegion scaledRegion = [self.mapView regionThatFits:region];
    [self.mapView setRegion:scaledRegion animated:animated];
    
}

-(void)updateAnnotations{
    [self updateAnnotationsAnimated:YES];
}


- (void)insertNewObject:(id)sender {
    
    PSSLocationEditorTableViewController * locationEditor = [[PSSLocationEditorTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    UINavigationController * navController = [[UINavigationController alloc] initWithRootViewController:locationEditor];
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
	// Do any additional setup after loading the view.
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
        
        self.navigationItem.rightBarButtonItem = addButton;
        
    }
    
    PSSAppDelegate *appDelegate = (PSSAppDelegate*)[[UIApplication sharedApplication] delegate];
    self.managedObjectContext = appDelegate.managedObjectContext;
    
    
    [self updateAnnotationsAnimated:NO];
    
   
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        UINavigationController * masterNavController = [self.splitViewController.viewControllers firstObject];
        PSSLocationListTableViewController * mainViewController = (PSSLocationListTableViewController*)[masterNavController.viewControllers firstObject];
        
        
        if ([mainViewController respondsToSelector:@selector(deselectAllRowsAnimated:)]) {
            [mainViewController deselectAllRowsAnimated:YES];
        }
        
        self.splitViewController.presentsWithGesture = NO;
        
    }
    
    
    
}





#pragma mark - NSFetchedResultsController

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"PSSLocationBaseObject" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:100];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"displayName" ascending:NO];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSPredicate * fetchPredicate = [NSPredicate predicateWithFormat:@"shouldGeofence == YES OR favorite == YES"];
    
    [fetchRequest setPredicate:fetchPredicate];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"FavoriteLocations"];
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


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    [self updateAnnotations];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    [self updateAnnotations];
}



-(MKAnnotationView*)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    
    static NSString *reuseId = @"annotationPin";
    MKPinAnnotationView *pav = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:reuseId];
    if (pav == nil)
    {
        pav = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseId];
        pav.draggable = NO;
        pav.pinColor = MKPinAnnotationColorGreen;
        pav.canShowCallout = YES;
        UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        [rightButton setTitle:annotation.title forState:UIControlStateNormal];
        [pav setRightCalloutAccessoryView:rightButton];
        
    }
    else {
        pav.annotation = annotation;
    }
    

    
    return pav;
}


- (void)mapView:(MKMapView *)mapView
 annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    
    if ([(UIButton*)control buttonType] == UIButtonTypeDetailDisclosure){
        // Do your thing when the detailDisclosureButton is touched
        
        PSSLocationBaseObject * baseObject = [self.fetchedResultsController.fetchedObjects objectAtIndex:[self.mapView.annotations indexOfObject:[view annotation]]];
        
        [self showDetailViewForLocation:baseObject];
        
    }
}


@end

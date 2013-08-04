//
//  PSSLocationEditorTableViewController.m
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-07-18.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import "PSSLocationEditorTableViewController.h"
#import "PSSnewPasswordMultilineTextFieldCell.h"
#import "PSSnewPasswordBasicTextFieldCell.h"
#import "PSSnewPasswordPasswordTextFieldCell.h"
#import "PSSLocationBaseObject.h"
#import "PSSLocationVersion.h"
#import "PSSPasswordGeneratorTableViewController.h"
#import "PSSlocationSearchTextFieldCell.h"
#import "PSSLocationMapCell.h"
#import "PSSAppDelegate.h"
#import "PSSSwitchTableViewCell.h"

@import CoreLocation;
@import MapKit;
@import AddressBookUI;

@interface PSSLocationEditorTableViewController ()

@property (strong) PSSnewPasswordBasicTextFieldCell * titleCell;
@property (strong) PSSnewPasswordPasswordTextFieldCell * passwordCell;
@property (strong) PSSSwitchTableViewCell * geofenceCell;

@property (strong) PSSlocationSearchTextFieldCell * locationSearchCell;
@property (strong) PSSLocationMapCell * mapCell;

@property (strong, nonatomic) PSSnewPasswordMultilineTextFieldCell * notesCell;
@property (nonatomic) CLLocationCoordinate2D pinLocation;
@property (nonatomic) NSString * addressString;

@property (strong, nonatomic) UIPopoverController * generatorPopover;


@property (nonatomic) BOOL isPasscodeUnlocked;

@end

@implementation PSSLocationEditorTableViewController


-(void)startGeofencingLocation:(PSSLocationBaseObject*)locationObject{
    
    PSSAppDelegate * appDelegate = (PSSAppDelegate*)[[UIApplication sharedApplication] delegate];
    NSString * identifierString = [[[locationObject objectID] URIRepresentation] absoluteString];
    
    CLLocationManager * locationManager = appDelegate.locationManager;
    
    CLCircularRegion * geofence = [[CLCircularRegion alloc] initWithCenter:CLLocationCoordinate2DMake([locationObject.currentVersion.latitude doubleValue], [locationObject.currentVersion.longitude doubleValue]) radius:[locationObject.currentVersion.radius doubleValue] identifier:identifierString];
    
    [locationManager startMonitoringForRegion:geofence];
    
    
}


-(void)stopGeofencingLocation:(PSSLocationBaseObject*)locationObject{
    
    PSSAppDelegate * appDelegate = (PSSAppDelegate*)[[UIApplication sharedApplication] delegate];
    NSString * identifierString = [[[locationObject objectID] URIRepresentation] absoluteString];
    CLLocationManager * locationManager = appDelegate.locationManager;
    
    
    for (CLRegion * region in locationManager.monitoredRegions) {
        if ([region.identifier isEqualToString:identifierString]) {
            
            [locationManager stopMonitoringForRegion:region];
            break;
        }
    }
    
    
}


-(PSSLocationVersion*)insertNewLocationVersionInManagedObject{
    
    PSSAppDelegate * appDelegate = (PSSAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    PSSLocationVersion *newManagedObject = (PSSLocationVersion*)[NSEntityDescription insertNewObjectForEntityForName:@"PSSLocationVersion" inManagedObjectContext:context];
    
    // We'll automatically timestamp it
    newManagedObject.timestamp = [NSDate date];
    
    return newManagedObject;
    
}

-(PSSLocationBaseObject*)insertNewLocationInManagedObject{
    
    PSSAppDelegate * appDelegate = (PSSAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    PSSLocationBaseObject *newManagedObject = (PSSLocationBaseObject*)[NSEntityDescription insertNewObjectForEntityForName:@"PSSLocationBaseObject" inManagedObjectContext:context];
    
    // We'll add a creation date automatically
    newManagedObject.created = [NSDate date];
    
    return newManagedObject;
    
}

-(void)saveChangesAndDismiss{
    
    BOOL creatingMode = NO;
    
    if (!self.locationBaseObject) {
        self.locationBaseObject = [self insertNewLocationInManagedObject];
        creatingMode = YES;
    }
    
    
    // Check if user decided to stop geofencing the location
    if (!creatingMode) {
        
        if ([self.locationBaseObject.shouldGeofence boolValue] && !self.geofenceCell.switchView.isOn) {
            // Base object says yes, new switch value says no. Remove the location from the geofenced areas.
            [self stopGeofencingLocation:self.locationBaseObject];
        }
        
    }
    
    self.locationBaseObject.shouldGeofence = [NSNumber numberWithBool:self.geofenceCell.switchView.isOn];
    
    
    // We need to create a new version
    
    PSSLocationVersion * version = [self insertNewLocationVersionInManagedObject];
    
    version.encryptedObject = self.locationBaseObject;
    
    version.displayName = self.titleCell.textField.text;
    // We update the display name with the latest
    self.locationBaseObject.displayName = version.displayName;
    
    version.decryptedPassword = self.passwordCell.textField.text;
    version.decryptedNotes = self.notesCell.textView.text;
    
    
    // We save the location
    
    // We save the latitude and longitude separately as they could differ from the "official" ones if the user drags the pin around.
    version.latitude = @(self.mapCell.locationPin.coordinate.latitude);
    version.longitude = @(self.mapCell.locationPin.coordinate.longitude);
    version.address = self.addressString;
    // Just fake a radius.
    version.radius = @100;
    
    self.locationBaseObject.address = version.address;
    self.locationBaseObject.currentVersion = version;
    NSError *error = nil;
    if (![self.locationBaseObject.managedObjectContext save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"An error occured", nil) message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
        
    }
    
    // Start geofencing the saved object
    if (self.geofenceCell.switchView.isOn) {
        [self startGeofencingLocation:self.locationBaseObject];
    }
    
    
    if (creatingMode) {
        [self.navigationController dismissViewControllerAnimated:YES completion:^{
        }];
    } else {
        if (self.editorDelegate) {
            [self.editorDelegate objectEditor:self finishedWithObject:self.locationBaseObject];
        }
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    
}


-(void)doneEditing:(id)sender{
    
    NSString * filePath = [[NSBundle mainBundle] pathForResource:@"commonPassDict" ofType:@"plist"];
    
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:filePath];
    
    NSArray * commonPasswordsArray = (NSArray*)[dict objectForKey:@"Root"];
    
    // Check if password is one of the top 500 passwords in use
    if ([commonPasswordsArray containsObject:self.passwordCell.textField.text] || [commonPasswordsArray containsObject:[self.passwordCell.textField.text lowercaseString]]) {
        // Alert the user it's password is sorta lame
        
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Weak Password Alert", nil) message:NSLocalizedString(@"The password you entered is one of the 500 most commonly used passwords on the Internet. Please chose another password.", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
        
        [alertView show];
    } else {
        
        // We're good, we can proceed with save
        [self saveChangesAndDismiss];
    }
    
}


-(void)showPasswordGenerator:(id)sender{
    
    PSSPasswordGeneratorTableViewController * passwordGenerator = [[PSSPasswordGeneratorTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    passwordGenerator.generatorDelegate = self;

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        
        if (self.generatorPopover) {
            [self.generatorPopover dismissPopoverAnimated:YES];
            self.generatorPopover = nil;
            return;
        }
        
        
        UINavigationController * navController = [[UINavigationController alloc] initWithRootViewController:passwordGenerator];
        
        UIPopoverController * popover = [[UIPopoverController alloc] initWithContentViewController:navController];
        self.generatorPopover = popover;
        
        
        [popover presentPopoverFromRect:self.passwordCell.shuffleButton.frame inView:self.passwordCell permittedArrowDirections:UIPopoverArrowDirectionRight animated:YES];
        
    } else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
    
    [self.navigationController pushViewController:passwordGenerator animated:YES];
    }
}


-(void)updateMapView{
    [self.locationSearchCell setIsGeocoding:YES];
    
    CLGeocoder * geocoder = [[CLGeocoder alloc] init];
    
   [geocoder geocodeAddressString:self.locationSearchCell.textField.text inRegion:nil completionHandler:^(NSArray *placemarks, NSError *error) {
       
       [self.locationSearchCell setIsGeocoding:NO];
       
       if (error) {
           UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"An Error Occured", nil) message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
           [alertView show];
       } else {
           
           if ([placemarks count] > 1) {
               
               // Prompt user for a specific location
           } else {
               CLLocation * location = [(CLPlacemark*)[placemarks objectAtIndex:0] location];
               self.pinLocation = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude);
               self.addressString = ABCreateStringWithAddressDictionary([(CLPlacemark*)[placemarks objectAtIndex:0] addressDictionary], NO);
           }
           
           
            [self.mapCell rearrangePinAndMapLocationWithLocation:self.pinLocation];
           
       }
       
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

-(void)cancelNewLocationEditor:(id)sender{
    
    
    [self.navigationController dismissViewControllerAnimated:YES completion:^{}];
    
    if (self.editorDelegate && [self.editorDelegate respondsToSelector:@selector(objectEditor:canceledOperationOnObject:)]) {
        [self.editorDelegate objectEditor:self canceledOperationOnObject:self.locationBaseObject];
    }
    
}



-(void)lockUI:(id)sender{
    
    self.isPasscodeUnlocked = NO;
    
    // Hide our sensitive information fields
    [self.passwordCell.textField setAlpha:0.0];
    
    // Launch a timer. If after 30 seconds our user is not back in the app, we'll just pop this editor our of the stack
    double delayInSeconds = 15.;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        // If user came back to the app in the meantime we just invalidate this timer
        if (!self.isPasscodeUnlocked) {
            
            if (self.navigationController.visibleViewController == self) {
                
                [self.navigationController popViewControllerAnimated:NO];
                
            }
            
        }
        
    });
    
    
}

-(void)unlockUI:(id)sender{
    
    self.isPasscodeUnlocked = YES;
    [self.passwordCell.textField setAlpha:1.0];
    
    
    
}



- (void)viewDidLoad
{
    [super viewDidLoad];

    if (self.locationBaseObject) {
        // We're in edit mode
        
        // Set the location object
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(lockUI:) name:PSSGlobalLockNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(unlockUI:) name:PSSGlobalUnlockNotification object:nil];
        
        self.isPasscodeUnlocked = YES;
        
        self.addressString = self.locationBaseObject.address;
        
    } else {
        
        self.title = NSLocalizedString(@"New Location", nil);
        
        // We're writing a new password
        
        UIBarButtonItem * cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelNewLocationEditor:)];
        
        self.navigationItem.leftBarButtonItem = cancelButton;
    }
    
    UIBarButtonItem * saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(doneEditing:)];
    self.navigationItem.rightBarButtonItem = saveButton;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - Table view data source

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    
    if (section == 1) {
        return NSLocalizedString(@"Location", nil);
    } else if (section == 2){
        return NSLocalizedString(@"Notes", nil);
    }
    
    return @"";
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 2) {
        // Notes
        return 144.;
    } else if (indexPath.section == 1 && indexPath.row == 1){
        // Map cell
        return 244.;
    }
    
    return 44.;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == 0) {
        // Title / password / pin
        return 2;
    } else if (section == 1){
        // Location
        return 3;
    } else if (section == 2){
        // Note
        return 1;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell;
    if (indexPath.section == 0 && indexPath.row == 0) {
        // Title Cell
        
        if (!self.titleCell) {
            
            PSSnewPasswordBasicTextFieldCell * titleCell = [[PSSnewPasswordBasicTextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            self.titleCell = titleCell;
            if (self.locationBaseObject) {
                self.titleCell.textField.text = self.locationBaseObject.displayName;
            }
            self.titleCell.textField.placeholder = NSLocalizedString(@"Title", nil);
            self.titleCell.selectionStyle = UITableViewCellSelectionStyleNone;
            self.titleCell.nextFormField = self.passwordCell.textField;
            
        }
        cell = self.titleCell;
        
    } else if (indexPath.section == 0 && indexPath.row == 1) {
        // Password Cell
        
        if (!self.passwordCell) {
            PSSnewPasswordPasswordTextFieldCell * passwordCell = [[PSSnewPasswordPasswordTextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            
            self.passwordCell = passwordCell;
            if (self.locationBaseObject) {
                self.passwordCell.textField.text = [self.locationBaseObject.currentVersion decryptedPassword];
            }
            self.passwordCell.textField.placeholder = NSLocalizedString(@"PIN", nil);
            self.passwordCell.selectionStyle = UITableViewCellSelectionStyleNone;
            [self.passwordCell.shuffleButton addTarget:self action:@selector(showPasswordGenerator:) forControlEvents:UIControlEventTouchUpInside];
            self.passwordCell.nextFormField = self.locationSearchCell.textField;
        }
        cell = self.passwordCell;
        
    } else if (indexPath.section == 1 && indexPath.row == 0) {
        // Location Search Cell
        
        if (!self.locationSearchCell) {
            
            PSSlocationSearchTextFieldCell * locationSearchCell = [[PSSlocationSearchTextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            self.locationSearchCell = locationSearchCell;
            if (self.locationBaseObject) {
                self.locationSearchCell.textField.text = self.locationBaseObject.currentVersion.address;
                
            }
            self.locationSearchCell.textField.placeholder = NSLocalizedString(@"Address", nil);
            self.locationSearchCell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            
            // Automatically try to complete the bank details for the typed credit card number
            // We never query bank details one existing card object / edit mode.
            __weak typeof(self) weakSelf = self;
            [self.locationSearchCell setFinishedEditingAddressBlock:^{
                [weakSelf updateMapView];
            }];
            
            
        }
        cell = self.locationSearchCell;
        
    } else if (indexPath.section == 1 && indexPath.row == 1) {
        // Location map Cell
        
        if (!self.mapCell) {
            PSSLocationMapCell * mapCell = [[PSSLocationMapCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            mapCell.userEditable = YES;
            self.mapCell = mapCell;
            
            self.mapCell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            if (self.locationBaseObject) {
                [self.mapCell rearrangePinAndMapLocationWithLocation:CLLocationCoordinate2DMake([self.locationBaseObject.currentVersion.latitude doubleValue], [self.locationBaseObject.currentVersion.longitude doubleValue])];
            }
            
        }
        cell = self.mapCell;
        
    } else if (indexPath.section == 1 && indexPath.row==2 ) {
        
        if (!self.geofenceCell) {
            PSSSwitchTableViewCell * geofenceCell = [[PSSSwitchTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
            geofenceCell.textLabel.text = NSLocalizedString(@"Location monotoring", nil);
            geofenceCell.detailTextLabel.text = NSLocalizedString(@"Monitor up to 20 locations", nil);
            
            self.geofenceCell = geofenceCell;
        }
        
        if (self.locationBaseObject) {
            if ([self.locationBaseObject.shouldGeofence boolValue]) {
                [self.geofenceCell.switchView setOn:YES];
            } else {
                [self.geofenceCell.switchView setOn:NO];
            }
        }
        
        cell = self.geofenceCell;
        
    } else if (indexPath.section == 2 && indexPath.row == 0){
        // Notes cell
        
        if (!self.notesCell) {
            
            PSSnewPasswordMultilineTextFieldCell * notesCell = [[PSSnewPasswordMultilineTextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            
            self.notesCell = notesCell;
            if (self.locationBaseObject) {
                self.notesCell.textView.text = [self.locationBaseObject.currentVersion decryptedNotes];
            }
            self.notesCell.selectionStyle = UITableViewCellSelectionStyleNone;
            
        }
        
        cell = self.notesCell;
        
    }
    
    return cell;
}

#pragma mark - PSSPasswordGeneratorTableViewControllerProtocol methods
-(void)passwordGenerator:(PSSPasswordGeneratorTableViewController *)generator finishedWithPassword:(NSString *)randomPassword{
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [self.generatorPopover dismissPopoverAnimated:YES];
        self.generatorPopover = nil;
    }
    
    [self.passwordCell setUnsecureTextPassword:randomPassword];
}

@end

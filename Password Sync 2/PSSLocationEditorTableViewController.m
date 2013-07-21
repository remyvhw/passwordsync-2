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

@import CoreLocation;
@import MapKit;
@import AddressBookUI;

@interface PSSLocationEditorTableViewController ()

@property (strong) PSSnewPasswordBasicTextFieldCell * titleCell;
@property (strong) PSSnewPasswordBasicTextFieldCell * usernameCell;
@property (strong) PSSnewPasswordPasswordTextFieldCell * passwordCell;

@property (strong) PSSlocationSearchTextFieldCell * locationSearchCell;
@property (strong) PSSLocationMapCell * mapCell;

@property (strong, nonatomic) PSSnewPasswordMultilineTextFieldCell * notesCell;
@property (strong) CLPlacemark * pinLocation;




@end

@implementation PSSLocationEditorTableViewController


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
    
    BOOL editingMode = NO;
    
    if (!self.locationBaseObject) {
        self.locationBaseObject = [self insertNewLocationInManagedObject];
        editingMode = YES;
    }
    
    
    
    // We need to create a new version
    
    PSSLocationVersion * version = [self insertNewLocationVersionInManagedObject];
    
    version.encryptedObject = self.locationBaseObject;
    
    version.displayName = self.titleCell.textField.text;
    // We update the display name with the latest
    self.locationBaseObject.displayName = version.displayName;
    
    version.decryptedUsername = self.usernameCell.textField.text;
    version.decryptedPassword = self.passwordCell.textField.text;
    version.decryptedNotes = self.notesCell.textView.text;
    
    
    // We save the location
    version.cllocation = [NSKeyedArchiver archivedDataWithRootObject:self.pinLocation];
    // We save the latitude and longitude separately as they could differ from the "official" ones if the user drags the pin around.
    version.latitude = @(self.mapCell.locationPin.coordinate.latitude);
    version.longitude = @(self.mapCell.locationPin.coordinate.longitude);
    
    NSError *error = nil;
    if (![self.locationBaseObject.managedObjectContext save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"An error occured", nil) message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
        
    }
    
    if (editingMode) {
        [self.navigationController dismissViewControllerAnimated:YES completion:^{
        }];
    } else {
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
    [self.navigationController pushViewController:passwordGenerator animated:YES];
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
               self.pinLocation = [placemarks objectAtIndex:0];
           }
           
           
            [self.mapCell rearrangePinAndMapLocationWithPlacemark:self.pinLocation];
           
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
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    if (self.locationBaseObject) {
        // We're in edit mode
        
        // Set the location object
        NSData * encodedPlacemark = self.locationBaseObject.currentVersion.cllocation;
        CLPlacemark * placemark = [NSKeyedUnarchiver unarchiveObjectWithData:encodedPlacemark];
        self.pinLocation = placemark;
        
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
        return 3;
    } else if (section == 1){
        // Location
        return 2;
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
            self.titleCell.nextFormField = self.usernameCell.textField;
            
        }
        cell = self.titleCell;
        
    } else if (indexPath.section == 0 && indexPath.row == 1) {
        // Username Cell
        
        if (!self.usernameCell) {
            PSSnewPasswordBasicTextFieldCell * usernameCell = [[PSSnewPasswordBasicTextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            
            self.usernameCell = usernameCell;
            if (self.locationBaseObject) {
                self.usernameCell.textField.text = [self.locationBaseObject.currentVersion decryptedUsername];
            }
            self.usernameCell.textField.placeholder = NSLocalizedString(@"Username (optional)", nil);
            self.usernameCell.selectionStyle = UITableViewCellSelectionStyleNone;
            self.usernameCell.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
            self.usernameCell.textField.autocorrectionType = UITextAutocorrectionTypeNo;
            self.usernameCell.nextFormField = self.passwordCell.textField;
        }
        cell = self.usernameCell;
        
    } else if (indexPath.section == 0 && indexPath.row == 2) {
        // Password Cell
        
        if (!self.passwordCell) {
            PSSnewPasswordPasswordTextFieldCell * passwordCell = [[PSSnewPasswordPasswordTextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            
            self.passwordCell = passwordCell;
            if (self.locationBaseObject) {
                self.passwordCell.textField.text = [self.locationBaseObject.currentVersion decryptedPassword];
            }
            self.passwordCell.textField.placeholder = NSLocalizedString(@"Password / PIN", nil);
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
                
                NSString * formattedAddress = ABCreateStringWithAddressDictionary(self.pinLocation.addressDictionary, NO);
                
                self.locationSearchCell.textField.text = formattedAddress;
                
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
            
            self.mapCell = mapCell;
            
            self.mapCell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            if (self.locationBaseObject) {
                [self.mapCell rearrangePinAndMapLocationWithLocation:CLLocationCoordinate2DMake([self.locationBaseObject.currentVersion.latitude doubleValue], [self.locationBaseObject.currentVersion.longitude doubleValue])];
            }
            
        }
        cell = self.mapCell;
        
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
    [self.passwordCell setUnsecureTextPassword:randomPassword];
}

@end

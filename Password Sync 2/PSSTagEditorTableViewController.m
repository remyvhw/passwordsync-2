//
//  PSSTagEditorTableViewController.m
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-08-15.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import "PSSTagEditorTableViewController.h"
#import "PSSnewPasswordBasicTextFieldCell.h"
#import "PSSAppDelegate.h"
#import "UIColor+PSSDictionaryCoding.h"

@interface PSSTagEditorTableViewController ()

@property (nonatomic, strong) PSSnewPasswordBasicTextFieldCell * nameCell;

@property (strong, nonatomic) UIColor * selectedColor;

@end

@implementation PSSTagEditorTableViewController




- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}


-(PSSObjectTag*)insertNewTagInManagedObject{
    
    
    NSManagedObjectContext *context = [APP_DELEGATE managedObjectContext];
    PSSObjectTag *newManagedObject = (PSSObjectTag*)[NSEntityDescription insertNewObjectForEntityForName:@"PSSObjectTag" inManagedObjectContext:context];
    
    
    
    // Fetch the latest tag object so we increment the position by 1
    NSFetchRequest * latestPositionFetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"PSSObjectTag"];
    
    NSSortDescriptor * positionDescriptor = [[NSSortDescriptor alloc] initWithKey:@"position" ascending:NO];
    
    latestPositionFetchRequest.sortDescriptors = @[positionDescriptor];
    
    [latestPositionFetchRequest setFetchLimit:1];
    
    NSArray * returnedObjects = [APP_DELEGATE.managedObjectContext executeFetchRequest:latestPositionFetchRequest error:NULL];
    
    double position;
    if ([returnedObjects count] > 0) {
        PSSObjectTag * latestTag = [returnedObjects objectAtIndex:0];
        position = [latestTag.position doubleValue] + 1.;
    } else {
        position = 0.;
    }
    
    newManagedObject.position = [NSNumber numberWithDouble:position];
    
    return newManagedObject;
    
}

-(void)doneEditing:(id)sender{
    
    if (!self.nameCell.textField.text || [self.nameCell.textField.text isEqualToString:@""]) {
        return;
    }
    
    
    BOOL creatingMode = NO;
    
    if (!self.baseObject) {
        self.baseObject = [self insertNewTagInManagedObject];
        creatingMode = YES;
    }
    
    // We need to create a new version
    
    
    self.baseObject.name = self.nameCell.textField.text;
    self.baseObject.color = [UIColor dictionaryWithColor:self.selectedColor];
    
    NSError *error = nil;
    if (![self.baseObject.managedObjectContext save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"An error occured", nil) message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
        
    }
    
    
     [self.navigationController popViewControllerAnimated:YES];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    UIBarButtonItem * doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(doneEditing:)];
    self.navigationItem.rightBarButtonItem = doneButton;
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"ColorCell"];
    
    if (self.baseObject) {
        self.selectedColor = [UIColor colorWithDictionary:self.baseObject.color];
    } else {
        self.selectedColor = APP_DELEGATE.window.tintColor;
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"presentTagColorPickerSegue"]) {
        
        PSSTagColorPickerViewController * pickerView = [segue destinationViewController];
        pickerView.pickerDelegate = self;
        
        pickerView.selectedColor = self.selectedColor;
        
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    // Return the number of rows in the section.
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Configure the cell...
    
    
    if (indexPath.row == 0) {
        // Name cell
        
        if (!self.nameCell) {
            
            PSSnewPasswordBasicTextFieldCell * titleCell = [[PSSnewPasswordBasicTextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            self.nameCell = titleCell;
            if (self.baseObject) {
                self.nameCell.textField.text = self.baseObject.name;
            }
            self.nameCell.textField.placeholder = NSLocalizedString(@"Title", nil);
            self.nameCell.selectionStyle = UITableViewCellSelectionStyleNone;
            
        }
        return self.nameCell;
        
    } else if (indexPath.row == 1) {
        
        
            
            UITableViewCell * colorCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ColorCell"];
        
        if (self.selectedColor) {
                colorCell.imageView.image = [UIColor imageWithColor:self.selectedColor];
        }
            colorCell.textLabel.text = NSLocalizedString(@"Color", nil);
            colorCell.selectionStyle = UITableViewCellSelectionStyleNone;
            colorCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        return colorCell;
    }
    
    
    return nil;
}

#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row==1) {
        
        [self performSegueWithIdentifier:@"presentTagColorPickerSegue" sender:self];
        
    }
}

#pragma mark - PSSTagColorPickerViewControllerDelegate

-(void)pickerViewController:(PSSTagColorPickerViewController *)viewController didFinishSelectingColor:(UIColor *)color{
    
    self.selectedColor = color;
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForItem:1 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    
}


@end

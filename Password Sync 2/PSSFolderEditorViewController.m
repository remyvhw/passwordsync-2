//
//  PSSFolderEditorViewController.m
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-08-15.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import "PSSFolderEditorViewController.h"
#import "PSSnewPasswordBasicTextFieldCell.h"
#import "PSSAppDelegate.h"

@interface PSSFolderEditorViewController ()

@property (nonatomic, strong) PSSnewPasswordBasicTextFieldCell * nameCell;


@end

@implementation PSSFolderEditorViewController

-(PSSObjectFolder*)insertNewFolderInManagedObject{
    
    
    NSManagedObjectContext *context = [APP_DELEGATE managedObjectContext];
    PSSObjectFolder *newManagedObject = (PSSObjectFolder*)[NSEntityDescription insertNewObjectForEntityForName:@"PSSObjectFolder" inManagedObjectContext:context];
    
    return newManagedObject;
    
}

-(void)doneEditing:(id)sender{
    
    
    // We're good, we can proceed with save
    
    BOOL creatingMode = NO;
    
    if (!self.baseObject) {
        self.baseObject = [self insertNewFolderInManagedObject];
        creatingMode = YES;
    }
    
    // We need to create a new version
    
    
    self.baseObject.name = self.nameCell.textLabel.text;
    self.baseObject.parent = self.parentFolder;
    
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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    return 1;
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
        
    }
    
    
    return nil;
}





@end

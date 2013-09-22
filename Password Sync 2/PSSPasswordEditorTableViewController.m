//
//  PSSPasswordEditorTableViewController.m
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-07-10.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import "PSSPasswordEditorTableViewController.h"
#import "PSSnewPasswordBasicTextFieldCell.h"
#import "PSSnewPasswordMultilineTextFieldCell.h"
#import "PSSnewPasswordPasswordTextFieldCell.h"
#import "PSSPasswordBaseObject.h"
#import "PSSPasswordVersion.h"
#import "PSSPasswordDomain.h"
#import "PSSAppDelegate.h"

#import "PSSFaviconFetcher.h"

#define kTextFieldTableViewCell @"kTextFieldTableViewCell"
#define kMultilineTableViewCell @"kMultilineTableViewCell"

@interface PSSPasswordEditorTableViewController ()

@property (strong) PSSnewPasswordBasicTextFieldCell * titleCell;
@property (strong) PSSnewPasswordBasicTextFieldCell * usernameCell;
@property (strong) PSSnewPasswordBasicTextFieldCell * hostCell;
@property (strong) PSSnewPasswordPasswordTextFieldCell * passwordCell;
@property (strong) PSSnewPasswordMultilineTextFieldCell * notesCell;

@property (strong, nonatomic) UIPopoverController * generatorPopover;

@property BOOL isPasscodeUnlocked;

@end

@implementation PSSPasswordEditorTableViewController





-(PSSPasswordVersion*)insertNewPasswordVersionInManagedObject{
    
    PSSAppDelegate * appDelegate = (PSSAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    PSSPasswordVersion *newManagedObject = (PSSPasswordVersion*)[NSEntityDescription insertNewObjectForEntityForName:@"PSSPasswordVersion" inManagedObjectContext:context];
    
    // We'll automatically timestamp it
    newManagedObject.timestamp = [NSDate date];
    
    return newManagedObject;
    
}

-(PSSPasswordBaseObject*)insertNewPasswordInManagedObject{
    
    PSSAppDelegate * appDelegate = (PSSAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    PSSPasswordBaseObject *newManagedObject = (PSSPasswordBaseObject*)[NSEntityDescription insertNewObjectForEntityForName:@"PSSPasswordBaseObject" inManagedObjectContext:context];
    
    // We'll add a creation date automatically
    newManagedObject.created = [NSDate date];
    
    return newManagedObject;
    
}

-(void)saveChangesAndDismiss{
    
    BOOL creatingMode = NO;
    
    if (!self.baseObject) {
        self.baseObject = [self insertNewPasswordInManagedObject];
        creatingMode = YES;
    }
    
    [self.baseObject setMainDomainFromString:self.hostCell.textField.text];
    
    
    // We need to create a new version
    
    PSSPasswordVersion * version = [self insertNewPasswordVersionInManagedObject];
    
    version.encryptedObject = self.baseObject;
    
    version.displayName = self.titleCell.textField.text;
    // We update the display name with the latest
    self.baseObject.displayName = version.displayName;
    
    version.decryptedUsername = self.usernameCell.textField.text;
    version.decryptedPassword = self.passwordCell.textField.text;
    version.decryptedNotes = self.notesCell.textView.text;
    
    self.baseObject.currentVersion = version;
    self.baseObject.tags = self.itemTags;
    
    
    [self.baseObject.managedObjectContext performBlockAndWait:^{
        NSError *error = nil;
        if (![self.baseObject.managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"An error occured", nil) message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
            
        }

    }];
    
    
    if (creatingMode) {
        
        [self.navigationController dismissViewControllerAnimated:YES completion:^{
            PSSFaviconFetcher * faviconFetcher = [[PSSFaviconFetcher alloc] init];
            
            [faviconFetcher backgroundFetchFaviconForBasePassword:self.baseObject];
            
        }];
    } else {
        
        if (!self.baseObject.favicon) {
            PSSFaviconFetcher * faviconFetcher = [[PSSFaviconFetcher alloc] init];
            
            [faviconFetcher backgroundFetchFaviconForBasePassword:self.baseObject];
        }
        
        if (self.editorDelegate) {
            [self.editorDelegate objectEditor:self finishedWithObject:self.baseObject];
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
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        
        if (self.generatorPopover) {
            [self.generatorPopover dismissPopoverAnimated:YES];
            self.generatorPopover = nil;
            return;
        }
        
        PSSPasswordGeneratorTableViewController * generatorView = [self.storyboard instantiateViewControllerWithIdentifier:@"passwordGenerator"];
        
        generatorView.generatorDelegate = self;
        
        UINavigationController * navController = [[UINavigationController alloc] initWithRootViewController:generatorView];
        
        UIPopoverController * popover = [[UIPopoverController alloc] initWithContentViewController:navController];
        self.generatorPopover = popover;
        
        
        [popover presentPopoverFromRect:self.passwordCell.shuffleButton.frame inView:self.passwordCell permittedArrowDirections:UIPopoverArrowDirectionRight animated:YES];
        
    } else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self performSegueWithIdentifier:@"pushPasswordGeneratorOnStackSegueIdentifier" sender:sender];
    }
    
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
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

    // Uncomment the following line to preserve selection between presentations.
    
    [self.tableView registerClass:[PSSnewPasswordBasicTextFieldCell class] forCellReuseIdentifier:kTextFieldTableViewCell];
    
    
    UIBarButtonItem * doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(doneEditing:)];
    self.navigationItem.rightBarButtonItem = doneButton;
    
    if (self.baseObject) {
        // We're in edit mode
        
        // Register for notifications
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(lockUI:) name:PSSGlobalLockNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(unlockUI:) name:PSSGlobalUnlockNotification object:nil];
        
        self.isPasscodeUnlocked = YES;
        
    }
    
    self.title = NSLocalizedString(@"New Password", nil);
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setToolbarHidden:YES animated:YES];
}



-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    // Update the field order so we can easily navigate using the keyboard's "next" button
    self.titleCell.nextFormField = self.usernameCell.textField;
    self.usernameCell.nextFormField = self.passwordCell.textField;
    self.passwordCell.nextFormField = self.hostCell.textField;
    self.hostCell.nextFormField = self.notesCell.textView;
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

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 1 && indexPath.row == 0) {
        // Notes
        return 144.;
    } else if (indexPath.section == 0 && indexPath.row == 2) {
        // Password
        return 51;
    }
    
    return 44.;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return NSLocalizedString(@"Login essentials", nil);
    } else if (section == 1){
        return NSLocalizedString(@"Notes", nil);
    } else if (section == 2) {
        return NSLocalizedString(@"Advanced", nil);
    }
    
    return @"";
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
        return 4;
    } else if (section == 1){
        // Notes
        
        return 1;
        
    } else if (section == 2) {
        // Advanced
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
            if (self.baseObject) {
                self.titleCell.textField.text = self.baseObject.displayName;
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
            if (self.baseObject) {
                self.usernameCell.textField.text = [self.baseObject.currentVersion decryptedUsername];
            }
            self.usernameCell.textField.placeholder = NSLocalizedString(@"Username", nil);
            self.usernameCell.selectionStyle = UITableViewCellSelectionStyleNone;
            self.usernameCell.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
            self.usernameCell.textField.autocorrectionType = UITextAutocorrectionTypeNo;
        }
        cell = self.usernameCell;
        
    } else if (indexPath.section == 0 && indexPath.row == 2) {
        // Password Cell
        
        if (!self.passwordCell) {
            PSSnewPasswordPasswordTextFieldCell * passwordCell = [[PSSnewPasswordPasswordTextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            
            self.passwordCell = passwordCell;
            if (self.baseObject) {
                self.passwordCell.textField.text = [self.baseObject.currentVersion decryptedPassword];
            }
            self.passwordCell.textField.placeholder = NSLocalizedString(@"Password", nil);
            self.passwordCell.selectionStyle = UITableViewCellSelectionStyleNone;
            [self.passwordCell.shuffleButton addTarget:self action:@selector(showPasswordGenerator:) forControlEvents:UIControlEventTouchUpInside];
        }
        cell = self.passwordCell;
        
    } else if (indexPath.section == 0 && indexPath.row == 3) {
        // Host Cell
        
        if (!self.hostCell) {
            PSSnewPasswordBasicTextFieldCell * hostCell = [[PSSnewPasswordBasicTextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            
            self.hostCell = hostCell;
            if (self.baseObject) {
                self.hostCell.textField.text = [[self.baseObject mainDomain] original_url];
            }
            self.hostCell.textField.placeholder = NSLocalizedString(@"URL", nil);
            self.hostCell.selectionStyle = UITableViewCellSelectionStyleNone;
            self.hostCell.textField.keyboardType = UIKeyboardTypeURL;
            self.hostCell.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
            self.hostCell.textField.autocorrectionType = UITextAutocorrectionTypeNo;
        }
        cell = self.hostCell;
        
    } else if (indexPath.section == 1 && indexPath.row == 0){
        // Notes cell
        
        if (!self.notesCell) {
            
            PSSnewPasswordMultilineTextFieldCell * notesCell = [[PSSnewPasswordMultilineTextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            
            self.notesCell = notesCell;
            if (self.baseObject) {
                self.notesCell.textView.text = [self.baseObject.currentVersion decryptedNotes];
            }
            self.notesCell.selectionStyle =UITableViewCellSelectionStyleNone;
            
        }
        
        cell = self.notesCell;
        
    } else if (indexPath.section == 2 && indexPath.row == 0) {
        // Tags
        cell = [self tagsTableViewCell];
    }
    
    
    return cell;
}


#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    
    if ([[segue identifier] isEqualToString:@"pushPasswordGeneratorOnStackSegueIdentifier"]) {
        
        // Set the password generator's delegate so we can recuperate the password
        
        PSSPasswordGeneratorTableViewController * destinationViewController = (PSSPasswordGeneratorTableViewController*)[segue destinationViewController];
        destinationViewController.generatorDelegate = self;
    }
    
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 2 && indexPath.row == 0) {
        [self presentTagSelectorViewController];
    }
    
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

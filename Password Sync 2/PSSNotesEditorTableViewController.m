//
//  PSSNotesEditorTableViewController.m
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-07-25.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import "PSSNotesEditorTableViewController.h"
#import "PSSnewPasswordBasicTextFieldCell.h"
#import "PSSnewPasswordMultilineTextFieldCell.h"
#import "PSSNoteVersion.h"
#import "PSSObjectAttachment.h"
#import "PSSObjectDecorativeImage.h"
#import "PSSThumbnailMaker.h"
#import "PSSAppDelegate.h"


@interface PSSNotesEditorTableViewController ()

@property (strong, nonatomic) PSSnewPasswordBasicTextFieldCell * titleCell;
@property (strong, nonatomic) PSSnewPasswordMultilineTextFieldCell * notesCell;
@property (strong, nonatomic) NSMutableArray * attachmentsArray;

@end

@implementation PSSNotesEditorTableViewController

#pragma mark Saving methods




-(PSSObjectDecorativeImage*)insertNewDecorativeImageInManagedObject{
    PSSAppDelegate * appDelegate = (PSSAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    PSSObjectDecorativeImage *newManagedObject = (PSSObjectDecorativeImage*)[NSEntityDescription insertNewObjectForEntityForName:@"PSSObjectDecorativeImage" inManagedObjectContext:context];
    
    // We'll automatically timestamp it
    newManagedObject.timestamp = [NSDate date];
    
    return newManagedObject;
}


-(PSSObjectAttachment*)insertNewAttachmentInManagedObject{
    PSSAppDelegate * appDelegate = (PSSAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    PSSObjectAttachment *newManagedObject = (PSSObjectAttachment*)[NSEntityDescription insertNewObjectForEntityForName:@"PSSObjectAttachment" inManagedObjectContext:context];
    
    // We'll automatically timestamp it
    newManagedObject.timestamp = [NSDate date];
    
    return newManagedObject;
}

-(PSSNoteVersion*)insertNewNoteVersionInManagedObject{
    
    PSSAppDelegate * appDelegate = (PSSAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    PSSNoteVersion *newManagedObject = (PSSNoteVersion*)[NSEntityDescription insertNewObjectForEntityForName:@"PSSNoteVersion" inManagedObjectContext:context];
    
    // We'll automatically timestamp it
    newManagedObject.timestamp = [NSDate date];
    
    return newManagedObject;
    
}

-(PSSNoteBaseObject*)insertNewNoteInManagedObject{
    
    PSSAppDelegate * appDelegate = (PSSAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    PSSNoteBaseObject *newManagedObject = (PSSNoteBaseObject*)[NSEntityDescription insertNewObjectForEntityForName:@"PSSNoteBaseObject" inManagedObjectContext:context];
    
    // We'll add a creation date automatically
    newManagedObject.created = [NSDate date];
    
    return newManagedObject;
    
}

-(void)saveChangesAndDismiss{
    
    BOOL creatingMode = NO;
    
    if (!self.baseObject) {
        self.baseObject = [self insertNewNoteInManagedObject];
        creatingMode = YES;
    }
    

    
    
    // We need to create a new version
    
    PSSNoteVersion * version = [self insertNewNoteVersionInManagedObject];
    
    // Save the version
    version.encryptedObject = self.baseObject;
    
    version.displayName = self.titleCell.textField.text;
    // We update the display name with the latest
    self.baseObject.displayName = version.displayName;
    
    version.decryptedNoteTextContent = self.notesCell.textView.text;
    
    
    
    // Save the attachments
    if ([self.attachmentsArray count]) {
        NSMutableSet * setOfnewAttachments = [[NSMutableSet alloc] initWithCapacity:[self.attachmentsArray count]];
        NSInteger counter = 0;
        for (id attachment in self.attachmentsArray) {
            
            PSSObjectDecorativeImage * thumbnail;
            
            if ([attachment isKindOfClass:[PSSObjectAttachment class]]) {
                [setOfnewAttachments addObject:attachment];
                
                thumbnail = [(PSSObjectAttachment*)attachment thumbnail];
                
            } else if ([attachment isKindOfClass:[NSString class]]) {
                UIImage * imageObject = [UIImage imageWithContentsOfFile:attachment];
                
                // We need to create a new attachment object
                PSSObjectAttachment * attachmentObject = [self insertNewAttachmentInManagedObject];
                
                attachmentObject.decryptedBinaryContent = [PSSThumbnailMaker createPDFfromImage:imageObject];
                // Create the attachment a thumbnail
                
                thumbnail = [self insertNewDecorativeImageInManagedObject];
                thumbnail.viewportIdentifier = PSSDecorativeImageTypeThumbnail;
                thumbnail.data = [PSSThumbnailMaker thumbnailPNGImageDataFromImageAtURL:[NSURL fileURLWithPath:attachment] maxSize:450];
                attachmentObject.thumbnail = thumbnail;
                
                [setOfnewAttachments addObject:attachmentObject];
                
            }
            
            if (counter==0) {
                self.baseObject.thumbnail = thumbnail;
            }
            
            counter++;
        }
        
        version.attachments = (NSSet*)setOfnewAttachments;
    }

    
    
    
    
    // Save the object
    self.baseObject.currentVersion = version;
    
    
    
    
    
    NSError *error = nil;
    if (![self.baseObject.managedObjectContext save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"An error occured", nil) message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
        
    }
    
    if (creatingMode) {
       
        [self.navigationController dismissViewControllerAnimated:YES completion:NULL];
        
       
    } else {
        
        if (self.editorDelegate) {
            [self.editorDelegate objectEditor:self finishedWithObject:self.baseObject];
        }
        
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    
}


#pragma mark Custom methods

-(void)deleteAttachment:(id)attachment{
    
    if ([attachment isKindOfClass:[PSSObjectAttachment class]]) {
        // Actual attachment object
        
        // We won't delete it as it was saved with another version
        
    } else if ([attachment isKindOfClass:[NSString class]]) {
        // NSString is a path to large attachment image
        
        NSURL * pathURL = [NSURL fileURLWithPath:(NSString*)attachment];
        [[NSFileManager defaultManager] removeItemAtPath:(NSString*)pathURL error:nil];
        
        
    }
    [self.attachmentsArray removeObject:attachment];
    
    
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
    
}

-(void)cancelAction:(id)sender{
    
    [super cancelAction:sender];
    
    [self cleanupUnsavedFilesInAttachmentArray];
}

-(void)saveAction:(id)sender{
    [self saveChangesAndDismiss];
}

-(void)cleanupUnsavedFilesInAttachmentArray{
    
    for (id attachment in self.attachmentsArray) {
        
        if ([attachment isKindOfClass:[NSString class]]) {
            
            [[NSFileManager defaultManager] removeItemAtPath:(NSString*)attachment error:nil];
            
        }
        
    }
    
}

-(UIImage*)tableViewThumbnailForAttachment:(id)attachment{
    
    if ([attachment isKindOfClass:[PSSObjectAttachment class]]) {
        // Actual attachment object
        
        PSSObjectAttachment * objectAttachment = (PSSObjectAttachment*)attachment;
        
        UIImage * attachment = [UIImage imageWithData:objectAttachment.thumbnail.data];
        return attachment;
        
    } else if ([attachment isKindOfClass:[NSString class]]) {
        // NSString is a path to large attachment image
        
        NSURL * pathURL = [NSURL fileURLWithPath:(NSString*)attachment];
        
        UIImage * thumbnailImage = [PSSThumbnailMaker thumbnailImageFromImageAtURL:pathURL maxSize:[UIScreen mainScreen].scale*195.];
        return thumbnailImage;
    }
    
    return nil;
}


-(void)presentDocumentCapturer:(id)sender{
    
    
    MAImagePickerController *imagePicker = [[MAImagePickerController alloc] init];
    
    [imagePicker setDelegate:self];
    [imagePicker setSourceType:MAImagePickerControllerSourceTypeCamera];
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:imagePicker];
    
    navigationController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    
    [self presentViewController:navigationController animated:YES completion:NULL];
    
}

#pragma mark - UIViewController lifecycle

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
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"buttonCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"PSSNotesAttachmentTableViewCell" bundle:[NSBundle mainBundle]]  forCellReuseIdentifier:@"attachmentCell"];
    
    
    //UIBarButtonItem * saveButton =
    
    if (self.baseObject) {
        NSSortDescriptor * sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:YES];
        NSSet * attachments = [(PSSNoteVersion*)self.baseObject.currentHardLinkedVersion attachments];
        NSArray * arrayOfAttachments = [attachments sortedArrayUsingDescriptors:@[sortDescriptor]];
        self.attachmentsArray = [[NSMutableArray alloc] initWithArray:arrayOfAttachments];
    } else {
        NSMutableArray * mutableArray = [[NSMutableArray alloc] initWithCapacity:5];
        self.attachmentsArray = mutableArray;
    }
    
}

-(void)dealloc{
    [self cleanupUnsavedFilesInAttachmentArray];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section == 1) {
        return NSLocalizedString(@"Attachments", nil);
    } else if (section == 2) {
        return NSLocalizedString(@"Notes", nil);
    }
    return @"";
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section==1) {
        
        NSInteger firstButtonIndex = [self.attachmentsArray count];
        if (indexPath.row < firstButtonIndex) {
            
            return 215.;
            
        }
        
        
    } else if (indexPath.section == 2) {
        return 144.;
    }
    
    return 44.;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (section==0) {
        // Title
        return 1;
    } else if (section == 1) {
        // Attachments
        return [self.attachmentsArray count] + 1;
    } else if (section == 2) {
        // Notes
        return 1;
    }
    
    return 0;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    // Title cell
    if (indexPath.section == 0) {
        
        
        if (!self.titleCell) {
            
            PSSnewPasswordBasicTextFieldCell * titleCell = [[PSSnewPasswordBasicTextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            self.titleCell = titleCell;
            if (self.baseObject) {
                self.titleCell.textField.text = self.baseObject.displayName;
            }
            self.titleCell.textField.placeholder = NSLocalizedString(@"Title", nil);
            self.titleCell.selectionStyle = UITableViewCellSelectionStyleNone;
            
        }
        return self.titleCell;
        
    }
    
    
    // Attachments
    if (indexPath.section == 1) {
        // Before the button cells we must count the number of attachment objects to insert
        
        
        NSInteger firstButtonIndex = [self.attachmentsArray count];
        
        if (indexPath.row < firstButtonIndex) {
            // Attachments rows
            
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"attachmentCell" forIndexPath:indexPath];
            
            UIImage * attachmentThumbnail = [self tableViewThumbnailForAttachment:[self.attachmentsArray objectAtIndex:indexPath.row]];
            
            UIImageView * cellImageView = (UIImageView*)[cell viewWithTag:100];
            [cellImageView setImage:attachmentThumbnail];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            return cell;
            
            
        } else {
            // Buttons rows
            
            NSUInteger rowOfPresentButton = indexPath.row - [self.attachmentsArray count];
            
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"buttonCell" forIndexPath:indexPath];
            
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            if (rowOfPresentButton == 0) {
                // Scan camera
                
                cell.textLabel.text = NSLocalizedString(@"Capture Document", nil);
                
                UIImage * cameraImage = [UIImage imageNamed:@"Camera"];
                
                cell.imageView.image = [cameraImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                
                
            }
            
            return cell;
            
        }
        
        
    }
    
    
    
    // Notes
    if (indexPath.section == 2) {
        
        if (!self.notesCell) {
            
            PSSnewPasswordMultilineTextFieldCell * notesCell = [[PSSnewPasswordMultilineTextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            
            self.notesCell = notesCell;
            if (self.baseObject) {
                self.notesCell.textView.text = [(PSSNoteVersion*)self.baseObject.currentHardLinkedVersion decryptedNoteTextContent];
            }
            self.notesCell.selectionStyle =UITableViewCellSelectionStyleNone;
            
        }
        
        return self.notesCell;
        
        
    }
    
    
    
    return nil;
    
}

#pragma mark - UITableViewDelegate methods

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 1) {
        // Attachments section
        NSUInteger rowOfPresentButton = indexPath.row - [self.attachmentsArray count];
        
        if (indexPath.row < rowOfPresentButton) {
            // User selected a real attachment
        } else {
            // User tapped a button
            NSUInteger zeroIndexedRowOfPresentButton = indexPath.row - [self.attachmentsArray count];
            if (zeroIndexedRowOfPresentButton == 0) {
                // Capture document button
                
                [self presentDocumentCapturer:tableView];
                
            }
        }
        
        
    }
    
    
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES if you want the specified item to be editable.
    
    
    if (indexPath.section == 1) {
        
        NSInteger firstButtonIndex = [self.attachmentsArray count];
        if (indexPath.row < firstButtonIndex) {
            return YES;
        }
        
        
    }
    
    return NO;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //add code here for when you hit delete
        
        [self deleteAttachment:[self.attachmentsArray objectAtIndex:indexPath.row]];
        
    }
}


#pragma mark - MAImagePickerDelegate methods

- (void)imagePickerDidCancel
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerDidChooseImageWithPath:(NSString *)path
{
    [self dismissViewControllerAnimated:YES completion:^{
        if ([[NSFileManager defaultManager] fileExistsAtPath:path])
        {
            [self.attachmentsArray addObject:path];
            
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
        }

    }];
    

    
    
}



@end

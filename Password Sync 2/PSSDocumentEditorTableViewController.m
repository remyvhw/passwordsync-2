//
//  PSSNotesEditorTableViewController.m
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-07-25.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import "PSSDocumentEditorTableViewController.h"
#import "PSSnewPasswordBasicTextFieldCell.h"
#import "PSSnewPasswordMultilineTextFieldCell.h"
#import "PSSDocumentVersion.h"
#import "PSSObjectAttachment.h"
#import "PSSObjectDecorativeImage.h"
#import "PSSThumbnailMaker.h"
#import "PSSAppDelegate.h"
#import "TestFlight.h"

@interface PSSDocumentEditorTableViewController ()

@property (strong, nonatomic) PSSnewPasswordBasicTextFieldCell * titleCell;
@property (strong, nonatomic) PSSnewPasswordMultilineTextFieldCell * notesCell;
@property (strong, nonatomic) NSMutableArray * attachmentsArray;
@property (nonatomic) BOOL fileimport;

@end

@implementation PSSDocumentEditorTableViewController

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

-(PSSDocumentVersion*)insertNewNoteVersionInManagedObject{
    
    PSSAppDelegate * appDelegate = (PSSAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    PSSDocumentVersion *newManagedObject = (PSSDocumentVersion*)[NSEntityDescription insertNewObjectForEntityForName:@"PSSDocumentVersion" inManagedObjectContext:context];
    
    // We'll automatically timestamp it
    newManagedObject.timestamp = [NSDate date];
    
    return newManagedObject;
    
}

-(PSSDocumentBaseObject*)insertNewNoteInManagedObject{
    
    PSSAppDelegate * appDelegate = (PSSAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    PSSDocumentBaseObject *newManagedObject = (PSSDocumentBaseObject*)[NSEntityDescription insertNewObjectForEntityForName:@"PSSDocumentBaseObject" inManagedObjectContext:context];
    
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
    
    PSSDocumentVersion * version = [self insertNewNoteVersionInManagedObject];
    
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
                
            } else if ([attachment isKindOfClass:[NSURL class]]) {
                // We need to create a new attachment object
                PSSObjectAttachment * attachmentObject = [self insertNewAttachmentInManagedObject];

                
                if (self.fileimport) {
                    
                    // We keep other imported documents as is
                    attachmentObject.decryptedBinaryContent = [NSData dataWithContentsOfURL:attachment];
                    // Create the attachment a thumbnail
                    
                    attachmentObject.fileExtension = [attachment pathExtension];
                    
                } else {
                    
                    // Image captured
                    UIImage * imageObject = [UIImage imageWithData:[NSData dataWithContentsOfURL:attachment]];
                    
                    // We convert snapped photos to PDF
                    attachmentObject.decryptedBinaryContent = [PSSThumbnailMaker createPDFfromImage:imageObject];
                    // Create the attachment a thumbnail
                    
                    attachmentObject.fileExtension = @"pdf";
                }
                
                
                thumbnail = [self insertNewDecorativeImageInManagedObject];
                thumbnail.viewportIdentifier = PSSDecorativeImageTypeThumbnail;
                thumbnail.data = [PSSThumbnailMaker thumbnailPNGImageDataFromImageAtURL:attachment maxSize:450];
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
#ifdef DEBUG
#else
            [TestFlight passCheckpoint:@"DOCUMENT_CREATED"];
#endif
        }];
        
       
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
        
    } else if ([attachment isKindOfClass:[NSURL class]]) {
        // NSString is a path to large attachment image
        
        [[NSFileManager defaultManager] removeItemAtURL:attachment error:NULL];
        
        
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
        
        if ([attachment isKindOfClass:[NSURL class]]) {
            
            [[NSFileManager defaultManager] removeItemAtURL:attachment error:NULL];
            
        }
        
    }
    
}

-(UIImage*)tableViewThumbnailForAttachment:(id)attachment{
    
    if ([attachment isKindOfClass:[PSSObjectAttachment class]]) {
        // Actual attachment object
        
        PSSObjectAttachment * objectAttachment = (PSSObjectAttachment*)attachment;
        
        UIImage * attachment = [UIImage imageWithData:objectAttachment.thumbnail.data];
        return attachment;
        
    } else if ([attachment isKindOfClass:[NSURL class]]) {
        // NSString is a path to large attachment image
        
        UIImage * thumbnailImage = [PSSThumbnailMaker thumbnailImageFromImageAtURL:attachment maxSize:[UIScreen mainScreen].scale*195.];
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

-(id)initWithDocumentURL:(NSURL *)documentURL{
    if (self = [super initWithStyle:UITableViewStyleGrouped]) {
        
        self.fileimport = YES;
        self.attachmentsArray = [[NSMutableArray alloc] initWithObjects:documentURL, nil];
        
        
        
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
    
    if (!self.attachmentsArray) {
        if (self.baseObject) {
            NSSortDescriptor * sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:YES];
            NSSet * attachments = [(PSSDocumentVersion*)self.baseObject.currentHardLinkedVersion attachments];
            NSArray * arrayOfAttachments = [attachments sortedArrayUsingDescriptors:@[sortDescriptor]];
            self.attachmentsArray = [[NSMutableArray alloc] initWithArray:arrayOfAttachments];
        } else {
            NSMutableArray * mutableArray = [[NSMutableArray alloc] initWithCapacity:5];
            self.attachmentsArray = mutableArray;
        }
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
    } else if (section==3) {
        return NSLocalizedString(@"Advanced", nil);
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
    return 5;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (section==0) {
        // Title
        return 1;
    } else if (section == 1) {
        // Attachments
        if (self.fileimport) {
            // When we file import, we don't show a picture scanner button
            return [self.attachmentsArray count];
        }
        return [self.attachmentsArray count] + 1;
    } else if (section==2) {
        // Notes
        return 1;
    } else if (section == 3) {
        // Advanced
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
                self.notesCell.textView.text = [(PSSDocumentVersion*)self.baseObject.currentHardLinkedVersion decryptedNoteTextContent];
            }
            self.notesCell.selectionStyle =UITableViewCellSelectionStyleNone;
            
        }
        
        return self.notesCell;
        
        
    }
    
    // Advanced
    if (indexPath.section == 3) {
        
        // Tags
        if (indexPath.row==0) {
            return self.tagsTableViewCell;
        }
        
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
        
        
    } else if (indexPath.section == 3) {
        
       // Advanced
        
        if (indexPath.row ==0) {
            
            [self presentTagSelectorViewController];
            
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
            NSURL * pathURL = [NSURL fileURLWithPath:(NSString*)path];
            [self.attachmentsArray addObject:pathURL];
            
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
        }

    }];
    

    
    
}



@end

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


@interface PSSNotesEditorTableViewController ()

@property (strong, nonatomic) PSSnewPasswordBasicTextFieldCell * titleCell;
@property (strong, nonatomic) PSSnewPasswordMultilineTextFieldCell * notesCell;
@property (strong, nonatomic) NSMutableArray * attachmentsArray;

@end

@implementation PSSNotesEditorTableViewController

-(void)deleteAttachment:(id)attachment{
    
    if ([attachment isKindOfClass:[PSSObjectAttachment class]]) {
        // Actual attachment object
        
        PSSObjectAttachment * objectAttachment = (PSSObjectAttachment*)attachment;
        
        [objectAttachment.managedObjectContext deleteObject:objectAttachment];
        
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
                //self.titleCell.textField.text = self.passwordBaseObject.displayName;
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
                //self.notesCell.textView.text = [self.passwordBaseObject.currentVersion decryptedNotes];
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

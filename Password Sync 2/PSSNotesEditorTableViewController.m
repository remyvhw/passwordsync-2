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

@interface PSSNotesEditorTableViewController ()

@property (strong, nonatomic) PSSnewPasswordBasicTextFieldCell * titleCell;
@property (strong, nonatomic) PSSnewPasswordMultilineTextFieldCell * notesCell;
@property (strong, nonatomic) NSMutableArray * attachmentsArray;

@end

@implementation PSSNotesEditorTableViewController

-(void)presentDocumentCapturer:(id)sender{
    
    
    MAImagePickerController *imagePicker = [[MAImagePickerController alloc] init];
    
    [imagePicker setDelegate:self];
    [imagePicker setSourceType:MAImagePickerControllerSourceTypeCamera];
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:imagePicker];
    
    navigationController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    
    [self presentViewController:navigationController animated:YES completion:NULL];
    
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
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"buttonCell"];
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
    
    if (indexPath.section == 2) {
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
        return 1;
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
        
        
        NSInteger firstButtonIndex = [self.attachmentsArray count] - 1;
        
        if (indexPath.row < firstButtonIndex) {
            // Attachments rows
            
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

#pragma mark - MAImagePickerDelegate methods

- (void)imagePickerDidCancel
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerDidChooseImageWithPath:(NSString *)path
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:path])
    {
        NSLog(@"File Found at %@", path);
        
    }
    else
    {
        NSLog(@"No File Found at %@", path);
    }
    
    [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
}



@end

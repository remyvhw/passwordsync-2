//
//  PSSNotesDetailCollectionViewController.m
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-07-27.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import "PSSNotesDetailCollectionViewController.h"
#import "PSSNoteBaseObject.h"
#import "PSSNoteVersion.h"
#import "PSSObjectAttachment.h"
#import "PSSObjectDecorativeImage.h"
#import "PSSExtentedNoteViewController.h"
#import "UIImage+ImageEffects.h"
#import "PSSNotesEditorTableViewController.h"

@interface PSSNotesDetailCollectionViewController ()

@property (nonatomic, strong) NSArray * attachments;

@end

@implementation PSSNotesDetailCollectionViewController
dispatch_queue_t backgroundQueue;

-(void)editorAction:(id)sender{
    
    PSSNotesEditorTableViewController * notesEditor = [[PSSNotesEditorTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    
    notesEditor.editorDelegate = self;
    notesEditor.baseObject = self.detailItem;
    
    [self.navigationController pushViewController:notesEditor animated:YES];
    
    
}


-(void)buildAttachmentList{
    
    NSSortDescriptor * sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:YES];
    
    NSArray * sortedAttachments = [self.detailItem.currentHardLinkedVersion.attachments sortedArrayUsingDescriptors:@[sortDescriptor]];
    
    self.attachments = sortedAttachments;
    
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
    
    backgroundQueue = dispatch_queue_create("com.pumaxprod.iOS.PasswordSync-2.notesCollectionViewBackgroundThread", NULL);

    
    self.collectionView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    [self buildAttachmentList];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if ([[segue identifier] isEqualToString:@"extendedPlainTextNoteSegue"]) {
        [[segue destinationViewController] setDetailItem:self.detailItem];
    }
    
}

-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender{
    
    if ([identifier isEqualToString:@"extendedPlainTextNoteSegue"]) {
        
        if (!self.isPasscodeUnlocked) {
            
            [self showUnlockingViewController];
            
            return NO;
        }
        
        // Check that we have a note to show.
        NSString * decryptedNote = [(PSSNoteVersion*)self.detailItem.currentHardLinkedVersion decryptedNoteTextContent];
        
        if (!decryptedNote || [decryptedNote isEqualToString:@""]) {
            return NO;
        }
        
    }
    
    return YES;
}

#pragma mark - UICollectionViewDataSource methods


- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    
    if ([kind isEqual:UICollectionElementKindSectionHeader]) {
        UICollectionReusableView * collectionReusableView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"titleReusableView" forIndexPath:indexPath];
        UILabel * label = (UILabel*)[collectionReusableView viewWithTag:1];
        label.text = self.detailItem.displayName;
        return collectionReusableView;

    } else if ([kind isEqual:UICollectionElementKindSectionFooter]){
        
        UICollectionReusableView * collectionReusableView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"noteReusableView" forIndexPath:indexPath];
        UILabel * label = (UILabel*)[collectionReusableView viewWithTag:1];
        UIImageView * accessoryView = (UIImageView*)[collectionReusableView viewWithTag:2];
        
        
        NSString * decryptedNote = [(PSSNoteVersion*)self.detailItem.currentHardLinkedVersion decryptedNoteTextContent];
        
        if (decryptedNote && ![decryptedNote isEqualToString:@""]) {
            if (self.isPasscodeUnlocked) {
                [accessoryView setImage:[[UIImage imageNamed:@"Chevron"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
                label.textColor = [UIColor darkTextColor];
                label.text = decryptedNote;
            } else {
                [accessoryView setImage:[[UIImage imageNamed:@"SmallLock"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
                label.textColor = [UIColor lightGrayColor];
                label.text = NSLocalizedString(@"Locked", nil);
            }
        } else {
            label.text = NSLocalizedString(@"No Notes", nil);
            label.textColor = [UIColor lightGrayColor];
            label.textAlignment = NSTextAlignmentCenter;

        }

        
        return collectionReusableView;
        
    }
    return nil;
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.attachments.count;
}

-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"attachmentCollectionViewCell" forIndexPath:indexPath];
    
    PSSObjectAttachment * attachmentAtIndex = [self.attachments objectAtIndex:indexPath.row];
    PSSObjectDecorativeImage * thumbnail = attachmentAtIndex.thumbnail;
    
    UIImageView * imageView = (UIImageView*)[cell viewWithTag:100];
    UIImageView * lockImageView = (UIImageView*)[cell viewWithTag:2];
    
    UIImage * contentImage;
    if (self.isPasscodeUnlocked) {
        [lockImageView setImage:nil];
        
        contentImage = thumbnail.imageNormal;
        imageView.image = contentImage;
    } else {
        
        [lockImageView setImage:[[UIImage imageNamed:@"LargeLock"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
        
        // We blur the image
        dispatch_async(backgroundQueue, ^(void) {
            
            UIImage * blurredThumbnail = thumbnail.imageLightEffect;
            
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                
                [imageView setAlpha:0.0];
                imageView.image = blurredThumbnail;
                [UIView animateWithDuration:0.1 animations:^{
                    [imageView setAlpha:1.0];
                }];
                
                
            });
            
        });
        
    }
    
    
    
    return cell;
}

#pragma mark - UICollectionViewDelegate methods

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if (!self.isPasscodeUnlocked) {
        [self showUnlockingViewController];
        return;
    }
    
    
}

@end

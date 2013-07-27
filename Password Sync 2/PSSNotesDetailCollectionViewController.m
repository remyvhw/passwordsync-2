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
        
        NSLog(@"%@", [accessoryView description]);
        
        if (self.isPasscodeUnlocked) {
            [accessoryView setImage:[[UIImage imageNamed:@"Chevron"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
            label.textColor = [UIColor darkTextColor];
            label.text = [(PSSNoteVersion*)self.detailItem.currentHardLinkedVersion decryptedNoteTextContent];
        } else {
            [accessoryView setImage:[[UIImage imageNamed:@"SmallLock"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
            label.textColor = [UIColor lightGrayColor];
            label.text = NSLocalizedString(@"Locked", nil);
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
    
    UIImage * contentImage;
    if (self.isPasscodeUnlocked) {
        contentImage = thumbnail.imageNormal;
    } else {
        // We blur the image
        contentImage = thumbnail.imageLightEffect;
    }
    
    imageView.image = contentImage;
    
    return cell;
}

#pragma mark - UICollectionViewDelegate methods

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"%@", [indexPath description]);
}

@end

//
//  PSSVersionFlowGenericControllerViewController.m
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-08-06.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import "PSSVersionFlowGenericControllerViewController.h"
#import "UIImage+ImageEffects.h"
#import "PSSVersionsCollectionViewFlowLayout.h"
#import "PSSBaseObjectVersion.h"

@interface PSSVersionFlowGenericControllerViewController ()

@property (strong, nonatomic) PSSVersionGenericCollectionViewCell * currentlyOpenedCell;

@end

@implementation PSSVersionFlowGenericControllerViewController


-(void)deleteVersionForCell:(PSSVersionGenericCollectionViewCell *)cell{
    
    
    
    [UIView animateWithDuration:0.3 animations:^{
        
        [cell setAlpha:0.0];
        
        [UIView performWithoutAnimation:^{
            NSInteger indexOfCell = [self.collectionView indexPathForCell:cell].row;
            PSSBaseObjectVersion * version = [self.orderedVersions objectAtIndex:indexOfCell];
            NSManagedObjectContext * context = version.managedObjectContext;
            [context deleteObject:version];
            [context save:NULL];
        }];
        
    } completion:^(BOOL finished) {
        [self.navigationController popViewControllerAnimated:YES];

    }];
    
    [self hideBacksideViewForCell:cell completion:^{
        
        
        
        
    }];
    
}

-(void)restoreVersionForCell:(PSSVersionGenericCollectionViewCell *)cell{
    
}

-(void)deleteVersionByPressingButton:(UIButton *)sender{
    [self deleteVersionForCell:self.currentlyOpenedCell];
}

-(void)restoreVersionByPressingButton:(UIButton *)sender{
    [self restoreVersionForCell:self.currentlyOpenedCell];
}

- (UIImage *) imageWithView:(UIView *)view
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, 0.f);
    [view drawViewHierarchyInRect:view.frame afterScreenUpdates:NO];
    UIImage *snapshot = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    return snapshot;
}


-(void)hideBacksideViewForCell:(PSSVersionGenericCollectionViewCell *)cell completion:(void(^)(void))completionBlock{
    
    self.currentlyOpenedCell = nil;
    
    UIView * controlView = [cell.subviews lastObject];
    
    [UIView animateWithDuration:0.4 animations:^{
        [controlView setAlpha:0.0];
    } completion:^(BOOL finished) {
        [controlView removeFromSuperview];
        if (completionBlock) {
            completionBlock();
        }
        
    }];
    
}

-(void)hideBacksideViewForCell:(PSSVersionGenericCollectionViewCell *)cell{
    
    
}

-(void)hideBacksideViewByPressingButton:(UIButton*)sender {
    PSSVersionGenericCollectionViewCell * owningCell = (PSSVersionGenericCollectionViewCell*)sender.superview.superview;
    
    [self hideBacksideViewForCell:owningCell];

}

-(void)showBacksideViewForCell:(PSSVersionGenericCollectionViewCell*)cell{
    
    if (self.currentlyOpenedCell) {
        [self hideBacksideViewForCell:self.currentlyOpenedCell];
    }
    
    self.currentlyOpenedCell = cell;
    
    UIImage * snapshottedImage = [self imageWithView:[cell.subviews firstObject]];
    
    
    NSArray* nib = [[NSBundle mainBundle] loadNibNamed:@"PSSVersionBacksideView" owner:self options:nil];
    [[nib objectAtIndex:0] setFrame:CGRectMake(0, 0, cell.bounds.size.width, cell.bounds.size.height)];
    UIView * controlView = [nib objectAtIndex:0];
    
    
    UIButton * controlRestoreButton = (UIButton*)[controlView viewWithTag:2];
    [controlRestoreButton addTarget:self action:@selector(restoreVersionByPressingButton:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton * controlDeleteButton = (UIButton*)[controlView viewWithTag:1];
    [controlDeleteButton addTarget:self action:@selector(deleteVersionByPressingButton:) forControlEvents:UIControlEventTouchUpInside];
    
    UIImageView * controlBackground = (UIImageView*)[controlView viewWithTag:995];
    
    
    controlBackground.image = [snapshottedImage applyExtraLightEffect];
    
    [controlView setAlpha:0.0];
    [cell addSubview:controlView];
    
    [UIView animateWithDuration:0.4 animations:^{
        [controlView setAlpha:1.0];
    }];
}

-(void)showBacksideViewByPressingButton:(UIButton*)sender{
    
    PSSVersionGenericCollectionViewCell * owningCell = (PSSVersionGenericCollectionViewCell*)sender.superview.superview;
    
    [self showBacksideViewForCell:owningCell];
}

-(void)configureCollectionViewFlowLayout{
    
    PSSVersionsCollectionViewFlowLayout * flowLayout = (PSSVersionsCollectionViewFlowLayout*)self.collectionView.collectionViewLayout;
    [flowLayout setSectionInset:UIEdgeInsetsMake(40., 0, 40, 0)];
    [flowLayout setMinimumLineSpacing:40];
    [flowLayout setItemSize:CGSizeMake(280., 287.)];
    
}

-(void)orderVersionsForBaseObject{
    NSSortDescriptor * descriptor = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:YES];
    self.orderedVersions = [self.detailItem.versions sortedArrayUsingDescriptors:@[descriptor]];
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
    // Do any additional setup after loading the view from its nib.
    
    self.backgroundQueue = dispatch_queue_create([[NSString stringWithFormat:@"%@.versionsDataDecryptor", [[NSBundle mainBundle] bundleIdentifier]] cStringUsingEncoding:NSUTF8StringEncoding], NULL);

    
    [self orderVersionsForBaseObject];
    
    if (!self.backgroundImage.image) {
        self.backgroundImage.image = [self.detailItem.decorativeImageForDevice applyLightEffect];
    }
    
    // We'll only use one single date formatter since allocating one is pretty ressource intensive.
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterLongStyle];
    [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    
    self.dateFormatter = dateFormatter;
    

    [self configureCollectionViewFlowLayout];
    
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    
    CGFloat padding = MIN(320, (self.view.frame.size.width-320.)/2);
    self.collectionView.contentInset = UIEdgeInsetsMake(64, padding, 49, padding);
    
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        NSInteger numberOfCells = self.orderedVersions.count;
        NSIndexPath * lastCollectionCell = [NSIndexPath indexPathForRow:numberOfCells-1 inSection:0];

        PSSVersionsCollectionViewFlowLayout * flowLayout = (PSSVersionsCollectionViewFlowLayout*)self.collectionView.collectionViewLayout;

        flowLayout.preventBounce = YES;
        [self.collectionView scrollToItemAtIndexPath:lastCollectionCell atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:NO];
        
        flowLayout.preventBounce = NO;

    }
    
    
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionViewDataSource

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [self.detailItem.versions count];
}

-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    return nil;
}

#pragma mark - UICollectionViewDatasource

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    
    if (self.currentlyOpenedCell) {
        [self hideBacksideViewForCell:self.currentlyOpenedCell];
    }
    
}



@end

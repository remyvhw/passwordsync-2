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

@interface PSSVersionFlowGenericControllerViewController ()

@end

@implementation PSSVersionFlowGenericControllerViewController

-(void)configureCollectionViewFlowLayout{
    
    PSSVersionsCollectionViewFlowLayout * flowLayout = (PSSVersionsCollectionViewFlowLayout*)self.collectionView.collectionViewLayout;
    [flowLayout setSectionInset:UIEdgeInsetsMake(40., 0, 40, 0)];
    [flowLayout setMinimumLineSpacing:40];
    [flowLayout setItemSize:CGSizeMake(280., 287.)];
    
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
    
    NSSortDescriptor * descriptor = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:YES];
    self.orderedVersions = [self.detailItem.versions sortedArrayUsingDescriptors:@[descriptor]];
    
    if (!self.backgroundImage.image) {
        self.backgroundImage.image = [self.detailItem.decorativeImageForDevice applyLightEffect];
    }
    
    self.collectionView.contentInset = UIEdgeInsetsMake(64., 0, 49., 0);
    [self configureCollectionViewFlowLayout];
    
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        NSInteger numberOfCells = 10;//self.orderedVersions.count;
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
    return 0;
}

-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    return nil;
}




@end

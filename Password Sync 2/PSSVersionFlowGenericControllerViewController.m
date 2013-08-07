//
//  PSSVersionFlowGenericControllerViewController.m
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-08-06.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import "PSSVersionFlowGenericControllerViewController.h"
#import "UIImage+ImageEffects.h"

@interface PSSVersionFlowGenericControllerViewController ()

@end

@implementation PSSVersionFlowGenericControllerViewController

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
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    NSInteger numberOfCells = 10;//self.orderedVersions.count;
    NSIndexPath * lastCollectionCell = [NSIndexPath indexPathForRow:numberOfCells-1 inSection:0];
    
    [self.collectionView scrollToItemAtIndexPath:lastCollectionCell atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:NO];
    
    
    
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

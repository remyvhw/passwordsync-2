//
//  PSSCSVColumnSelectorCollectionViewController.m
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-10-01.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import "PSSCSVColumnSelectorCollectionViewController.h"
#import "PSSCSVColumnCollectionViewCell.h"

@interface PSSCSVColumnSelectorCollectionViewController ()

@end

@implementation PSSCSVColumnSelectorCollectionViewController

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
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"PSSCSVColumnCollectionViewCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"columnCollectionViewCell"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"PSSCSVColumnCollectionHeaderReusableView" bundle:[NSBundle mainBundle]] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"PSSCSVColumnHeaderView"];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionViewDataSource

-(UICollectionReusableView*)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        
        UICollectionReusableView * reusableHeader = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"PSSCSVColumnHeaderView" forIndexPath:indexPath];
        
        UILabel * titleLabel = (UILabel*)[reusableHeader viewWithTag:1];
        
        titleLabel.text = NSLocalizedString(@"Title", nil);
        
        return reusableHeader;
    }
    return nil;
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 0;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return 0;
}

-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    
    return nil;
}


@end

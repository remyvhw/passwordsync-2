//
//  PSSCSVColumnTableViewCell.m
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-10-03.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import "PSSCSVColumnTableViewCell.h"
#import "PSSCSVImporterCSVColumnCollectionViewCell.h"

@implementation PSSCSVColumnTableViewCell


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (!(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) return nil;
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.sectionInset = UIEdgeInsetsMake(10, 0, 9, 0);
    layout.minimumInteritemSpacing = 0;
    layout.minimumLineSpacing = 0;
    layout.itemSize = CGSizeMake(self.bounds.size.width, 370);
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.collectionView = [[PSSCSVColumnIndexedCollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    self.collectionView.pagingEnabled = YES;
    [self.collectionView registerClass:[PSSCSVImporterCSVColumnCollectionViewCell class] forCellWithReuseIdentifier:CollectionViewCellIdentifier];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.showsHorizontalScrollIndicator = NO;
    [self.contentView addSubview:self.collectionView];
    
    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    self.collectionView.frame = self.contentView.bounds;
}

-(void)setCollectionViewDataSourceDelegate:(id<UICollectionViewDataSource, UICollectionViewDelegate>)dataSourceDelegate index:(NSInteger)index
{
    self.collectionView.dataSource = dataSourceDelegate;
    self.collectionView.delegate = dataSourceDelegate;
    self.collectionView.index = index;
    [self.collectionView reloadData];
}


@end

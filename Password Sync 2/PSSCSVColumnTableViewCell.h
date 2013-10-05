//
//  PSSCSVColumnTableViewCell.h
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-10-03.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSSCSVColumnIndexedCollectionView.h"

static NSString *CollectionViewCellIdentifier = @"CollectionViewCellIdentifier";

@interface PSSCSVColumnTableViewCell : UITableViewCell

@property (nonatomic, strong) PSSCSVColumnIndexedCollectionView *collectionView;

-(void)setCollectionViewDataSourceDelegate:(id<UICollectionViewDataSource, UICollectionViewDelegate>)dataSourceDelegate index:(NSInteger)index;


@end

//
//  PSSCSVImporterCSVColumnCollectionViewCell.h
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-10-03.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PSSCSVImporterCSVColumnCollectionViewCell : UICollectionViewCell


@property (nonatomic, strong) UILabel * columnIndicator;
@property (nonatomic, strong) UILabel * columnContent;
@property (nonatomic) BOOL emptyColumn;

@end

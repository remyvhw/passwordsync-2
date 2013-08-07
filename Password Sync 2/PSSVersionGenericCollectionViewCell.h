//
//  PSSVersionGenericCollectionViewCell.h
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-08-06.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PSSVersionGenericCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIButton *infoButton;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@property BOOL currentVersion;

@end

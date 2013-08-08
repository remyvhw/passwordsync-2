//
//  PSSVersionsCollectionViewFlowLayout.h
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-08-07.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PSSVersionsCollectionViewFlowLayout : UICollectionViewFlowLayout

@property BOOL preventBounce;
@property (strong, nonatomic) UIDynamicAnimator * dynamicAnimator;


@end

//
//  PSSVersionFlowGenericControllerViewController.h
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-08-06.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSSBaseGenericObject.h"

@interface PSSVersionFlowGenericControllerViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) PSSBaseGenericObject * detailItem;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImage;

@property (nonatomic, strong) NSArray * orderedVersions;

-(void)configureCollectionViewFlowLayout;

@end

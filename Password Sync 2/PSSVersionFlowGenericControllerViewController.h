//
//  PSSVersionFlowGenericControllerViewController.h
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-08-06.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSSBaseGenericObject.h"
#import "PSSVersionGenericCollectionViewCell.h"
#import "PSSObjectEditorProtocol.h"

@interface PSSVersionFlowGenericControllerViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) PSSBaseGenericObject * detailItem;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImage;
@property (weak, nonatomic) id<PSSObjectEditorProtocol> editorDelegate;

@property (nonatomic, strong) NSArray * orderedVersions;
@property (nonatomic, strong) NSDateFormatter * dateFormatter;

@property dispatch_queue_t backgroundQueue;

-(void)showBacksideViewByPressingButton:(UIButton*)sender;
-(void)showBacksideViewForCell:(PSSVersionGenericCollectionViewCell*)cell;
-(void)hideBacksideViewByPressingButton:(UIButton*)sender;
-(void)hideBacksideViewForCell:(PSSVersionGenericCollectionViewCell*)cell;

-(void)restoreVersionForCell:(PSSVersionGenericCollectionViewCell*)cell;
-(void)deleteVersionForCell:(PSSVersionGenericCollectionViewCell*)cell;

-(void)configureCollectionViewFlowLayout;

@end

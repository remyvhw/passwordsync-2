//
//  PSSGenericEditorCollectionViewController.m
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-07-27.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import "PSSGenericDetailCollectionViewController.h"

@interface PSSGenericDetailCollectionViewController ()

@end

@implementation PSSGenericDetailCollectionViewController

-(void)userDidUnlockWithPasscode{
    [super userDidUnlockWithPasscode];
    [self.collectionView reloadData];
}

-(void)lockUIAction:(id)notification{
    [super lockUIAction:notification];
    [self.collectionView reloadData];
}

-(void)datastoreHasBeenUpdated:(id)sender{
    [self.collectionView reloadData];
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
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionViewDataSource methods

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 0;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return 0;
}

-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"collectionCell" forIndexPath:indexPath];
    return cell;
}


#pragma mark - PSSObjectEditorProtocol methods

-(void)objectEditor:(id)editor finishedWithObject:(PSSBaseGenericObject *)genericObject{
    [super objectEditor:editor finishedWithObject:genericObject];
    [self.collectionView reloadData];
}


@end

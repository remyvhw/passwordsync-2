//
//  PSSVersionFlowPasswordCollectionViewController.m
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-08-06.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import "PSSVersionFlowPasswordCollectionViewController.h"
#import "PSSVersionGenericCollectionViewCell.h"

@interface PSSVersionFlowPasswordCollectionViewController ()

@end

@implementation PSSVersionFlowPasswordCollectionViewController

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
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"PSSVersionPasswordCollectionViewCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"passwordVersionCell"];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionViewDataSource


-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return 10;
}

-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    PSSVersionGenericCollectionViewCell * cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"passwordVersionCell" forIndexPath:indexPath];
    
    
    cell.dateLabel.text = [[NSDate date] description];
    
    return cell;
}


@end

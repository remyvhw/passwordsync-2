//
//  PSSCSVColumnSelectorCollectionViewController.m
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-10-01.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import "PSSCSVColumnSelectorCollectionViewController.h"
#import "PSSCSVColumnCollectionViewCell.h"
#import "PSSCSVImporterNavigationController.h"


@interface PSSCSVColumnSelectorCollectionViewController ()

@end

@implementation PSSCSVColumnSelectorCollectionViewController



-(NSArray*)fieldsForDataType{
    
    
    NSArray * websiteArray = @[NSLocalizedString(@"Title", nil), NSLocalizedString(@"Username", nil), NSLocalizedString(@"Password", nil), NSLocalizedString(@"URL", nil), NSLocalizedString(@"Notes", nil)];
    
    
    return websiteArray;
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
    // Do any additional setup after loading the view from its nib.
    
    NSLog(@"%@", [self.collectionView description]);
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"columnCollectionViewCell"];
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
    
    UICollectionReusableView * reusableHeader = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"PSSCSVColumnHeaderView" forIndexPath:indexPath];
        
    UILabel * titleLabel = (UILabel*)[reusableHeader viewWithTag:1];
        
    titleLabel.text = [[self fieldsForDataType] objectAtIndex:indexPath.section];
        
    return reusableHeader;
    
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    PSSCSVImporterNavigationController * navigationController = (PSSCSVImporterNavigationController*)self.navigationController;

    if (navigationController.lines.count < 1) {
        // The array is empty
        return 0;
    }
    
    return [[navigationController.lines objectAtIndex:0] count];
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [self fieldsForDataType].count;
}

-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    
    PSSCSVColumnCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"columnCollectionViewCell" forIndexPath:indexPath];
    
    
    
    
    
    return cell;
}


@end

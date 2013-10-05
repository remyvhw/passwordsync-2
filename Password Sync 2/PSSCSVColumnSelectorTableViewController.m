//
//  PSSCSVColumnSelectorTableViewController.m
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-10-03.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import "PSSCSVColumnSelectorTableViewController.h"
#import "PSSCSVImporterNavigationController.h"
#include "PSSCSVColumnTableViewCell.h"
#import "PSSCSVImporterCSVColumnCollectionViewCell.h"

@interface PSSCSVColumnSelectorTableViewController ()

@property (nonatomic, strong) NSMutableDictionary *contentOffsetDictionary;
@property (nonatomic, strong, readonly) NSArray * columnContent;

@end

@implementation PSSCSVColumnSelectorTableViewController
@synthesize columnContent = _columnContent;

-(void)doneButtonPressed:(id)sender{
    
    PSSCSVImporterNavigationController * navigationController = (PSSCSVImporterNavigationController*)self.navigationController;
    
    [navigationController endWithDataArrangment:self.contentOffsetDictionary];
    
}

-(NSArray*)columnContent{
    
    if (!_columnContent) {
        
        PSSCSVImporterNavigationController * navigationController = (PSSCSVImporterNavigationController*)self.navigationController;
        
        NSUInteger countOfColumns = [[navigationController.lines objectAtIndex:0] count];
        
        NSMutableArray * arrayOfColumnsStrings = [[NSMutableArray alloc] initWithCapacity:countOfColumns];
        
        NSUInteger i = 0;
        while (i<countOfColumns) {
            
            // Go through the column at index 'i' and generate a string
            
            __block NSMutableString * columnValues = [[NSMutableString alloc] init];
            
            [navigationController.lines enumerateObjectsUsingBlock:^(NSArray * line, NSUInteger idx, BOOL *stop) {
                
                // For each line, we get the string for the column
                
                NSString * columnForLine = [NSString stringWithFormat:@"%@", [line objectAtIndex:i]];
                
                [columnValues appendString:columnForLine];
                
                if (idx >= 13) {
                    // We break the loop after 6 lines
                    [columnValues appendString:@"\n..."];
                    *stop = YES;
                } else {
                    // We add a line return
                    [columnValues appendString:@"\n"];
                };
                
            }];
            [arrayOfColumnsStrings addObject:columnValues];
            i++;
        }
        
        _columnContent = arrayOfColumnsStrings;
        
    }
    
    return _columnContent;
}

-(NSArray*)fieldsForDataType{
    
    PSSCSVImporterNavigationController * navController = (PSSCSVImporterNavigationController*)self.navigationController;
    
    NSArray* appropriateArray = [navController fieldsForDataType];
    
    return appropriateArray;
}

-(void)loadView
{
    [super loadView];
    
    const NSInteger numberOfTableViewRows = 20;
    const NSInteger numberOfCollectionViewCells = 15;
    
    NSMutableArray *mutableArray = [NSMutableArray arrayWithCapacity:numberOfTableViewRows];
    
    for (NSInteger tableViewRow = 0; tableViewRow < numberOfTableViewRows; tableViewRow++)
    {
        NSMutableArray *colorArray = [NSMutableArray arrayWithCapacity:numberOfCollectionViewCells];
        
        for (NSInteger collectionViewItem = 0; collectionViewItem < numberOfCollectionViewCells; collectionViewItem++)
        {
            
            CGFloat red = arc4random() % 255;
            CGFloat green = arc4random() % 255;
            CGFloat blue = arc4random() % 255;
            UIColor *color = [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:1.0f];
            
            [colorArray addObject:color];
        }
        
        [mutableArray addObject:colorArray];
    }
    
    
    self.contentOffsetDictionary = [[NSMutableDictionary alloc] initWithCapacity:[self fieldsForDataType].count];
    
    NSInteger i = 0;
    while (i<[self fieldsForDataType].count) {
        self.contentOffsetDictionary[[@(i) stringValue]] = @(0);
        i++;
    }
    
    
}

-(void)viewDidLoad{
    [super viewDidLoad];
    
    UIBarButtonItem * doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonPressed:)];
    
    self.navigationItem.rightBarButtonItem = doneButton;
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return [[self fieldsForDataType] objectAtIndex:section];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    return [self fieldsForDataType].count;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellIdentifier";
    
    PSSCSVColumnTableViewCell *cell = (PSSCSVColumnTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell)
    {
        cell = [[PSSCSVColumnTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    
    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(PSSCSVColumnTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setCollectionViewDataSourceDelegate:self index:indexPath.section];
    NSInteger index = cell.collectionView.index;
    int horizontalOffset = [self.contentOffsetDictionary[[@(index) stringValue]] integerValue];
    [cell.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:horizontalOffset inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
    //[cell.collectionView setContentOffset:CGPointMake(horizontalOffset, 0)];
}

#pragma mark - UITableView Delegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 390;
}

#pragma mark - UICollectionViewDataSource Methods

-(NSInteger)collectionView:(PSSCSVColumnIndexedCollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    PSSCSVImporterNavigationController * navigationController = (PSSCSVImporterNavigationController*)self.navigationController;
    
    if (navigationController.lines.count < 1) {
        // The array is empty
        return 0;
    }
    
    return [[navigationController.lines objectAtIndex:0] count]+1;
}

-(UICollectionViewCell *)collectionView:(PSSCSVColumnIndexedCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PSSCSVImporterNavigationController * navigationController = (PSSCSVImporterNavigationController*)self.navigationController;
    
    // Dequeue the collection cell
    
    PSSCSVImporterCSVColumnCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CollectionViewCellIdentifier forIndexPath:indexPath];
    
    cell.backgroundColor = [UIColor whiteColor];
    
    if (indexPath.row == 0) {
        // First row is always the "Leave empty row"
        cell.columnIndicator.text = NSLocalizedString(@"Leave Empty", nil);
        cell.emptyColumn = YES;
        
        
        
    } else {
        cell.columnIndicator.text = [NSString stringWithFormat:@"%@ %ld/%lu", NSLocalizedString(@"Column", nil), (long)indexPath.row, (unsigned long)[[navigationController.lines objectAtIndex:0] count]];
        
        cell.columnContent.text = [[self columnContent] objectAtIndex:indexPath.row-1];
        
        cell.emptyColumn = NO;
    }
    
    return cell;
}


#pragma mark - UIScrollViewDelegate Methods

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (![scrollView isKindOfClass:[PSSCSVColumnIndexedCollectionView class]]) return;
    
    int page = scrollView.contentOffset.x / scrollView.frame.size.width;
    
    PSSCSVColumnIndexedCollectionView *collectionView = (PSSCSVColumnIndexedCollectionView *)scrollView;
    NSInteger index = collectionView.index;
    self.contentOffsetDictionary[[@(index) stringValue]] = @(page);
}



@end

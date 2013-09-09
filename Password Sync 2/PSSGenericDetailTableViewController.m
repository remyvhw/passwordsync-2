//
//  PSSDetailViewController.m
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-06-26.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import "PSSGenericDetailTableViewController.h"





@implementation PSSGenericDetailTableViewController
@synthesize detailItem = _detailItem;
@synthesize versionsTableViewCell = _versionsTableViewCell;
@synthesize favoriteTableViewCell = _favoriteTableViewCell;
@synthesize twoStepsTableViewCell = _twoStepsTableViewCell;

-(UITableViewCell*)twoStepsTableViewCell{
    
    if (_twoStepsTableViewCell) {
        return _twoStepsTableViewCell;
    }
    
    UITableViewCell * twoStepsTableViewCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    
    twoStepsTableViewCell.textLabel.text = NSLocalizedString(@"Two-factor Authentication", nil);
    twoStepsTableViewCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    twoStepsTableViewCell.imageView.image = [[UIImage imageNamed:@"TwoStep"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    _twoStepsTableViewCell = twoStepsTableViewCell;
    return twoStepsTableViewCell;
}

-(UITableViewCell*)tagsTableViewCell{
    
    if (_tagsTableViewCell) {
        return _tagsTableViewCell;
    }
    
    UITableViewCell * tagsTableViewCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    
    tagsTableViewCell.textLabel.text = NSLocalizedString(@"Tags", nil);
    tagsTableViewCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    tagsTableViewCell.imageView.image = [[UIImage imageNamed:@"Tags"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    _tagsTableViewCell = tagsTableViewCell;
    return tagsTableViewCell;
    
}


-(UITableViewCell*)versionsTableViewCell{
    
    if (_versionsTableViewCell) {
        return _versionsTableViewCell;
    }
    
    UITableViewCell * versionsTableViewCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    
    versionsTableViewCell.textLabel.text = NSLocalizedString(@"Versions", nil);
    versionsTableViewCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    versionsTableViewCell.imageView.image = [[UIImage imageNamed:@"Versions"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    _versionsTableViewCell = versionsTableViewCell;
    return versionsTableViewCell;
    
}


-(UITableViewCell*)favoriteTableViewCell{
    
    if (_favoriteTableViewCell) {
        return _favoriteTableViewCell;
    }
    
    UITableViewCell * favoriteTableViewCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    
    favoriteTableViewCell.textLabel.text = NSLocalizedString(@"Favorite", nil);
    
    favoriteTableViewCell.imageView.image = [[UIImage imageNamed:@"Favorite"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    _favoriteTableViewCell = favoriteTableViewCell;
    return favoriteTableViewCell;
    
}

#pragma mark - Managing the detail item


-(UIView*)lockedImageAccessoryView{
    
    UIImage * lockImage = [UIImage imageNamed:@"SmallLock"];
    
    UIImageView * accessoryView = [[UIImageView alloc] initWithImage:[lockImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    return accessoryView;
}

-(UIView*)copyImageAccessoryView{
    UIImage * copyImage = [UIImage imageNamed:@"Copy"];
    
    UIImageView * accessoryView = [[UIImageView alloc] initWithImage:[copyImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    return accessoryView;
}

-(void)lockUIAction:(id)notification{
    
    
    [super lockUIAction:notification];
    [self.tableView reloadData];
    
}




-(void)userDidUnlockWithPasscode{
    [super userDidUnlockWithPasscode];
    [self.tableView reloadData];
    
}


-(void)datastoreHasBeenUpdated:(id)sender{
    [self.tableView reloadData];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




#pragma mark - UITableViewDataSource methods

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 0;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 0;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    return nil;
}

#pragma mark - UITableViewDelegate methods
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (![self isPasscodeUnlocked]) {
        
        [self showUnlockingViewController];
        return;
    }
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - PSSObjectEditorProtocol methods

-(void)objectEditor:(id)editor finishedWithObject:(PSSBaseGenericObject *)genericObject{
    [super objectEditor:editor finishedWithObject:genericObject];
    self.detailItem = genericObject;
    [self.tableView reloadData];
}



@end

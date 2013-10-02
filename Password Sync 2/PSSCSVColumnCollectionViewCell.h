//
//  PSSCSVColumnCollectionViewCell.h
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-10-01.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSSCSVColumnTableViewDatasource.h"

@interface PSSCSVColumnCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet PSSCSVColumnTableViewDatasource *tableViewDataSource;

@end

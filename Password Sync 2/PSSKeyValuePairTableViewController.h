//
//  PSSKeyValuePairTableViewController.h
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 10/7/2013.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSSBaseObjectVersion.h"
#import "PSSBaseGenericObject.h"

@interface PSSKeyValuePairTableViewController : UITableViewController

@property (nonatomic, strong) PSSBaseGenericObject * detailItem;
@property (nonatomic, strong) NSArray * baseArray;


@end

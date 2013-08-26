//
//  PSSGenericListTableViewController.m
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-08-18.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import "PSSGenericListTableViewController.h"
#import "PSSBaseGenericObject.h"

@interface PSSGenericListTableViewController ()
@property (nonatomic, strong) NSFetchedResultsController * fetchedResultsController;


@end

@implementation PSSGenericListTableViewController


-(void)datastoreHasBeenUpdated:(id)sender{
    [self.tableView reloadData];
}

-(void)viewDidLoad{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(datastoreHasBeenUpdated:) name:PSSGlobalUpdateNotification object:nil];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Table view data source

-(void)deselectAllRowsAnimated:(BOOL)animated{
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:animated];
}


-(void)selectRowForBaseObject:(PSSBaseGenericObject *)baseObject{
    
    NSIndexPath * indexPath = [[self fetchedResultsController] indexPathForObject:baseObject];
    
    [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

@end

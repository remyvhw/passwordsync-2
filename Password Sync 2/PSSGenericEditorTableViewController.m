//
//  PSSGenericEditorTableViewController.m
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-07-25.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import "PSSGenericEditorTableViewController.h"
#import "PSSTagsSelectorTableViewController.h"

@interface PSSGenericEditorTableViewController ()


@end

@implementation PSSGenericEditorTableViewController
@synthesize tagsTableViewCell = _tagsTableViewCell;

-(void)presentTagSelectorViewController{
    
    PSSTagsSelectorTableViewController * tagsSelector = [[PSSTagsSelectorTableViewController alloc] initWithNibName:@"PSSTagsSelectorTableViewController" bundle:[NSBundle mainBundle]];
    
    
    tagsSelector.editionMode = YES;
    tagsSelector.detailItem = self.baseObject;
    tagsSelector.tagsSelectorDelegate = self;
    
    if (self.itemTags) {
        tagsSelector.selectionSet = [[NSMutableSet alloc] initWithSet:self.itemTags];
    }
    
    [self.navigationController pushViewController:tagsSelector animated:YES];
    
    
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



-(void)cancelAction:(id)sender{
    if (self.baseObject) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self.navigationController dismissViewControllerAnimated:YES completion:NULL];
    }
}

-(void)saveAction:(id)sender{
    
    
    
}


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem * saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveAction:)];
    
    self.navigationItem.rightBarButtonItem = saveButton;
    
    
    if (self.baseObject) {
        
    } else {
        
        UIBarButtonItem * cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelAction:)];
        
        self.navigationItem.leftBarButtonItem = cancelButton;
        
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

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
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}


#pragma mark - PSSTagsSelectorDelegate protocol methods

-(void)tagsSelector:(PSSTagsSelectorTableViewController *)tagsSelector didFinishWithSelection:(NSSet *)selectionSet{
    
    self.itemTags = selectionSet;
    
    
}

@end

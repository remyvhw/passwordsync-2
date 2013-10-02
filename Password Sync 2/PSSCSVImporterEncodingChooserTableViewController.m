//
//  PSSCSVImporterEncodingChooserTableViewController.m
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-10-01.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import "PSSCSVImporterEncodingChooserTableViewController.h"
#import "PSSCSVImporterNavigationController.h"
#import "PSSCSVColumnSelectorCollectionViewController.h"

@interface PSSCSVImporterEncodingChooserTableViewController ()


@end

@implementation PSSCSVImporterEncodingChooserTableViewController

    
#pragma mark - UINavigationController Lifecycle

-(void)continueToNext:(id)sender{
    
    PSSCSVImporterNavigationController * navigationController = (PSSCSVImporterNavigationController*)self.navigationController;
    
    [navigationController startParsing:sender];
    
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
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"encoding-cell"];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"delimiter-cell"];

    
    UIBarButtonItem * nextButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Continue", nil) style:UIBarButtonItemStylePlain target:self action:@selector(continueToNext:)];
    
    self.navigationItem.rightBarButtonItem = nextButton;
    
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return NSLocalizedString(@"Encoding", nil);
    } else if ( section==1 ) {
        return NSLocalizedString(@"Delimiter", nil);
    }
    return @"";
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == 0) {
        return 7;
    } else if (section == 1) {
        return 2;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PSSCSVImporterNavigationController * navigationController = (PSSCSVImporterNavigationController*)self.navigationController;
    
    if (indexPath.section == 0) {
        static NSString *CellIdentifier = @"encoding-cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        
        
        switch (indexPath.row) {
            case 0:
                cell.textLabel.text = @"MacOS Roman";
                if (navigationController.fileEncoding == NSMacOSRomanStringEncoding) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                } else {
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }
                break;
            case 1:
                cell.textLabel.text = @"UTF-8";
                if (navigationController.fileEncoding == NSUTF8StringEncoding) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                } else {
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }
                break;
            case 2:
                cell.textLabel.text = @"UTF-16BE";
                if (navigationController.fileEncoding == NSUTF16BigEndianStringEncoding) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                } else {
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }
                break;
            case 3:
                cell.textLabel.text = @"UTF-16LE";
                if (navigationController.fileEncoding == NSUTF16LittleEndianStringEncoding) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                } else {
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }
                break;
            case 4:
                cell.textLabel.text = @"UTF-32BE";
                if (navigationController.fileEncoding == NSUTF32BigEndianStringEncoding) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                } else {
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }
                break;
            case 5:
                cell.textLabel.text = @"UTF-32LE";
                if (navigationController.fileEncoding == NSUTF32LittleEndianStringEncoding) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                } else {
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }
                break;
            case 6:
                cell.textLabel.text = @"ISO 2022-KR";
                if (navigationController.fileEncoding == kCFStringEncodingISO_2022_KR) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                } else {
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }
                break;
        }
        
        
        return cell;
    } else if (indexPath.section==1) {
        
        
        static NSString *CellIdentifier = @"delimiter-cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        
        switch (indexPath.row) {
            case 0:
                cell.textLabel.text = @",";
                if ([navigationController.separator isEqualToString:@","]) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                } else {
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }
                break;
            case 1:
                cell.textLabel.text = @"tab";
                if ([navigationController.separator isEqualToString:@"\t"]) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                } else {
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }
                break;
        }
        
        return cell;
    }

    return nil;
}

#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    PSSCSVImporterNavigationController * navigationController = (PSSCSVImporterNavigationController*)self.navigationController;
    
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:
                navigationController.fileEncoding = NSMacOSRomanStringEncoding;
                break;
            case 1:
                navigationController.fileEncoding = NSUTF8StringEncoding;
                break;
            case 2:
                navigationController.fileEncoding = NSUTF16BigEndianStringEncoding;
                break;
            case 3:
                navigationController.fileEncoding = NSUTF16LittleEndianStringEncoding;
                break;
            case 4:
                navigationController.fileEncoding = NSUTF32BigEndianStringEncoding;
                break;
            case 5:
                navigationController.fileEncoding = NSUTF32LittleEndianStringEncoding;
                break;
            case 6:
                navigationController.fileEncoding = kCFStringEncodingISO_2022_KR;
                break;
        }

        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
    } else if (indexPath.section == 1) {
        
        switch (indexPath.row) {
            case 0:
                navigationController.separator = @",";
                break;
            case 1:
                navigationController.separator = @"\t";
                break;
        }
        
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
        
        
    }
    
    
    
}

@end

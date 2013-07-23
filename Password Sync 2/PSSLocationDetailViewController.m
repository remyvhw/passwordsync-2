//
//  PSSLocationDetailViewController.m
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-07-23.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import "PSSLocationDetailViewController.h"
#import "PSSLocationVersion.h"
#import "PSSLocationEditorTableViewController.h"

#import "PSSLocationMapCell.h"
@import CoreLocation;

@interface PSSLocationDetailViewController ()
@property (strong, nonatomic) UITableViewCell * titleCell;
@property (strong, nonatomic) UITableViewCell * notesCell;
@property (strong, nonatomic) PSSLocationMapCell * mapCell;


@end

@implementation PSSLocationDetailViewController


-(void)editorAction:(id)sender{
    
    PSSLocationEditorTableViewController * locationEditor = [[PSSLocationEditorTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    
    locationEditor.editorDelegate = self;
    locationEditor.locationBaseObject = self.detailItem;
    
    [self.navigationController pushViewController:locationEditor animated:YES];
    
    
}


-(void)lockUIAction:(id)notification{
    self.isPasscodeUnlocked = NO;
    [self createNotesCell];
    [super lockUIAction:notification];
}

-(void)userDidUnlockWithPasscode{
    
    // We need to reload the note cell
    [self createNotesCell];
    [super userDidUnlockWithPasscode];
    
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

-(void)createNotesCell{
    UITableViewCell * notesCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    
    notesCell.textLabel.numberOfLines = 0;
    notesCell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSString * decryptedNotes = self.detailItem.currentVersion.decryptedNotes;
    if (decryptedNotes && ![decryptedNotes isEqualToString:@""]) {
        
        if (self.isPasscodeUnlocked) {
            notesCell.textLabel.text = decryptedNotes;
        } else {
            notesCell.textLabel.text = NSLocalizedString(@"Locked", nil);
            notesCell.textLabel.textColor = [UIColor lightGrayColor];
            notesCell.accessoryView = [self lockedImageAccessoryView];
        }
        
        
    } else {
        notesCell.textLabel.text = NSLocalizedString(@"No Notes", nil);
        notesCell.textLabel.textColor = [UIColor lightGrayColor];
        notesCell.textLabel.textAlignment = NSTextAlignmentCenter;
    }
    
    self.notesCell = notesCell;
    
}

#pragma mark - UITableViewDataSource methods

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    
    if (section == 2) {
        return NSLocalizedString(@"Notes", nil);
    }
    
    return @"";
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 1) {
        // Map
        return 244.;
    }
    
    
    if (indexPath.section == 2) {
        // Notes
        
        if (!self.notesCell) {
            [self createNotesCell];
        }
        
        CGRect labelFrame = self.notesCell.textLabel.frame;
        labelFrame.size.width = self.view.frame.size.width;
        self.notesCell.textLabel.frame = labelFrame;
        [self.notesCell.textLabel sizeToFit];
        
        return self.notesCell.textLabel.frame.size.height + 20;
        
    }

    return 44.;
    
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 4;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        // Title && Password
        return 2;
    } else if (section == 1) {
        // Map
        return 1;
    } else if (section == 2) {
        // Notes
        return 1;
    }
    return 0;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    /// TITLE
    if (indexPath.section == 0 && indexPath.row == 0) {
        // Title cell
        if (!self.titleCell) {
            UITableViewCell * titleCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            titleCell.selectionStyle = UITableViewCellSelectionStyleNone;
            titleCell.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
            self.titleCell = titleCell;
        }
        self.titleCell.textLabel.text = self.detailItem.displayName;
        
        return self.titleCell;
    }
    
    
    if (indexPath.section == 0 && indexPath.row == 1) {
        // Password
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"KeyValueCell" forIndexPath:indexPath];
        cell.detailTextLabel.textColor = [UIColor blackColor];
        cell.accessoryView = nil;
        
        cell.textLabel.text = NSLocalizedString(@"PIN", nil);
        if (self.isPasscodeUnlocked) {
            cell.detailTextLabel.text = self.detailItem.currentVersion.decryptedPassword;
        } else {
            cell.detailTextLabel.text = NSLocalizedString(@"Locked", nil);
            cell.detailTextLabel.textColor = [UIColor lightGrayColor];
            cell.accessoryView = [self lockedImageAccessoryView];
        }
        
        
        
        
        
        return cell;
    }
    
    
    if (indexPath.section == 1) {
        
        if (!self.mapCell) {
            PSSLocationMapCell * mapCell = [[PSSLocationMapCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            mapCell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            CLLocationCoordinate2D coordinates = CLLocationCoordinate2DMake([self.detailItem.currentVersion.latitude doubleValue], [self.detailItem.currentVersion.longitude doubleValue]);
            [mapCell rearrangePinAndMapLocationWithLocation:coordinates];
            
            
            self.mapCell = mapCell;
        }
        
        
        return self.mapCell;
    }
    
    if (indexPath.section == 2) {
        // Notes
        if (!self.notesCell) {
            [self createNotesCell];
        }
        return self.notesCell;
        
    }
    
    
    return nil;

    
    
}

#pragma mark - PSSObjectEditorDelegate methods

-(void)objectEditor:(id)editor finishedWithObject:(PSSLocationBaseObject *)genericObject{
    
    [self createNotesCell];
    CLLocationCoordinate2D newlocation = CLLocationCoordinate2DMake([genericObject.currentVersion.latitude doubleValue], [genericObject.currentVersion.longitude doubleValue]);
    [self.mapCell rearrangePinAndMapLocationWithLocation:newlocation];
    
    [super objectEditor:editor finishedWithObject:genericObject];
}

@end

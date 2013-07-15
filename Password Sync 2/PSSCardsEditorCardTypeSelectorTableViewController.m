//
//  PSSCardsEditorCardTypeSelectorTableViewController.m
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-07-15.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import "PSSCardsEditorCardTypeSelectorTableViewController.h"

@interface PSSCardsEditorCardTypeSelectorTableViewController ()

@property (strong) NSArray * arrayOfCardTypes;

@end

@implementation PSSCardsEditorCardTypeSelectorTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        
        self.arrayOfCardTypes = @[
                                  
                                  @{@"cardTypeIdentifier": [NSNumber numberWithChar:CardIOCreditCardTypeVisa],
                                  @"cardTypeVerboseName" : @"Visa"},
                                  
                                  @{@"cardTypeIdentifier": [NSNumber numberWithChar:CardIOCreditCardTypeMastercard],
                                    @"cardTypeVerboseName" : @"MasterCard"},
                                  
                                  @{@"cardTypeIdentifier": [NSNumber numberWithChar:CardIOCreditCardTypeAmex],
                                    @"cardTypeVerboseName" : @"American Express"},
                                  
                                  @{@"cardTypeIdentifier": [NSNumber numberWithChar:CardIOCreditCardTypeDiscover],
                                    @"cardTypeVerboseName" : @"Discover"},
                                  
                                  @{@"cardTypeIdentifier": [NSNumber numberWithChar:CardIOCreditCardTypeJCB],
                                    @"cardTypeVerboseName" : @"JCB"},
                                  
                                  ];
        
     
        [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cardTypeCell"];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    
    if (section==0) {
        return [self.arrayOfCardTypes count];
    } else if (section==1){
        return 1;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"cardTypeCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (indexPath.section == 0) {
        
        NSDictionary * cardTypeDict = [self.arrayOfCardTypes objectAtIndex:indexPath.row];
        
        CardIOCreditCardType cardType = [(NSNumber*)[cardTypeDict objectForKey:@"cardTypeIdentifier"] charValue];
        
        cell.textLabel.text = [cardTypeDict objectForKey:@"cardTypeVerboseName"];
        
        cell.imageView.image = [CardIOCreditCardInfo logoForCardType:cardType];
        
        if (self.selectedCardType == cardType) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        
        
    } else if (indexPath.section == 1){
        
        cell.textLabel.text = NSLocalizedString(@"Other", nil);
        cell.imageView.image = nil;
        if (!self.selectedCardType || self.selectedCardType == CardIOCreditCardTypeAmbiguous || self.selectedCardType == CardIOCreditCardTypeUnrecognized) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        
        
    }
    
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 0) {
        
        NSDictionary * cardTypeDict = [self.arrayOfCardTypes objectAtIndex:indexPath.row];
        
        CardIOCreditCardType cardType = [(NSNumber*)[cardTypeDict objectForKey:@"cardTypeIdentifier"] charValue];
        
        if (self.cardEditorDelegate) {
            [self.cardEditorDelegate cardSelector:self finishedWithCardType:cardType];
        }
        
    } else if (indexPath.section == 1) {
        
        if (self.cardEditorDelegate) {
            [self.cardEditorDelegate cardSelector:self finishedWithCardType:CardIOCreditCardTypeUnrecognized];
        }
        
    }
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

@end

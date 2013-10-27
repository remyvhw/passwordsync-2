//
//  PSSKeyValuePairTableViewController.m
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 10/7/2013.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import "PSSKeyValuePairTableViewController.h"

@interface PSSKeyValuePairTableViewController ()



@end

@implementation PSSKeyValuePairTableViewController

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

    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    
    if (!self.baseArray) {
        
        NSData * decryptedData = self.detailItem.currentHardLinkedVersion.decryptedAdditionalJSONfields;
        if (decryptedData) {
            id decryptedObject = [NSJSONSerialization JSONObjectWithData:self.detailItem.currentHardLinkedVersion.decryptedAdditionalJSONfields options:0 error:NULL];

            if ([decryptedObject isKindOfClass:[NSArray class]]) {
                self.baseArray = decryptedObject;
            } else if ([decryptedObject isKindOfClass:[NSDictionary class]]) {
                self.baseArray = @[decryptedObject];
            }
            
            
            
            
            
        }
        
        
        
    }
    
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"buttonCell"];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"keyValueCell"];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"keyButtonCell"];
    
    
    
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
    return self.baseArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    // Return the number of rows in the section.
    
    id objectForSection = [self.baseArray objectAtIndex:section];
    
    if ([objectForSection isKindOfClass:[NSArray class]]) {
        // One object linking to another array
        return 1;
    } else if ([objectForSection isKindOfClass:[NSDictionary class]]) {
        return [(NSDictionary*)objectForSection count];
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    
    
    id objectForSection = [self.baseArray objectAtIndex:indexPath.section];
    
    if ([objectForSection isKindOfClass:[NSArray class]]) {
        // One object linking to another array
        
        
        static NSString *CellIdentifier = @"buttonCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        
        cell.textLabel.textColor = self.view.window.tintColor;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.text = NSLocalizedString(@"More...", nil);
        
        return cell;
    } else if ([objectForSection isKindOfClass:[NSDictionary class]]) {
        
        NSDictionary * sectionDictionary = objectForSection;
        
        NSArray * sortedKeys = [[sectionDictionary allKeys] sortedArrayUsingSelector: @selector(caseInsensitiveCompare:)];
        NSArray * objects = [sectionDictionary objectsForKeys: sortedKeys notFoundMarker: [NSNull null]];
        
        if ([[objects objectAtIndex:indexPath.row] isKindOfClass:[NSArray class]]) {
            
            static NSString *CellIdentifier = @"keyButtonCell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
            
            cell.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.textLabel.text = [sortedKeys objectAtIndex:indexPath.row];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            return cell;
            
        } else if ([[objects objectAtIndex:indexPath.row] isKindOfClass:[NSString class]]) {
            
            static NSString *CellIdentifier = @"keyValueCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        
        cell.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.detailTextLabel.text = [sortedKeys objectAtIndex:indexPath.row];
        cell.textLabel.text = [objects objectAtIndex:indexPath.row];
        return cell;
        }
        
        
        
        
        
    }
    
    
    
    
    return nil;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end

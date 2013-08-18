//
//  PSSObjectsForTagViewController.m
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-08-16.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import "PSSObjectsForTagViewController.h"
#import "PSSPasswordBaseObject.h"
#import "PSSLocationBaseObject.h"
#import "PSSCreditCardBaseObject.h"
#import "PSSDocumentBaseObject.h"
#import "PSSAppDelegate.h"

@interface PSSObjectsForTagViewController ()

@property (strong, nonatomic) NSMutableArray * finalArrayOfArrays;
@property (strong, nonatomic) NSMutableArray * arrayOfTitles;

@end

@implementation PSSObjectsForTagViewController

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


    // Depending of if we have a selectedTag or selectedCategory, we'll have to configure our final array
    
    self.arrayOfTitles = [[NSMutableArray alloc] initWithCapacity:5];
    self.finalArrayOfArrays = [[NSMutableArray alloc] initWithCapacity:5];
    
    NSSet * setOfObjects = nil;
    if (self.selectedTag) {
        setOfObjects = self.selectedTag.encryptedObjects;
    } else if (self.selectedFolder) {
        setOfObjects = self.selectedFolder.encryptedObjects;
    }
    
    NSSortDescriptor * orderByNameSorter = [[NSSortDescriptor alloc] initWithKey:@"displayName" ascending:YES];
    
    // Now we'll parse each of the generic objects subclass
    
    // Websites
    NSPredicate * passwordsPredicate = [NSPredicate predicateWithFormat: @"self isKindOfClass: %@", [PSSPasswordBaseObject class]];
    
    NSSet * filteredPasswords = [setOfObjects filteredSetUsingPredicate:passwordsPredicate];
    NSArray * orderedArrayOfPasswords = [filteredPasswords sortedArrayUsingDescriptors:@[orderByNameSorter]];
    
    if ([orderedArrayOfPasswords count]) {
        // If we have passwords in that tag/folder, we'll add them to the array.
        [self.arrayOfTitles addObject:NSLocalizedString(@"Websites", nil)];
        [self.finalArrayOfArrays addObject:orderedArrayOfPasswords];
    }
    
    
    
}




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return [self.arrayOfTitles objectAtIndex:section];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [self.finalArrayOfArrays count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    NSArray * currentArray = [self.finalArrayOfArrays objectAtIndex:section];
    return [currentArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSArray * observedArray = [self.finalArrayOfArrays objectAtIndex:indexPath.section];
    id illustratedObject = [observedArray objectAtIndex:indexPath.row];
    
    
    if ([illustratedObject isKindOfClass:[PSSPasswordBaseObject class]]) {
        
        
        PSSPasswordBaseObject * passwordObject = illustratedObject;
        static NSString *CellIdentifier = @"passwordCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        
        // Configure the cell...
        cell.textLabel.text = passwordObject.displayName;
        
        UIImage * favicon = [UIImage imageWithData:passwordObject.favicon];
        cell.imageView.image = favicon;
        
        CALayer *mask = [CALayer layer];
        mask.contents = (id)[[UIImage imageNamed:@"TableViewRoundMask"] CGImage];
        mask.frame = CGRectMake(0, 2, 40, 40);
        cell.imageView.layer.mask = mask;
        cell.imageView.layer.masksToBounds = YES;
        
        
        return cell;
    }
    
    return nil;

}

#pragma mark - UITableVIewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSArray * observedArray = [self.finalArrayOfArrays objectAtIndex:indexPath.section];
    id illustratedObject = [observedArray objectAtIndex:indexPath.row];

    if ([illustratedObject isKindOfClass:[PSSBaseGenericObject class]]) {
        [APP_DELEGATE openBaseObjectDetailView:illustratedObject];
    }
    
    
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

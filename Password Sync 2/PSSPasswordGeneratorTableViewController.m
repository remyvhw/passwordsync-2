//
//  PSSPasswordGeneratorTableViewController.m
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-07-12.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import "PSSPasswordGeneratorTableViewController.h"
#import "PSSRandomPasswordGenerator.h"

@interface PSSPasswordGeneratorTableViewController ()

@property (strong, nonatomic) NSArray * arrayOfGeneratedPasswords;

@end

@implementation PSSPasswordGeneratorTableViewController

-(void)popToPasswordEditorSelectedPassword:(NSString*)selectedPassword{
    
    if (self.generatorDelegate) {
        [self.generatorDelegate passwordGenerator:self finishedWithPassword:selectedPassword];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(NSArray*)generateListOfPasswords{
    
    PSSRandomPasswordGenerator * randomGenerator = [[PSSRandomPasswordGenerator alloc] init];
    
    return @[
             
             @[[randomGenerator generateComplexPasswordUsingPunctuation:YES],
               [randomGenerator generateComplexPasswordUsingPunctuation:YES],
               [randomGenerator generateComplexPasswordUsingPunctuation:YES],
               [randomGenerator generateComplexPasswordUsingPunctuation:NO],
               [randomGenerator generateComplexPasswordUsingPunctuation:NO],
               [randomGenerator generateComplexPasswordUsingPunctuation:NO],
               ],
             
             @[[randomGenerator generateShortLetterNumberAndSpecialCharRandomPassword],
               [randomGenerator generateShortLetterNumberCharRandomPassword],
               ],
             
             
             ];
}

-(void)shufflePasswords:(id)sender{
    
    self.arrayOfGeneratedPasswords = [self generateListOfPasswords];
    
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [self.arrayOfGeneratedPasswords count])] withRowAnimation:UITableViewRowAnimationFade];
    
    
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.arrayOfGeneratedPasswords = [self generateListOfPasswords];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"RandomPasswordGeneratorCell"];
    
    UIBarButtonItem * shuffleButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Shuffle"] landscapeImagePhone:[UIImage imageNamed:@"Shuffle"] style:UIBarButtonItemStylePlain target:self action:@selector(shufflePasswords:)];
    
    
    
    [self.navigationController setToolbarHidden:NO animated:YES];
    [self setToolbarItems:@[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil], shuffleButton, [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil]]];
    
    [self.navigationController setHidesBottomBarWhenPushed:YES];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source


-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section==0) {
        return NSLocalizedString(@"HumanPass", nil);
    }
    
    return @"";
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [self.arrayOfGeneratedPasswords count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    NSArray * passwordsInSection = [self.arrayOfGeneratedPasswords objectAtIndex:section];
    return [passwordsInSection count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"RandomPasswordGeneratorCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    
    NSString * stringAtIndex = [[self.arrayOfGeneratedPasswords objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    cell.textLabel.text = stringAtIndex;
    
    return cell;
}


/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */


#pragma mark - UITableViewController delegate methods
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString * selectedString = [[self.arrayOfGeneratedPasswords objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self popToPasswordEditorSelectedPassword:selectedString];
    }
    
}

@end

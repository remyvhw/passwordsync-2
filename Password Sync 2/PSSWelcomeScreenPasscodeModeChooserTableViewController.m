//
//  PSSWelcomeScreenPasscodeModeChooserTableViewController.m
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-07-01.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import "PSSWelcomeScreenPasscodeModeChooserTableViewController.h"
#import "PSSPasscodeVerifyerViewController.h"

@interface PSSWelcomeScreenPasscodeModeChooserTableViewController ()

@property (strong) NSString * gesturePasscodeEntryDetailText;
@property (strong) NSString * pinPasscodeEntryDetailText;
@property (weak, nonatomic) IBOutlet UILabel *explanationText;

@end

@implementation PSSWelcomeScreenPasscodeModeChooserTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
        if (self) {
        // Custom initialization
        self.gesturePasscodeEntryDetailText = NSLocalizedString(@"Simply draw a pattern.", nil);
        self.pinPasscodeEntryDetailText = NSLocalizedString(@"Five digit passcode.", nil);
            
            
            PSSPasscodeVerifyerViewController * passcodeVerifyer = [[PSSPasscodeVerifyerViewController alloc] init];
            if (passcodeVerifyer.countOfPasscodeAttempts >= 5) {
                // User is resetting it's passcode
                
                self.explanationText.text = NSLocalizedString(@"Please choose a new passcode.", nil);
                
                self.title = NSLocalizedString(@"Reset Passcode", nil);
                
            }
            
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
    return 1;
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"PasscodeModeCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    
    if (indexPath.row == 0) {
        
        cell.imageView.image = [UIImage imageNamed:@"GestureBasedPasscodeIcon"];
        
        cell.textLabel.text = NSLocalizedString(@"Gesture based Passcode", nil);
        cell.detailTextLabel.text = self.gesturePasscodeEntryDetailText;
        
        
    } else if (indexPath.row == 1) {
        
        cell.imageView.image = [UIImage imageNamed:@"NumberBasedPasscodeIcon"];
        cell.textLabel.text = NSLocalizedString(@"PIN based Passcode", nil);
        cell.detailTextLabel.text = self.pinPasscodeEntryDetailText;
    }
    
    
    return cell;
}



#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 0) {
        // Gesture based
        [self performSegueWithIdentifier:@"userSelectedGesturePasscodeSegue" sender:self];
    } else if (indexPath.row == 1){
        [self performSegueWithIdentifier:@"userSelectedPINPasscordSegue" sender:self];
    }
}

@end

//
//  PSSWelcomeScreenFinishedViewController.m
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-07-03.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import "PSSWelcomeScreenFinishedViewController.h"
#import "PSSPasswordSyncOneDataImporter.h"

@interface PSSWelcomeScreenFinishedViewController ()
- (IBAction)finishWelcomeScreenWalkthrough:(id)sender;

@end

@implementation PSSWelcomeScreenFinishedViewController

-(void)dismissModalStartingImport:(BOOL)startingImport{
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        
        if (startingImport) {
            
            PSSPasswordSyncOneDataImporter * dataImporter = [[PSSPasswordSyncOneDataImporter alloc] init];
            [dataImporter beginImportProcedure:self];
            
        }
        
    }];
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
    [self.navigationItem setHidesBackButton:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)finishWelcomeScreenWalkthrough:(id)sender {
    
    
    // Check if we find an old version of Password Sync
    
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"passsyncjsonexport://passsynctwoupgrade?enckey=ABCD"]]) {
        UIAlertView * importFromPasswordSyncAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Import from Password Sync 1", nil) message:NSLocalizedString(@"We have found an existing version of Password Sync on your device. Would you like to import your existing passwords to Password Sync 2?", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Skip for now", nil) otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
        [importFromPasswordSyncAlertView show];
    } else {
        [self dismissModalStartingImport:NO];
    }
    
    
    
    
}



#pragma mark - UIAlertView delegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex==[alertView cancelButtonIndex]) {
        [self dismissModalStartingImport:NO];
    } else {
        [self dismissModalStartingImport:YES];
    }
}

@end

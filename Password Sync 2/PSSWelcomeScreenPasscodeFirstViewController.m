//
//  PSSWelcomeScreenPasscodeFirstViewController.m
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-07-01.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import "PSSWelcomeScreenPasscodeFirstViewController.h"

@interface PSSWelcomeScreenPasscodeFirstViewController ()


@end

@implementation PSSWelcomeScreenPasscodeFirstViewController

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
    
    
    UILabel * descriptionLabel = (UILabel*)[self.view viewWithTag:111];
    descriptionLabel.text = NSLocalizedString(@"Now comes the time to choose a passcode. A passcode is a simpler code that will allow you to unlock your database quickly. It doesn't have to be the same on each of your devices. You should also know that you can always override your passcode with your master password.", nil);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

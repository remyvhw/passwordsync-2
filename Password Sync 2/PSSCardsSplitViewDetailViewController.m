//
//  PSSCardsSplitViewDetailViewController.m
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-08-03.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import "PSSCardsSplitViewDetailViewController.h"
#import "PSSCardDetailViewController.h"

@interface PSSCardsSplitViewDetailViewController ()

@end

@implementation PSSCardsSplitViewDetailViewController

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


-(void)presentViewControllerForCardEntity:(PSSCreditCardBaseObject *)cardBaseObject{
    
    PSSCardDetailViewController * detailView = [self.storyboard instantiateViewControllerWithIdentifier:@"cardDetailViewController"];
    
    
    detailView.detailItem = cardBaseObject;
    
    if (self.visibleViewController != [self.viewControllers objectAtIndex:0]) {
        [self popToRootViewControllerAnimated:NO];
        [self pushViewController:detailView animated:NO];
    } else {
        [self pushViewController:detailView animated:YES];
    }
    

}



@end

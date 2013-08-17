//
//  PSSOrganizerSplitViewDetailViewController.m
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-08-17.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import "PSSOrganizerSplitViewDetailViewController.h"
#import "PSSObjectsForTagViewController.h"

@interface PSSOrganizerSplitViewDetailViewController ()

@end

@implementation PSSOrganizerSplitViewDetailViewController

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

-(void)presentViewControllerForTagEntity:(PSSObjectTag *)tagBaseObject{
    PSSObjectsForTagViewController * detailView = [self.storyboard instantiateViewControllerWithIdentifier:@"objectsForTagControllerSegue"];
    
    
    detailView.selectedTag = tagBaseObject;
    
    if (self.visibleViewController != [self.viewControllers objectAtIndex:0]) {
        [self popToRootViewControllerAnimated:NO];
        [self pushViewController:detailView animated:NO];
    } else {
        [self pushViewController:detailView animated:YES];
    }

}

-(void)forcePopToRoot{
    [self popToRootViewControllerAnimated:YES];
}

@end

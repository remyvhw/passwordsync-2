//
//  PSSLocationsSplitViewDetailViewController.m
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-08-03.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import "PSSLocationsSplitViewDetailViewController.h"
#import "PSSLocationDetailViewController.h"
#import "PSSLocationListTableViewController.h"

@interface PSSLocationsSplitViewDetailViewController ()

@end

@implementation PSSLocationsSplitViewDetailViewController

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

-(void)presentViewControllerForLocationEntity:(PSSLocationBaseObject *)locationBaseObject{
    PSSLocationDetailViewController * detailView = [self.storyboard instantiateViewControllerWithIdentifier:@"locationDetailViewController"];
    
    self.splitViewController.presentsWithGesture = YES;
    
    detailView.detailItem = locationBaseObject;
    
    if (self.visibleViewController != [self.viewControllers objectAtIndex:0]) {
        [self popToRootViewControllerAnimated:NO];
        [self pushViewController:detailView animated:NO];
    } else {
        [self pushViewController:detailView animated:YES];
    }
    
    UINavigationController * listView = [[self.splitViewController viewControllers] objectAtIndex:0];
    
    if ([[listView visibleViewController] isKindOfClass:[PSSLocationListTableViewController class]]) {
        PSSLocationListTableViewController * listOfLocations = (PSSLocationListTableViewController*)[listView visibleViewController];
        [listOfLocations selectRowForBaseObject:locationBaseObject];
    }

    
}

#pragma mark - UISplitViewController Delegate



@end

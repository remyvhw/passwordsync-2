//
//  PSSPasswordSplitViewDetailViewController.m
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-08-03.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import "PSSPasswordSplitViewDetailViewController.h"
#import "PSSPasswordDetailViewController.h"
#import "PSSPasswordListViewController.h"

@interface PSSPasswordSplitViewDetailViewController ()

@end

@implementation PSSPasswordSplitViewDetailViewController



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)presentViewControllerForPasswordEntity:(PSSPasswordBaseObject *)passwordBaseObject{
    
    PSSPasswordDetailViewController * detailView = [self.storyboard instantiateViewControllerWithIdentifier:@"passwordDetailViewController"];
    
    
    detailView.detailItem = passwordBaseObject;
    
    if (self.visibleViewController != [self.viewControllers objectAtIndex:0]) {
        [self popToRootViewControllerAnimated:NO];
        [self pushViewController:detailView animated:NO];
    } else {
        [self pushViewController:detailView animated:YES];
    }
    
    UINavigationController * listView = [[self.splitViewController viewControllers] objectAtIndex:0];
    
    if ([[listView visibleViewController] isKindOfClass:[PSSPasswordListViewController class]]) {
        PSSPasswordListViewController * listOfPasswords = (PSSPasswordListViewController*)[listView visibleViewController];
        [listOfPasswords selectRowForBaseObject:passwordBaseObject];
    }
    
    
}



@end

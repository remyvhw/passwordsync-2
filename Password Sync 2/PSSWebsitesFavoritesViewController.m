//
//  PSSWebsitesFavoritesViewController.m
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-08-03.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import "PSSWebsitesFavoritesViewController.h"
#import "PSSPasswordListViewController.h"

@interface PSSWebsitesFavoritesViewController ()

@end

@implementation PSSWebsitesFavoritesViewController

- (void)insertNewObject:(id)sender
{
    
    UIStoryboard * storyboardContainingEditor = [UIStoryboard storyboardWithName:@"PSSNewPasswordObjectStoryboard_iPhone" bundle:[NSBundle mainBundle]];
    UINavigationController * passwordEditorNavController = [storyboardContainingEditor instantiateInitialViewController];
    
    passwordEditorNavController.modalPresentationStyle = UIModalPresentationFormSheet;
    [self.navigationController presentViewController:passwordEditorNavController animated:YES completion:^{
        
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
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
        
        self.navigationItem.rightBarButtonItem = addButton;
        
    }

    
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    
    UINavigationController * masterNavController = [self.splitViewController.viewControllers firstObject];
    PSSPasswordListViewController * mainViewController = (PSSPasswordListViewController*)[masterNavController.viewControllers firstObject];
  

    if ([mainViewController respondsToSelector:@selector(deselectAllRowsAnimated:)]) {
            [mainViewController deselectAllRowsAnimated:YES];
    }
    

    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

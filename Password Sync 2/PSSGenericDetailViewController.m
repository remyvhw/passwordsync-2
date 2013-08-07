//
//  PSSGenericDetailViewController.m
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-07-27.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import "PSSGenericDetailViewController.h"
#import "PSSUnlockPromptViewController.h"

@interface PSSGenericDetailViewController ()

@property (strong, nonatomic) UIPopoverController *masterPopoverController;

@end

@implementation PSSGenericDetailViewController




-(void)presentVersionsBrowser:(id)sender{
    
}



-(void)lockUIAction:(id)notification{
    
    self.isPasscodeUnlocked = NO;
    
}

-(void)unlockUIAction:(id)notification{
    self.isPasscodeUnlocked = YES;
    [self userDidUnlockWithPasscode];
}

-(void)editorAction:(id)sender{
    
    
    
}

-(void)userDidUnlockWithPasscode{
    UIBarButtonItem * editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editorAction:)];
    [self.navigationItem setRightBarButtonItem:editButton animated:YES];
    
}



-(void)showUnlockingViewController{
    
    
    UIStoryboard * unlockStoryboard = [UIStoryboard storyboardWithName:@"UnlockPrompt" bundle:[NSBundle mainBundle]];
    PSSUnlockPromptViewController * unlockController = (PSSUnlockPromptViewController*)[unlockStoryboard instantiateInitialViewController];
    
    [self.navigationController presentViewController:[unlockController promptForPasscodeBlockingView:NO completion:^{
        // We only run the refresh if the UI was locked to prevent double reloads
        if (!self.isPasscodeUnlocked) {
            self.isPasscodeUnlocked = YES;
            [self userDidUnlockWithPasscode];
        }
        
    } cancelation:^{
        
    }] animated:YES completion:^{
        
    }];
    
    
    
    
}

-(void)updateViewForNewDetailItem{
    
}


- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        // Update the view.
        [self updateViewForNewDetailItem];
    }
    
    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }
}


#pragma mark - Common stuff

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
    
    self.isPasscodeUnlocked = NO;
    
    // Subscribe to the lock notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(lockUIAction:) name:PSSGlobalLockNotification object:nil];
    
    // Subscribe to unlock notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(unlockUIAction:) name:PSSGlobalUnlockNotification object:nil];
    

}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - SplitViewControllerDelegate methods

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Master", @"Master");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}



#pragma mark - PSSObjectEditorProtocol methods

-(void)objectEditor:(id)editor finishedWithObject:(PSSBaseGenericObject *)genericObject{
    
    
}


@end

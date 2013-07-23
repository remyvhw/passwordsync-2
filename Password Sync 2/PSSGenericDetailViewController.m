//
//  PSSDetailViewController.m
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-06-26.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import "PSSGenericDetailViewController.h"

#import "PSSEncryptor.h"
#import "PSSUnlockPromptViewController.h"

@interface PSSGenericDetailViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;

@end

@implementation PSSGenericDetailViewController

#pragma mark - Managing the detail item

-(UIView*)lockedImageAccessoryView{
    
    UIImage * lockImage = [UIImage imageNamed:@"SmallLock"];
    
    UIImageView * accessoryView = [[UIImageView alloc] initWithImage:[lockImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    return accessoryView;
}

-(void)lockUIAction:(id)notification{
    
    
    self.isPasscodeUnlocked = NO;
    [self.tableView reloadData];
    
}

-(void)unlockUIAction:(id)notification{
    self.isPasscodeUnlocked = YES;
    [self userDidUnlockWithPasscode];
}

-(void)editorAction:(id)sender{
    
    
    
}

-(void)userDidUnlockWithPasscode{
    [self.tableView reloadData];
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


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
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

#pragma mark - Split view

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

#pragma mark - UITableViewDataSource methods

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 0;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 0;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    return nil;
}

#pragma mark - UITableViewDelegate methods
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (![self isPasscodeUnlocked]) {
        
        [self showUnlockingViewController];
        return;
    }
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - PSSObjectEditorProtocol methods

-(void)objectEditor:(id)editor finishedWithObject:(PSSBaseGenericObject *)genericObject{
    [self.tableView reloadData];
}



@end

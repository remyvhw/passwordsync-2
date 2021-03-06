//
//  PSSGenericDetailViewController.m
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-07-27.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import "PSSGenericDetailViewController.h"
#import "PSSUnlockPromptViewController.h"
#import "PSSAppDelegate.h"
#import "PSSTagsSelectorTableViewController.h"
#import "PSSKeyValuePairTableViewController.h"

@interface PSSGenericDetailViewController ()

@property (strong, nonatomic) UIPopoverController *masterPopoverController;

@end

@implementation PSSGenericDetailViewController

-(void)presentKeyValuePairsBrowser:(id)sender{
    
    PSSKeyValuePairTableViewController * keyValueController = [[PSSKeyValuePairTableViewController alloc] initWithStyle:UITableViewStylePlain];
    
    keyValueController.detailItem = self.detailItem;
    
    [self.navigationController pushViewController:keyValueController animated:YES];
    
}

-(void)presentTagsBrowser:(id)sender{
    
    
    PSSTagsSelectorTableViewController * tagsSelector = [[PSSTagsSelectorTableViewController alloc] initWithNibName:@"PSSTagsSelectorTableViewController" bundle:[NSBundle mainBundle]];
    
    
    tagsSelector.editionMode = NO;
    tagsSelector.detailItem = self.detailItem;
    
    [self.navigationController pushViewController:tagsSelector animated:YES];

}

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
    
    
    NSUserDefaults * standardUserDefaults = [NSUserDefaults standardUserDefaults];
    
    if (![[standardUserDefaults objectForKey:PSSUserSettingsPromptForPasscodeForEveryUnlockedEntry] boolValue] && APP_DELEGATE.isUnlocked) {
        if (!self.isPasscodeUnlocked) {
            self.isPasscodeUnlocked = YES;
            [self userDidUnlockWithPasscode];
        }
        return;
    }
    
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
    // Will be subclassed
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

-(void)adjustContentInsetForBannerView{
    
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

-(void)datastoreHasBeenUpdated:(id)sender{
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
    
    // Subscribe to global refresh (when the iCloud data is swapped)
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(datastoreHasBeenUpdated:) name:PSSGlobalUpdateNotification object:nil];
    
    
    
    if (APP_DELEGATE.shouldPresentAds && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        
        // Insert an ad
        
        ADBannerView * bannerView = [[ADBannerView alloc] initWithAdType:ADAdTypeBanner];
        
        CGFloat bannerHeight = 0.0;
        CGFloat bannerTopFromOrigin = 0.0;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            // On the iPhone, the ad's height is 50 points
            bannerHeight = 50.;
            bannerTopFromOrigin = self.view.frame.size.height - bannerHeight - 49;
        } else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            // On iPad 66 points
            bannerHeight = 66.;
            bannerTopFromOrigin = self.view.frame.size.height - bannerHeight - 56;
        }
        
        CGRect bannerRect = CGRectMake(0, bannerTopFromOrigin, self.view.frame.size.width, bannerHeight);
        
        bannerView.frame = bannerRect;
        bannerView.delegate = self;
        self.bannerView = bannerView;
        
        [self.view addSubview:bannerView];
        
        
    }

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



-(void)toggleFavorite{
    
    if ([self.detailItem.favorite boolValue]) {
        // Item is already a favorite. Remove it.
        self.detailItem.favorite = [NSNumber numberWithBool:NO];
    } else {
        self.detailItem.favorite = [NSNumber numberWithBool:YES];
    }
    
    // Save the context
    [self.detailItem.managedObjectContext performBlockAndWait:^{
            [self.detailItem.managedObjectContext save:NULL];
    }];

    
}


#pragma mark - PSSObjectEditorProtocol methods

-(void)objectEditor:(id)editor finishedWithObject:(PSSBaseGenericObject *)genericObject{
    
    
}

#pragma mark - ADBannerViewDelegate methods

-(void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error{
    [UIView animateWithDuration:0.3 animations:^{
        [self.bannerView setAlpha:0.0];
    } completion:^(BOOL finished) {
        self.bannerView = nil;
        [self adjustContentInsetForBannerView];
    }];
}

-(void)bannerViewDidLoadAd:(ADBannerView *)banner{
    [self adjustContentInsetForBannerView];
}



@end

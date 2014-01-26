//
//  PSSUpgradePurchasesAppViewController.m
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 10/27/2013.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import "PSSUpgradePurchasesAppViewController.h"
#import "PSSDeviceCapacity.h"
#import "UIImage+ImageEffects.h"
#import "RMStore.h"
#import "PSSAppDelegate.h"
#import "SVProgressHUD.h"

@interface PSSUpgradePurchasesAppViewController ()

@end

@implementation PSSUpgradePurchasesAppViewController
dispatch_queue_t backgroundQueue;

-(void)dismissModalSelf:(id)sender{
    [self.navigationController dismissViewControllerAnimated:YES completion:NULL];
}

-(void)settingsButtonAction:(id)sender{
    
    UIActionSheet * settingsActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Restore Purchases", nil), nil];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [settingsActionSheet showFromBarButtonItem:sender animated:YES];
    } else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [settingsActionSheet showFromTabBar:[(UITabBarController*)APP_DELEGATE.window.rootViewController tabBar]];
        
    }
    
}

-(void)restorePurchases{
    
    [SVProgressHUD show];
    
    [[RMStore defaultStore] restoreTransactionsOnSuccess:^{
        [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Restored", nil)];
    } failure:^(NSError *error) {
        [SVProgressHUD dismiss];
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"An Error Occured", nil) message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
    }];
    
}

-(void)refreshViewForCurrentStatusAnimated:(BOOL)animated{
    
    CGFloat duration = 0.0;
    if (animated) {
        duration = 0.7;
    }
    
    if (APP_DELEGATE.shouldAllowUnlimitedFeatures) {
        [self.proButton setEnabled:NO];
        [self.totalButton setEnabled:NO];
        [self.proButton setTitle:@"✓" forState:UIControlStateNormal];
        
        [UIView animateWithDuration:duration animations:^{
            [self.proTitle setAlpha:0.5];
            [self.proExplanationText setAlpha:0.5];
            [self.totalTitle setAlpha:0.5];
            [self.totalExplanationText setAlpha:0.5];
        }];
        
    }
    
    if (!APP_DELEGATE.shouldPresentAds) {
        [self.noadsButton setEnabled:NO];
        [self.totalButton setEnabled:NO];
        [self.noadsButton setTitle:@"✓" forState:UIControlStateNormal];
        
        [UIView animateWithDuration:duration animations:^{
            [self.noadsTitle setAlpha:0.5];
            [self.noadsExplanationText setAlpha:0.5];
            [self.totalTitle setAlpha:0.5];
            [self.totalExplanationText setAlpha:0.5];
        }];
        
    }
    
    if (!APP_DELEGATE.shouldPresentAds && APP_DELEGATE.shouldAllowUnlimitedFeatures) {
        [self.totalButton setTitle:@"✓" forState:UIControlStateNormal];
    }
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = NSLocalizedString(@"Upgrade", nil);
        self.tabBarItem.image = [UIImage imageNamed:@"Keyhole"];
        self.tabBarItem.selectedImage = [UIImage imageNamed:@"Keyhole-selected"];
    }
    return self;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    [self.proButton setBackgroundImage:[UIImage imageNamed:@"large_button_white_highlight"] forState:UIControlStateHighlighted];
    [self.noadsButton setBackgroundImage:[UIImage imageNamed:@"large_button_white_highlight"] forState:UIControlStateHighlighted];
    [self.totalButton setBackgroundImage:[UIImage imageNamed:@"large_button_white_highlight"] forState:UIControlStateHighlighted];
    
    // Localize UI
    self.proTitle.text = NSLocalizedString(@"Unlock all features", nil);
    self.proExplanationText.text = NSLocalizedString(@"Unlock access to all of Password Sync, including location based password, data import and more than 25 entries.", nil);
    self.noadsTitle.text = NSLocalizedString(@"Remove Ads", nil);
    self.proExplanationText.text = NSLocalizedString(@"Unclutter Password Sync by removing banner ads from the interface.", nil);
    self.totalTitle.text = NSLocalizedString(@"Unlock all + remove ads", nil);
    self.proExplanationText.text = NSLocalizedString(@"Unlock access to all of Password Sync, including location based passwords, data import and more than 25 entries, and remove banner ads from the app, all at once!", nil);
    

    // Add a button to restore purchases
    UIBarButtonItem * restorePurchasesButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"CloudDownload"] style:UIBarButtonItemStylePlain target:self action:@selector(settingsButtonAction:)];
    restorePurchasesButton.accessibilityLabel = NSLocalizedString(@"Restore Purchases", nil);
    self.navigationItem.rightBarButtonItem = restorePurchasesButton;
    
    if (self.isPresentedModally) {
        // Add a cancel button
        
        UIBarButtonItem * cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismissModalSelf:)];
        self.navigationItem.leftBarButtonItem = cancelButton;
    }
    
    
    if ([PSSDeviceCapacity shouldRunAdvancedFeatures]) {
        
        backgroundQueue = dispatch_queue_create([[NSString stringWithFormat:@"%@.UpgradeBackgroundImageProcessingQueue", [[NSBundle mainBundle] bundleIdentifier]] cStringUsingEncoding:NSUTF8StringEncoding], NULL);
            
            // Configure a image view with a blur
        self.backgroundImage.alpha = 0.0;
        
        
        dispatch_async(backgroundQueue, ^(void) {
                
                UIImage * backgroundLogoImage = [[UIImage imageNamed:@"KeyImage.jpg"] applyLightEffect];
            
                
                // Replace any transparency in the favicon by white so we don't end up with black cells (unless we have a black favicon)
               
                
                
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                
                self.backgroundImage.clipsToBounds = YES;
                self.backgroundImage.image = backgroundLogoImage;
                
                    
                    [UIView animateWithDuration:1.5 animations:^{
                        self.backgroundImage.alpha = 0.5;
                    }];
                    
                });
            
            });
            // End of background thread
       
    }
    
    self.scrollView.contentInset = UIEdgeInsetsMake(64., 0, 49, 0);
    
    
    NSSet *products = [NSSet setWithArray:@[PSSPasswordSyncTwoRemoveAdsAndAllowUnlimitedItems, PSSPasswordSyncTwoRemoveAdsPurchase, PSSPasswordSyncTwoAllowUnlimitedItems]];
    [[RMStore defaultStore] requestProducts:products success:^(NSArray *products, NSArray *invalidProductIdentifiers) {
        
        
        
        
    } failure:^(NSError *error) {
        
        
        [self.totalButton setEnabled:NO];
        [self.noadsButton setEnabled:NO];
        [self.proButton setEnabled:NO];
        
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"An Error Occured", nil) message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
        [alert show];
        
    }];
    
    [self refreshViewForCurrentStatusAnimated:NO];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(paymentNotificationWasPosted:) name:PSSGlobalInAppPurchaseNotification object:nil];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)proAction:(id)sender {
    
    [[RMStore defaultStore] addPayment:PSSPasswordSyncTwoAllowUnlimitedItems success:^(SKPaymentTransaction *transaction) {
        
        
        APP_DELEGATE.shouldAllowUnlimitedFeatures = YES;
        
        [self postPaymentNotification];
        
        
    } failure:^(SKPaymentTransaction *transaction, NSError *error) {
        
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"An Error Occured", nil) message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
        [alertView show];
        
    }];
    
}

- (IBAction)totalAction:(id)sender {
    
    [self postPaymentNotification];
    APP_DELEGATE.shouldAllowUnlimitedFeatures = YES;
    APP_DELEGATE.shouldPresentAds = NO;
    return;
    
    [[RMStore defaultStore] addPayment:PSSPasswordSyncTwoRemoveAdsAndAllowUnlimitedItems success:^(SKPaymentTransaction *transaction) {
        
        
        APP_DELEGATE.shouldAllowUnlimitedFeatures = YES;
        APP_DELEGATE.shouldPresentAds = NO;
        
        [self postPaymentNotification];
        
    } failure:^(SKPaymentTransaction *transaction, NSError *error) {
        
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"An Error Occured", nil) message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
        [alertView show];
        
    }];
    
}

- (IBAction)noadsAction:(id)sender {
    
    [[RMStore defaultStore] addPayment:PSSPasswordSyncTwoRemoveAdsPurchase success:^(SKPaymentTransaction *transaction) {
        
        
        APP_DELEGATE.shouldPresentAds = NO;
        
        [self postPaymentNotification];
        
    } failure:^(SKPaymentTransaction *transaction, NSError *error) {
        
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"An Error Occured", nil) message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
        [alertView show];
        
    }];
    
}

-(void)paymentNotificationWasPosted:(NSNotification*)notification{
    [self refreshViewForCurrentStatusAnimated:YES];
}

-(void)postPaymentNotification{
    [[NSNotificationCenter defaultCenter] postNotificationName:PSSGlobalInAppPurchaseNotification object:self];
}

#pragma mark - UIActionSheetDelegate methods

-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (buttonIndex==0) {
        // Restore purchases
        
        [self restorePurchases];
        
    }
}

@end

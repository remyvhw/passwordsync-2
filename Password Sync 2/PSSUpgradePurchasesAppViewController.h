//
//  PSSUpgradePurchasesAppViewController.h
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 10/27/2013.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PSSUpgradePurchasesAppViewController : UIViewController <UIActionSheetDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImage;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *topTitle;
@property (weak, nonatomic) IBOutlet UILabel *topSubtitle;
@property (weak, nonatomic) IBOutlet UIButton *proButton;
@property (weak, nonatomic) IBOutlet UILabel *proTitle;
@property (weak, nonatomic) IBOutlet UILabel *proExplanationText;
@property (weak, nonatomic) IBOutlet UIButton *noadsButton;
@property (weak, nonatomic) IBOutlet UILabel *noadsTitle;
@property (weak, nonatomic) IBOutlet UILabel *noadsExplanationText;
@property (weak, nonatomic) IBOutlet UIButton *totalButton;
@property (weak, nonatomic) IBOutlet UILabel *totalTitle;
@property (weak, nonatomic) IBOutlet UILabel *totalExplanationText;
@property (weak, nonatomic) IBOutlet UIImageView *logo;

@property BOOL isPresentedModally;

- (IBAction)proAction:(id)sender;
- (IBAction)totalAction:(id)sender;
- (IBAction)noadsAction:(id)sender;

@end

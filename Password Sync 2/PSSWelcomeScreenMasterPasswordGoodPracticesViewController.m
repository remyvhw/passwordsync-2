//
//  PSSWelcomeScreenMasterPasswordGoodPracticesViewController.m
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-07-01.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import "PSSWelcomeScreenMasterPasswordGoodPracticesViewController.h"
#import "UIImage+ImageEffects.h"


@interface PSSWelcomeScreenMasterPasswordGoodPracticesViewController ()
@property (weak, nonatomic) IBOutlet UIButton *continueButton;
@property (weak, nonatomic) IBOutlet UIScrollView *mainScrollView;
@property (weak, nonatomic) IBOutlet UILabel *explaningText;

@end

@implementation PSSWelcomeScreenMasterPasswordGoodPracticesViewController

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
    
    
    NSString * explanationText = NSLocalizedString(@"Choose your master password carefully: not only will you have to remember it but it will also encrypt your database. Therefore, it has to be strong yet rememberable. Simple advice for chosing one: the longer the better, yes, but a random string of letters and numbers is not exactly memorable (unless you're Dustin Hoffman). So to keep things complex yet memorable, try putting random words together, add a couple of numbers and call it a day!", nil);
    
    if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad) {
        
                
        self.explaningText.text = explanationText;
    } else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
        [self.mainScrollView setTranslatesAutoresizingMaskIntoConstraints:NO];
        
        for (UIView * subview in [self.mainScrollView subviews]) {
            [subview setTranslatesAutoresizingMaskIntoConstraints:NO];
        }
        
        self.explaningText.text = explanationText;
        [self.explaningText sizeToFit];
        
        [self.mainScrollView setContentInset:UIEdgeInsetsMake(0, 0, self.navigationController.navigationBar.frame.size.height*2, 0)];
    }
    

}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

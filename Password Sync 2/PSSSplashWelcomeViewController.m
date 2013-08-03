//
//  PSSSplashWelcomeViewController.m
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-07-30.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import "PSSSplashWelcomeViewController.h"
#import "UIImage+ImageEffects.h"

@interface PSSSplashWelcomeViewController ()
@property (weak, nonatomic) IBOutlet UILabel *welcomeText;
@property (weak, nonatomic) IBOutlet UIImageView *topImageView;

@end

@implementation PSSSplashWelcomeViewController

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
    
    NSString * baseWelcomeText = NSLocalizedString(@"Before you use Password Sync to easily and safely sync your passwords, credit cards and notes across your devices, there are a couple of important things we need to configure with you. Don't worry, it'll just take a few minutes of your time.", nil);

    
    
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        // Add background image
        
        UIImage * welcomeImage =[UIImage imageNamed:@"KeyImage.jpg"];
        
        [self.topImageView setImage:[welcomeImage applyLightEffect]];
        self.topImageView.clipsToBounds = YES;
        
        [self.navigationController setNavigationBarHidden:YES];
        
        // Make the welcome text more palatable
        
        NSString * welcomeTitle = NSLocalizedString(@"Welcome to Password Sync", nil);
        
        NSString * enhancedWelcomeText = [NSString stringWithFormat:@"%@\n%@", welcomeTitle, baseWelcomeText];
        
        
        NSMutableAttributedString * mutableWelcomeText = [[NSMutableAttributedString alloc] initWithString:enhancedWelcomeText];
        
        NSRange rangeOfWelcomeLine = [enhancedWelcomeText rangeOfString:welcomeTitle];
        
        [mutableWelcomeText addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-UltraLight" size:38.] range:rangeOfWelcomeLine];
        
        self.welcomeText.attributedText = mutableWelcomeText;
        
        
    } else {
        self.welcomeText.text = baseWelcomeText;
    }
    
        

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end

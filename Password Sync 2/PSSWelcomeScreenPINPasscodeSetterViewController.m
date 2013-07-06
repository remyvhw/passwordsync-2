//
//  PSSWelcomeScreenPINPasscodeSetterViewController.m
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-07-04.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import "PSSWelcomeScreenPINPasscodeSetterViewController.h"
#import "PSSPINpasscodeButtonView.h"
#import "PSSPasscodeVerifyerViewController.h"

@interface PSSWelcomeScreenPINPasscodeSetterViewController ()
@property (weak, nonatomic) IBOutlet PSSPINpasscodeButtonView *pinOneButton;
@property (weak, nonatomic) IBOutlet PSSPINpasscodeButtonView *pinTwoButton;
@property (weak, nonatomic) IBOutlet PSSPINpasscodeButtonView *pinThreeButton;
@property (weak, nonatomic) IBOutlet PSSPINpasscodeButtonView *pinFourButton;
@property (weak, nonatomic) IBOutlet PSSPINpasscodeButtonView *pinFiveButton;
@property (weak, nonatomic) IBOutlet PSSPINpasscodeButtonView *pinSixButton;
@property (weak, nonatomic) IBOutlet PSSPINpasscodeButtonView *pinSevenButton;
@property (weak, nonatomic) IBOutlet PSSPINpasscodeButtonView *pinEightButton;
@property (weak, nonatomic) IBOutlet PSSPINpasscodeButtonView *pinNineButton;
@property (weak, nonatomic) IBOutlet PSSPINpasscodeButtonView *pinZeroButton;
@property (weak, nonatomic) IBOutlet UILabel *captionText;

@property (strong) NSMutableString * passcodeString;
@property (strong) NSMutableString * validationString;

@property PSSPINpasscodeStatus passcodeStatus;

-(void)refreshLabel;
-(IBAction)pressedKeypad:(PSSPINpasscodeButtonView*)sender;

@end

@implementation PSSWelcomeScreenPINPasscodeSetterViewController

-(void)finishWithPasscode:(NSString*)passcode{
    
    PSSPasscodeVerifyerViewController * passcodeVerifyer = [[PSSPasscodeVerifyerViewController alloc] init];
    
    [passcodeVerifyer savePasscode:passcode withType:PSSPasscodeTypeNIPcode];
    
    
    [self performSegueWithIdentifier:@"userFinishedSettingPINPasscodeSegue" sender:nil];
}

-(void)refreshLabel{
    
    [UIView animateWithDuration:0.07 animations:^{
        [self.captionText setAlpha:0.0];
        [self.captionText setCenter:CGPointMake(self.captionText.center.x-10., self.captionText.center.y)];
        
    } completion:^(BOOL finished) {
        [self.captionText setCenter:CGPointMake(self.captionText.center.x+20., self.captionText.center.y)];
        // Edit the text
        switch (self.passcodeStatus) {
            case PSSPINpasscodeStatusUndefined:
                self.captionText.text = NSLocalizedString(@"Enter a 5 digits passcode.", nil);
                break;
            case PSSPINpasscodeStatusOne:
                self.captionText.text = @"◉○○○○";
                break;
            case PSSPINpasscodeStatusTwo:
                self.captionText.text = @"◉◉○○○";
                break;
            case PSSPINpasscodeStatusThree:
                self.captionText.text = @"◉◉◉○○";
                break;
            case PSSPINpasscodeStatusFour:
                self.captionText.text = @"◉◉◉◉○";
                break;
            case PSSPINpasscodeStatusValidateOne:
                self.captionText.text = @"◉○○○○";
                break;
            case PSSPINpasscodeStatusValidateTwo:
                self.captionText.text = @"◉◉○○○";
                break;
            case PSSPINpasscodeStatusValidateThree:
                self.captionText.text = @"◉◉◉○○";
                break;
            case PSSPINpasscodeStatusValidateFour:
                self.captionText.text = @"◉◉◉◉○";
                break;
            case PSSPINpasscodeStatusValidate:
                self.captionText.text = NSLocalizedString(@"Re-enter your passcode", nil);
                break;
            case PSSPINpasscodeStatusInvalid:
                self.captionText.text = NSLocalizedString(@"Passcodes did not match, try again", nil);
                break;
            default:
                break;
        }
        
       [UIView animateWithDuration:0.07 animations:^{
           [self.captionText setCenter:CGPointMake(self.captionText.center.x-10., self.captionText.center.y)];
           [self.captionText setAlpha:1.0];
           
       }];
        
        
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

-(NSInteger)accessibilityElementCount{
    return 11;
}

-(id)accessibilityElementAtIndex:(NSInteger)index{
    
    switch (index) {
        case 0:
            return self.captionText;
        case 1:
            return self.pinOneButton;
        case 2:
            return self.pinTwoButton;
        case 3:
            return self.pinThreeButton;
        case 4:
            return self.pinFourButton;
        case 5:
            return self.pinFiveButton;
        case 6:
            return self.pinSixButton;
        case 7:
            return self.pinSevenButton;
        case 8:
            return self.pinEightButton;
        case 9:
            return self.pinNineButton;
        case 10:
            return self.pinZeroButton;
    }

    return self.captionText;
}

-(NSInteger)indexOfAccessibilityElement:(id)element{
    
    
    if (element == self.captionText) {
        return 0;
    }
    
    if (element == self.pinZeroButton) {
        return 10;
    }
    
    if (element == self.pinOneButton) {
        return 1;
    }
    
    if (element == self.pinTwoButton) {
        return 2;
    }
    
    if (element == self.pinThreeButton) {
        return 3;
    }
    
    if (element == self.pinFourButton) {
        return 4;
    }
    
    if (element == self.pinFiveButton) {
        return 5;
    }
    
    if (element == self.pinSixButton) {
        return 6;
    }
    
    if (element == self.pinSevenButton) {
        return 7;
    }
    
    if (element == self.pinEightButton) {
        return 8;
    }
    
    if (element == self.pinNineButton) {
        return 9;
    }
    
    return 0;
}

-(BOOL)shouldGroupAccessibilityChildren{
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.pinZeroButton.passcodeNumber = PSSPINpasscodeButtonNumberZero;
    self.pinOneButton.passcodeNumber = PSSPINpasscodeButtonNumberOne;
    self.pinTwoButton.passcodeNumber = PSSPINpasscodeButtonNumberTwo;
    self.pinThreeButton.passcodeNumber = PSSPINpasscodeButtonNumberThree;
    self.pinFourButton.passcodeNumber = PSSPINpasscodeButtonNumberFour;
    self.pinFiveButton.passcodeNumber = PSSPINpasscodeButtonNumberFive;
    self.pinSixButton.passcodeNumber = PSSPINpasscodeButtonNumberSix;
    self.pinSevenButton.passcodeNumber = PSSPINpasscodeButtonNumberSeven;
    self.pinEightButton.passcodeNumber = PSSPINpasscodeButtonNumberEight;
    self.pinNineButton.passcodeNumber = PSSPINpasscodeButtonNumberNine;
    
    self.passcodeStatus = PSSPINpasscodeStatusUndefined;
    
    self.passcodeString = [[NSMutableString alloc] initWithCapacity:5];

    
    [self refreshLabel];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(IBAction)pressedKeypad:(PSSPINpasscodeButtonView*)sender{
    
    if (self.passcodeStatus == PSSPINpasscodeStatusUndefined || self.passcodeStatus == PSSPINpasscodeStatusInvalid) {
        [self.passcodeString appendString:[sender numberForCurrentPasscodeNumber]];
        self.passcodeStatus = PSSPINpasscodeStatusOne;
    } else if (self.passcodeStatus == PSSPINpasscodeStatusOne){
        [self.passcodeString appendString:[sender numberForCurrentPasscodeNumber]];
        self.passcodeStatus = PSSPINpasscodeStatusTwo;
    } else if (self.passcodeStatus == PSSPINpasscodeStatusTwo){
        [self.passcodeString appendString:[sender numberForCurrentPasscodeNumber]];
        self.passcodeStatus = PSSPINpasscodeStatusThree;
    } else if (self.passcodeStatus == PSSPINpasscodeStatusThree){
        [self.passcodeString appendString:[sender numberForCurrentPasscodeNumber]];
        self.passcodeStatus = PSSPINpasscodeStatusFour;
    } else if (self.passcodeStatus == PSSPINpasscodeStatusFour){
        [self.passcodeString appendString:[sender numberForCurrentPasscodeNumber]];
        self.validationString = [[NSMutableString alloc] initWithCapacity:5];
        self.passcodeStatus = PSSPINpasscodeStatusValidate;
    } else if (self.passcodeStatus == PSSPINpasscodeStatusValidate){
        [self.validationString appendString:[sender numberForCurrentPasscodeNumber]];
        self.passcodeStatus = PSSPINpasscodeStatusValidateOne;
    } else if (self.passcodeStatus == PSSPINpasscodeStatusValidateOne){
        [self.validationString appendString:[sender numberForCurrentPasscodeNumber]];
        self.passcodeStatus = PSSPINpasscodeStatusValidateTwo;
    } else if (self.passcodeStatus == PSSPINpasscodeStatusValidateTwo){
        [self.validationString appendString:[sender numberForCurrentPasscodeNumber]];
        self.passcodeStatus = PSSPINpasscodeStatusValidateThree;
    } else if (self.passcodeStatus == PSSPINpasscodeStatusValidateThree){
        [self.validationString appendString:[sender numberForCurrentPasscodeNumber]];
        self.passcodeStatus = PSSPINpasscodeStatusValidateFour;
    } else if (self.passcodeStatus == PSSPINpasscodeStatusValidateFour){
        [self.validationString appendString:[sender numberForCurrentPasscodeNumber]];
        
        // Now verify if passcode was correctly typed
        
        if ([self.validationString isEqualToString:self.passcodeString]) {
            // Passcode is valid
            [self finishWithPasscode:self.passcodeString];
        } else {
            // Oops, invalid passcode. Retry
            self.passcodeString = [[NSMutableString alloc] initWithCapacity:5];
            self.passcodeStatus = PSSPINpasscodeStatusInvalid;
        }
    }
    
      
    [self refreshLabel];
    
    
}
@end

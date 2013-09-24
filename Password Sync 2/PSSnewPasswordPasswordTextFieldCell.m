//
//  PSSnewPasswordPasswordTextFieldCell.m
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-07-12.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import "PSSnewPasswordPasswordTextFieldCell.h"


@implementation PSSnewPasswordPasswordTextFieldCell

-(void)hideShuffleIconAnimated:(BOOL)animated{
    
}



- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self.textField setSecureTextEntry:YES];
        self.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        self.textField.autocorrectionType = UITextAutocorrectionTypeNo;
        
        UIButton * shuffleButton = [[UIButton alloc] init];
        UIImage * shuffleImage = [UIImage imageNamed:@"Shuffle"];
        
        [shuffleButton setImage:[shuffleImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        self.shuffleButton = shuffleButton;
        [self.shuffleButton setAlpha:0.0];
        [self addSubview:self.shuffleButton];
        
        
        PSSPasswordStrengthGaugeView * gaugeView = [[PSSPasswordStrengthGaugeView alloc] init];
        self.strengthGauge = gaugeView;
        [self addSubview:self.strengthGauge];
        
    }
    return self;
}

-(void)toggleGeneratorButtonAnimated:(BOOL)animated password:(NSString*)password{
    
    NSTimeInterval duration = 0;
    if (animated) {
        duration = 0.2;
    }
    
    if (!password) {
        password = self.textField.text;
    }
    
    [UIView animateWithDuration:duration animations:^{
        
        
        if ([password isEqualToString:@""]) {
            // When the text is empty, we show the generator icon
            [self.shuffleButton setFrame:CGRectMake(self.frame.size.width-50, self.textField.frame.origin.y, 50., self.textField.frame.size.height)];
            [self.textField setFrame:CGRectMake(self.textField.frame.origin.x, self.textField.frame.origin.y, self.frame.size.width - 60., self.textField.frame.size.height)];
            [self.shuffleButton setAlpha:1.0];
            
            // We also (re)introduce the secure text
            [self.textField setSecureTextEntry:YES];
        } else {
            [self.shuffleButton setAlpha:0.0];
            [self.textField setFrame:CGRectMake(self.textField.frame.origin.x, self.textField.frame.origin.y, self.frame.size.width - 20, self.textField.frame.size.height)];
        }

    }];
    
    
}

-(void)layoutSubviews{
    [super layoutSubviews];
    
    
    // We slightly resize the textfield so we can add a password indicator gauge under
    [self.textField setFrame:CGRectMake(self.textField.frame.origin.x, self.textField.frame.origin.y, self.textField.frame.size.width, self.textField.frame.size.height-7-4)];
    
    [self.strengthGauge setFrame:CGRectMake(self.textField.frame.origin.x, self.textField.frame.origin.y+self.textField.frame.size.height+7., self.textField.frame.size.width, 4)];
    
    
    [self toggleGeneratorButtonAnimated:NO password:self.textField.text];
    
}

-(void)setUnsecureTextPassword:(NSString *)password{
    
    self.textField.secureTextEntry = NO;
    self.textField.text = password;
    
    [self updateLayoutForNewPassword:password];
}

-(void)updateLayoutForNewPassword:(NSString*)password{
    
    [self.strengthGauge updateGaugeForString:password];
    
    [self toggleGeneratorButtonAnimated:YES password:password];
    
    
    
}

#pragma mark - UITextFieldDelegate methods

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    // Intercept each keystroke so we can adjust the gauge and remove the random generator button
    
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    [self updateLayoutForNewPassword:newString];
    
    
    return YES;
}

@end

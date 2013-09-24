//
//  PSSnewCardNumberTextFieldCell.m
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-07-14.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import "PSSnewCardNumberTextFieldCell.h"



@implementation PSSnewCardNumberTextFieldCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.textField.keyboardType = UIKeyboardTypeNumberPad;
        
        UIButton * cameraButton = [[UIButton alloc] init];
        UIImage * cameraImage = [UIImage imageNamed:@"Camera"];
        
        [cameraButton setImage:[cameraImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        self.cameraButton = cameraButton;
        [self.cameraButton setAlpha:0.0];
        [self addSubview:self.cameraButton];
        
        self.finishedEditingNumberBlock = nil;
        
    }
    return self;
}

-(void)setCardNumber:(NSString *)string{
    [self.textField setText:string];
    if (self.finishedEditingNumberBlock)
        self.finishedEditingNumberBlock();
}

-(void)layoutSubviews{
    [super layoutSubviews];
    
    
    [self.cameraButton setFrame:CGRectMake(self.frame.size.width-50, self.textField.frame.origin.y, 50., self.textField.frame.size.height)];
    [self.textField setFrame:CGRectMake(self.textField.frame.origin.x, self.textField.frame.origin.y, self.frame.size.width - 50., self.textField.frame.size.height)];
    [self.cameraButton setAlpha:1.0];
    
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    // Intercept each keystroke so we can adjust the gauge and remove the random generator button
    
    if ([string isEqualToString:@" "]) {
        return NO;
    }
    
    return YES;
}


-(void)textFieldDidEndEditing:(UITextField *)textField{
    if (self.finishedEditingNumberBlock)
        self.finishedEditingNumberBlock();
}



@end

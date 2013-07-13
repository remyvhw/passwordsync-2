//
//  PSSnewPasswordPasswordTextFieldCell.h
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-07-12.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import "PSSnewPasswordBasicTextFieldCell.h"
#import "PSSPasswordStrengthGaugeView.h"

@interface PSSnewPasswordPasswordTextFieldCell : PSSnewPasswordBasicTextFieldCell 

@property (strong) UIButton * shuffleButton;
@property (strong) PSSPasswordStrengthGaugeView * strengthGauge;

-(void)setUnsecureTextPassword:(NSString*)password;
/// @description Will make the text field unsecure and insert the password

@end

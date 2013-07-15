//
//  PSSnewCardNumberTextFieldCell.h
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-07-14.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import "PSSnewPasswordBasicTextFieldCell.h"

typedef void(^PSSfinishedEditingNumberBlock)(void);

@interface PSSnewCardNumberTextFieldCell : PSSnewPasswordBasicTextFieldCell


@property (strong) UIButton * cameraButton;
@property (strong) PSSfinishedEditingNumberBlock finishedEditingNumberBlock;

-(void)setCardNumber:(NSString*)string;

@end

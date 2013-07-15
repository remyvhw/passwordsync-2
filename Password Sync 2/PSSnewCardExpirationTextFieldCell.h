//
//  PSSnewCardExpirationTextFieldCell.h
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-07-14.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import "PSSnewPasswordBasicTextFieldCell.h"

@interface PSSnewCardExpirationTextFieldCell : PSSnewPasswordBasicTextFieldCell

@property (strong, nonatomic) UITextField * cvvField;

-(void)setExpirationDate:(NSString*)expirationDate;

@end

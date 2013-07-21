//
//  PSSlocationSearchTextFieldCell.h
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-07-20.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import "PSSnewPasswordBasicTextFieldCell.h"

typedef void(^PSSfinishedEditingAddressBlock)(void);


@interface PSSlocationSearchTextFieldCell : PSSnewPasswordBasicTextFieldCell

@property (strong) UIButton * searchButton;
@property (strong) PSSfinishedEditingAddressBlock finishedEditingAddressBlock;

@property BOOL isGeocoding;

@end

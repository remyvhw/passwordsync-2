//
//  PSSnewPasswordBasicTextFieldCell.h
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-07-10.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PSSnewPasswordBasicTextFieldCell : UITableViewCell <UITextFieldDelegate>

@property (strong) IBOutlet UITextField * textField;

@property (weak) id nextFormField;

@end

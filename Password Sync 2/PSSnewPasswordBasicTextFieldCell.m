//
//  PSSnewPasswordBasicTextFieldCell.m
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-07-10.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import "PSSnewPasswordBasicTextFieldCell.h"

@implementation PSSnewPasswordBasicTextFieldCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        UITextField * textField = [[UITextField alloc] init];
        textField.delegate = self;
        [textField setBackgroundColor:[UIColor clearColor]];
        [self addSubview:textField];
        self.textField = textField;
        
        
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.textField.frame = CGRectMake(20.0, 7., self.frame.size.width-40, self.frame.size.height-14);
    
    
    
}


#pragma mark - UITextFieldDelegate

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    
    // Change the return button accordingly
    if (self.nextFormField) {
        [self.textField setReturnKeyType:UIReturnKeyNext];
    } else {
        [self.textField setReturnKeyType:UIReturnKeyDone];
    }
    
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    
    if (self.nextFormField) {
        [self.nextFormField becomeFirstResponder];
    } else {
        [self resignFirstResponder];
    }
    
    
    return NO;
}

@end

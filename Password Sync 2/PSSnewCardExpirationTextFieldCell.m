//
//  PSSnewCardExpirationTextFieldCell.m
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-07-14.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import "PSSnewCardExpirationTextFieldCell.h"

@implementation PSSnewCardExpirationTextFieldCell


-(void)createLightGraySlashOnExpirationDateWithString:(NSString*)adjustedText{
    NSMutableAttributedString * attributedExpiration = [[NSMutableAttributedString alloc] initWithString:adjustedText];
    if ([attributedExpiration length] == 7) {
        
        [attributedExpiration addAttribute:NSForegroundColorAttributeName value:[UIColor lightGrayColor] range:NSMakeRange(2, 1)];
        
        self.textField.attributedText = attributedExpiration;
        
    }
}

-(void)setExpirationDate:(NSString *)expirationDate{
    [self createLightGraySlashOnExpirationDateWithString:expirationDate];
}


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        UITextField * cvvTextField = [[UITextField alloc] init];
        cvvTextField.delegate = self;
        [cvvTextField setBackgroundColor:[UIColor clearColor]];
        [self addSubview:cvvTextField];
        self.cvvField = cvvTextField;
        
        self.textField.keyboardType = UIKeyboardTypeNumberPad;
        self.cvvField.keyboardType = UIKeyboardTypeNumberPad;
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    
    // Reframe the Textfields so they line up on the same line
    self.textField.frame = CGRectMake(self.textField.frame.origin.x, self.textField.frame.origin.y, (self.textField.frame.size.width)*0.6-10, self.textField.frame.size.height);
    
    self.cvvField.frame = CGRectMake(self.textField.frame.origin.x+self.textField.frame.size.width+20, self.textField.frame.origin.y, self.frame.size.width-40-20-self.textField.frame.size.width, self.textField.frame.size.height);
    
    [self setNeedsDisplay];
    
    
}



#pragma mark - UITextFieldDelegate methods

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    
    if (textField == self.cvvField) {
        return [super textFieldShouldReturn:textField];
    } else {
        
        [self.cvvField becomeFirstResponder];
        
    }
    
    
    return NO;
}


-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    // Intercept each keystroke so we can adjust the gauge and remove the random generator button
    
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if (textField == self.textField) {
        
        if ([newString length] == 3 && [[newString stringByReplacingOccurrencesOfString:@"/" withString:@""] length] == 3) {
            textField.text = [NSString stringWithFormat:@"%@/", textField.text];
            return YES;
        } else if ([[newString stringByReplacingOccurrencesOfString:@"/" withString:@""] length] > 6) {
            // We already have a complete date. Pass to next responder and do not let more characters in.
            return NO;
        }
        
    } else if (textField == self.cvvField) {
        // Prevent text from being longer than 4 characters
        if ([newString length] > 4) {
            
            if (self.nextFormField) {
                [self.nextFormField becomeFirstResponder];
            }
            
            return NO;
        }
    }
    
    
    return YES;
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    if (textField==self.textField) {
        // We'll add a bit of color to our textfield
        
        NSMutableString * adjustedText = [NSMutableString stringWithString:self.textField.text];
        
        if ([adjustedText length] == 5 && [[adjustedText stringByReplacingOccurrencesOfString:@"/" withString:@""] length] == 4) {
            // Just add a "20" to the year part
            [adjustedText insertString:@"20" atIndex:3];
        }
        
        
        [self createLightGraySlashOnExpirationDateWithString:adjustedText];
        
    }
}

@end

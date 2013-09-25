//
//  PSSlocationSearchTextFieldCell.m
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-07-20.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import "PSSlocationSearchTextFieldCell.h"

@interface PSSlocationSearchTextFieldCell ()

@property (strong, nonatomic) UIActivityIndicatorView * spinnerView;

@end

@implementation PSSlocationSearchTextFieldCell
@synthesize isGeocoding = _isGeocoding;

-(void)showSearchButton{
    if (self.localizeButton.alpha != 0.0 || self.searchButton.alpha != 1.0) {
        [UIView animateWithDuration:0.2 animations:^{
            [self.localizeButton setAlpha:0.0];
            [self.searchButton setAlpha:1.0];
        }];
    }
    
}

-(void)showLocalizeButton{
    if (self.searchButton.alpha != 0.0 || self.localizeButton.alpha != 1.0) {
        [UIView animateWithDuration:0.2 animations:^{
            [self.localizeButton setAlpha:1.0];
            [self.searchButton setAlpha:0.];
        }];
    }

}

-(void)setIsGeocoding:(BOOL)isGeocoding{
    
    if (isGeocoding) {
        [self.spinnerView setHidden:NO];
        [UIView animateWithDuration:0.1 animations:^{
            [self.spinnerView setAlpha:1.0];
            [self.searchButton setAlpha:0.0];
            [self.localizeButton setAlpha:0.0];
        } completion:^(BOOL finished) {
            [self.searchButton setHidden:YES];
            [self.spinnerView startAnimating];
            
            [self.textField setEnabled:NO];
        }];
        
        
    } else {
        [self.searchButton setHidden:NO];
        [UIView animateWithDuration:0.1 animations:^{
            [self.spinnerView setAlpha:0.0];
            [self.searchButton setAlpha:1.0];
        } completion:^(BOOL finished) {
            
            [self.spinnerView stopAnimating];
            [self.spinnerView setHidden:YES];
            [self.textField setEnabled:YES];
        }];
        
       
    }
    
    _isGeocoding = isGeocoding;
}

-(BOOL)isGeocoding{
    return _isGeocoding;
}

-(void)searchButtonPressed:(id)sender{
    
    if (self.isGeocoding) {
        return;
    }
    
    // To avoid firing the block twice, we just dismiss the keyboard
    if ([self.textField isFirstResponder]) {
        [self.textField resignFirstResponder];
    } else {
        if (self.finishedEditingAddressBlock) {
            self.finishedEditingAddressBlock();
        }

    }
    
}

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.isGeocoding = NO;

        
        UIButton * searchButton = [[UIButton alloc] init];
        UIImage * searchImage = [UIImage imageNamed:@"Search"];
        [searchButton addTarget:self action:@selector(searchButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [searchButton setImage:[searchImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        self.searchButton = searchButton;
        [self.searchButton setAlpha:0.0];
        [self addSubview:self.searchButton];
        
        UIButton * localizeButton = [[UIButton alloc] init];
        UIImage * localizeImage = [UIImage imageNamed:@"Locate"];
        [localizeButton setImage:[localizeImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        self.localizeButton = localizeButton;
        [self addSubview:self.localizeButton];
        
        UIActivityIndicatorView * spinnerView = [[UIActivityIndicatorView alloc] init];
        spinnerView.hidesWhenStopped = YES;
        [spinnerView setColor:[UIColor lightGrayColor]];
        self.spinnerView = spinnerView;
        [self addSubview:spinnerView];
        
        
        
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    
    
    [self.searchButton setFrame:CGRectMake(self.frame.size.width-50, self.textField.frame.origin.y, 50., self.textField.frame.size.height)];
    [self.localizeButton setFrame:CGRectMake(self.frame.size.width-50, self.textField.frame.origin.y, 50., self.textField.frame.size.height)];
    [self.textField setFrame:CGRectMake(self.textField.frame.origin.x, self.textField.frame.origin.y, self.frame.size.width - 60., self.textField.frame.size.height)];
    
    
    [self.spinnerView setFrame:self.searchButton.frame];
    
    if (![self.textField.text isEqualToString:@""]) {
        // Textfield is not empty, do not show the localize button
        [self.localizeButton setAlpha:0.0];
    }
}


-(void)textFieldDidBeginEditing:(UITextField *)textField{
    if (![self.textField.text isEqualToString:@""]) {
        // The textfield is not empty, show ths search button
        [self showSearchButton];
    }
}

-(void)textFieldDidEndEditing:(UITextField *)textField{

    if (self.isGeocoding) {
        return;
    }
    
    if (self.finishedEditingAddressBlock)
        self.finishedEditingAddressBlock();
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSRange textFieldRange = NSMakeRange(0, [textField.text length]);
    if (NSEqualRanges(range, textFieldRange) && [string length] == 0) {
        // The field is empty, show to the location pin
        [self showLocalizeButton];
    } else {
        // Field is not empty, show the search button
        [self showSearchButton];
    }
    return YES;
}

@end

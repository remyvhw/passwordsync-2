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


-(void)setIsGeocoding:(BOOL)isGeocoding{
    
    if (isGeocoding) {
        [self.spinnerView setHidden:NO];
        [UIView animateWithDuration:0.1 animations:^{
            [self.spinnerView setAlpha:1.0];
            [self.searchButton setAlpha:0.0];
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
        UIButton * searchButton = [[UIButton alloc] init];
        UIImage * searchImage = [UIImage imageNamed:@"Search"];
        [searchButton addTarget:self action:@selector(searchButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [searchButton setImage:[searchImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        self.searchButton = searchButton;
        [self.searchButton setAlpha:0.0];
        [self addSubview:self.searchButton];
        
        UIActivityIndicatorView * spinnerView = [[UIActivityIndicatorView alloc] init];
        spinnerView.hidesWhenStopped = YES;
        [spinnerView setColor:[UIColor lightGrayColor]];
        self.spinnerView = spinnerView;
        [self addSubview:spinnerView];
        
        self.isGeocoding = NO;
        
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    
    
    [self.searchButton setFrame:CGRectMake(self.frame.size.width-40, self.textField.frame.origin.y, 20., self.textField.frame.size.height)];
    [self.textField setFrame:CGRectMake(self.textField.frame.origin.x, self.textField.frame.origin.y, self.frame.size.width - 60., self.textField.frame.size.height)];
    [self.searchButton setAlpha:1.0];
    
    
    [self.spinnerView setFrame:self.searchButton.frame];
    
}



-(void)textFieldDidEndEditing:(UITextField *)textField{
    if (self.isGeocoding) {
        return;
    }
    
    if (self.finishedEditingAddressBlock)
        self.finishedEditingAddressBlock();
}


@end

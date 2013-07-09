//
//  PSSFormSimpleFieldCell.m
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-07-08.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import "PSSFormSimpleFieldCell.h"

@implementation PSSFormSimpleFieldCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        UITextField * textField = [[UITextField alloc] initWithFrame:self.frame];
        self.textField = textField;
        [self addSubview:self.textField];
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

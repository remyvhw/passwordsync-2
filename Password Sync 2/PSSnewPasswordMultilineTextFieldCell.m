//
//  PSSnewPasswordMultilineTextFieldCell.m
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-07-11.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import "PSSnewPasswordMultilineTextFieldCell.h"

@implementation PSSnewPasswordMultilineTextFieldCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        UITextView * textView = [[UITextView alloc] init];
        [textView setBackgroundColor:[UIColor clearColor]];
        [self addSubview:textView];
        self.textView = textView;

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
    self.textView.frame = CGRectMake(20.0, 7., self.frame.size.width-40, self.frame.size.height-14);
}

@end

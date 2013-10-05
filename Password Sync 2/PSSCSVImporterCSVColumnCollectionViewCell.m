//
//  PSSCSVImporterCSVColumnCollectionViewCell.m
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-10-03.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import "PSSCSVImporterCSVColumnCollectionViewCell.h"

@interface PSSCSVImporterCSVColumnCollectionViewCell ()

@property (nonatomic, strong) UIImageView * emptyCellLogo;

@end

@implementation PSSCSVImporterCSVColumnCollectionViewCell
@synthesize emptyColumn = _emptyColumn;

-(void)setEmptyColumn:(BOOL)emptyColumn{
    _emptyColumn = emptyColumn;
    
    [self.emptyCellLogo setHidden:!emptyColumn];
    [self.columnContent setHidden:emptyColumn];
}

-(BOOL)emptyColumn{
    return _emptyColumn;
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    
    if (selected) {
        
    } else {
        
    }
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        UILabel * columnIndicator = [[UILabel alloc] init];
        [columnIndicator setTextAlignment:NSTextAlignmentCenter];
        [columnIndicator setTextColor:[UIColor lightGrayColor]];
        [self addSubview:columnIndicator];
        self.columnIndicator = columnIndicator;
        
        UILabel * columnContent = [[UILabel alloc] init];
        [columnContent setTextColor:[UIColor darkGrayColor]];
        [self addSubview:columnContent];
        columnContent.numberOfLines = 15;
        self.columnContent = columnContent;
        
        UIImageView * emptyCellLogo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Empty"]];
        emptyCellLogo.contentMode = UIViewContentModeCenter;
        [self addSubview:emptyCellLogo];
        self.emptyCellLogo = emptyCellLogo;
    }
    return self;
}

-(void)layoutSubviews{
    
    self.columnIndicator.frame = CGRectMake(10., 0, self.bounds.size.width-20, 30);
    self.emptyCellLogo.frame = CGRectMake(10, 40, self.bounds.size.width-20, self.bounds.size.height-39);
    self.columnContent.frame = CGRectMake(20, 50, self.bounds.size.width-40, self.bounds.size.height-59);

    
}

- (void)drawRect:(CGRect)rect
{
    
    //// Color Declarations
    UIColor* fillColor = [UIColor groupTableViewBackgroundColor];
    
    //// Rectangle Drawing
    UIBezierPath* rectanglePath = [UIBezierPath bezierPathWithRect: CGRectMake(10, 40, rect.size.width-20, rect.size.height-39)];
    [fillColor setFill];
    [rectanglePath fill];
    
    
}


@end

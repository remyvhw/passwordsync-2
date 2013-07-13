//
//  PSSPasswordStrengthGaugeView.m
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-07-12.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import "PSSPasswordStrengthGaugeView.h"

@interface PSSPasswordStrengthGaugeView ()

@property (strong) NSArray * commonPasswordsArray;

@end

@implementation PSSPasswordStrengthGaugeView

-(PSSPasswordStrengthLevel)strengthLevelForString:(NSString*)password{
    
    if ([password isEqualToString:@""]) {
        return PSSPasswordStrengthLevelNone;
    }
    
    
    NSInteger score = 0;
    
    
    // Check if password (with or without uppercases is in the most common pass dict.
    if (!self.commonPasswordsArray) {
        // Lazy load the array
        NSString * filePath = [[NSBundle mainBundle] pathForResource:@"commonPassDict" ofType:@"plist"];
        NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:filePath];
        self.commonPasswordsArray = (NSArray*)[dict objectForKey:@"Root"];
    }
    
    if ([self.commonPasswordsArray containsObject:password] || [self.commonPasswordsArray containsObject:[password lowercaseString]]) {
        return PSSPasswordStrengthLevelLow;
    }
    
    
    // if the password is lower than 8, return weak
    if ([password length] <= 8) {
        return PSSPasswordStrengthLevelLow;
    }
    
    
    if ([password length] > 12) {
        score++;
    }
    
    
    if ([password length] > 14) {
        score++;
    }
    
    
    if ([password length] > 20) {
        score++;
    }
    
    if ([password length] > 24) {
        score++;
    }
    
    
    BOOL containsLetterDigitsCombo = YES;
    BOOL containsLettersDigitsAndSpecialCharactersCombo = YES;
    
    // If the password contains numbers, give it one point
    NSRegularExpression * digitsPattern = [NSRegularExpression regularExpressionWithPattern:@"[0-9]+(\\.[0-9][0-9]?)?" options:0 error:NULL];
    NSTextCheckingResult *digitsMatch = [digitsPattern firstMatchInString:password options:0 range:NSMakeRange(0, [password length])];
    if (digitsMatch) {
        // Contains letters
        score++;
    } else {
        containsLetterDigitsCombo = NO;
        containsLettersDigitsAndSpecialCharactersCombo = NO;
    }
    
    
    // If the password both uppercase and lowercase latin letters
    NSRegularExpression * lettersPattern = [NSRegularExpression regularExpressionWithPattern:@"^(?=.*[a-z])(?=.*[A-Z]).+$" options:0 error:NULL];
    NSTextCheckingResult *lettersMatch = [lettersPattern firstMatchInString:password options:0 range:NSMakeRange(0, [password length])];
    if (lettersMatch) {
        // Contains letters
        score++;
    } else {
        containsLetterDigitsCombo = NO;
        containsLettersDigitsAndSpecialCharactersCombo = NO;
    }
    
    
    // If the password contains special characters
    NSRegularExpression * charPattern = [NSRegularExpression regularExpressionWithPattern:@"[!,@,#,$,%,^,&,*,?,_,~,-,£,(,)]" options:0 error:NULL];
    NSTextCheckingResult *charMatch = [charPattern firstMatchInString:password options:0 range:NSMakeRange(0, [password length])];
    if (charMatch) {
        // Contains letters
        score++;
    } else {
        containsLettersDigitsAndSpecialCharactersCombo = NO;
    }
    
    
    // Check for repeated words
    NSRegularExpression * repeatedWordsPattern = [NSRegularExpression regularExpressionWithPattern:@"\\b(\\w+)\\s+\\1\\b" options:0 error:NULL];
    NSTextCheckingResult *repeatedWordsMatch = [repeatedWordsPattern firstMatchInString:password options:0 range:NSMakeRange(0, [password length])];
    if (repeatedWordsMatch) {
        // Contains repeated words. Substract 2 points.
        score--;
        score--;
    }
    
    
    
    
    if (containsLetterDigitsCombo) {
        score ++;
    }
    
    if (containsLettersDigitsAndSpecialCharactersCombo) {
        score ++;
    }
    
    // Put the score on a 100 scale
    CGFloat percentScore = (score*100)/8;
    
    
    if (percentScore < 25.) {
        return PSSPasswordStrengthLevelLow;
    } else if (percentScore < 50) {
        return PSSPasswordStrengthLevelMedium;
    } else if (percentScore < 75){
        return PSSPasswordStrengthLevelHigh;
    } else if (percentScore <= 100){
        return PSSPasswordStrengthLevelHighest;
    }
    
    
    
    return PSSPasswordStrengthLevelLow;
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

-(CGFloat)indicatorWidthForRect:(CGRect)rect{
    CGFloat floatingPointWidth = (rect.size.width-8.)/4;
    return ceilf(floatingPointWidth);
}

-(void)drawLowLevelIndicatorInRect:(CGRect)rect colorize:(BOOL)colorize{
    //// Color Declarations
    
    UIColor* fillColor;
    if (colorize) {
       fillColor = [UIColor colorWithRed: 143./255. green: 45./255. blue: 50./255. alpha: 1];
    } else {
        fillColor = [UIColor groupTableViewBackgroundColor];
    }
    
    //// Rectangle Drawing
    
    CGFloat gaugeWidth = [self indicatorWidthForRect:rect];
    CGFloat gaugeOrigin = 1.+0*gaugeWidth;
    CGFloat gaugeHeight = rect.size.height-2;
    UIBezierPath* gaugePath = [UIBezierPath bezierPathWithRect: CGRectMake(gaugeOrigin, 1, gaugeWidth, gaugeHeight)];
    [fillColor setFill];
    [gaugePath fill];
    
}

-(void)drawMediumLevelIndicatorInRect:(CGRect)rect colorize:(BOOL)colorize{
    
    //// Color Declarations
   
    UIColor* fillColor;
    if (colorize) {
        fillColor = [UIColor colorWithRed: 143./255. green: 89./255. blue: 45./255. alpha: 1];
    } else {
        fillColor = [UIColor groupTableViewBackgroundColor];
    }
    
    //// Rectangle Drawing
    
    CGFloat gaugeWidth = [self indicatorWidthForRect:rect];
    CGFloat gaugeOrigin = 1.+2.+1*gaugeWidth;
    CGFloat gaugeHeight = rect.size.height-2;
    UIBezierPath* gaugePath = [UIBezierPath bezierPathWithRect: CGRectMake(gaugeOrigin, 1, gaugeWidth, gaugeHeight)];
    [fillColor setFill];
    [gaugePath fill];
}

-(void)drawHighLevelIndicatorInRect:(CGRect)rect colorize:(BOOL)colorize{
   
    //// Color Declarations
  
    UIColor* fillColor;
    if (colorize) {
        fillColor = [UIColor colorWithRed: 143./255. green: 139./255. blue: 45./255. alpha: 1];
    } else {
        fillColor = [UIColor groupTableViewBackgroundColor];
    }
    
    //// Rectangle Drawing
    
    CGFloat gaugeWidth = [self indicatorWidthForRect:rect];
    CGFloat gaugeOrigin = 1.+2+2.+2*gaugeWidth;
    CGFloat gaugeHeight = rect.size.height-2;
    UIBezierPath* gaugePath = [UIBezierPath bezierPathWithRect: CGRectMake(gaugeOrigin, 1, gaugeWidth, gaugeHeight)];
    [fillColor setFill];
    [gaugePath fill];
}

-(void)drawHighestLevelIndicatorInRect:(CGRect)rect colorize:(BOOL)colorize{
    
    //// Color Declarations
    UIColor* fillColor;
    if (colorize) {
        fillColor = [UIColor colorWithRed: 46./255. green: 144./255. blue: 90./255. alpha: 1];
    } else {
        fillColor = [UIColor groupTableViewBackgroundColor];
    }
    
    //// Rectangle Drawing
    
    CGFloat gaugeWidth = [self indicatorWidthForRect:rect];
    CGFloat gaugeOrigin = 1.+2.+2+2.+3*gaugeWidth;
    CGFloat gaugeHeight = rect.size.height-2;
    UIBezierPath* gaugePath = [UIBezierPath bezierPathWithRect: CGRectMake(gaugeOrigin, 1, gaugeWidth, gaugeHeight)];
    [fillColor setFill];
    [gaugePath fill];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    
    BOOL level4 = NO;
    BOOL level3 = NO;
    BOOL level2 = NO;
    BOOL level1 = NO;
    
    switch (self.strengthLevel) {
        case PSSPasswordStrengthLevelHighest:
            level4 = YES;
        case PSSPasswordStrengthLevelHigh:
            level3 = YES;
        case PSSPasswordStrengthLevelMedium:
            level2 = YES;
        case PSSPasswordStrengthLevelLow:
            level1 = YES;
        case PSSPasswordStrengthLevelNone:
        default:
            break;
    }
    
    
    if (level4) {
        [self drawHighestLevelIndicatorInRect:rect colorize:YES];
    } else {
        [self drawHighestLevelIndicatorInRect:rect colorize:NO];
    }

    if (level3) {
        [self drawHighLevelIndicatorInRect:rect colorize:YES];
    } else {
        [self drawHighLevelIndicatorInRect:rect colorize:NO];
    }
    
    if (level2) {
        [self drawMediumLevelIndicatorInRect:rect colorize:YES];
    } else {
        [self drawMediumLevelIndicatorInRect:rect colorize:NO];
    }
    
    if (level1) {
        [self drawLowLevelIndicatorInRect:rect colorize:YES];
    } else {
        [self drawLowLevelIndicatorInRect:rect colorize:NO];
    }
    
    
    
}

#pragma mark - Public methods

-(void)redrawAnimated:(BOOL)animated newStrengthLevel:(PSSPasswordStrengthLevel)strengthLevel{
    
    NSTimeInterval duration;
    if (animated) {
        duration = 0.1;
    } else {
        duration = 0.;
    }

    [UIView animateWithDuration:duration animations:^{
        [self setAlpha:0.];
    } completion:^(BOOL finished) {
        
        self.strengthLevel = strengthLevel;
        [self setNeedsDisplay];
        
        [UIView animateWithDuration:duration animations:^{
            [self setAlpha:1.0];
        }];
        
    }];
    
    [UIView animateKeyframesWithDuration:0.1 delay:0.1 options:UIViewKeyframeAnimationOptionAutoreverse animations:^{
        [self setAlpha:0.0];
    } completion:^(BOOL finished) {
        [self setNeedsDisplay];
    }];
}

-(void)updateGaugeForLevel:(PSSPasswordStrengthLevel)strengthLevel{
    [self redrawAnimated:YES newStrengthLevel:strengthLevel];
}

-(void)updateGaugeForString:(NSString *)passwordString{
    
    PSSPasswordStrengthLevel newStrengthLevel = [self strengthLevelForString:passwordString];
    
    if (self.strengthLevel != newStrengthLevel) {
        [self redrawAnimated:YES newStrengthLevel:newStrengthLevel];
    }
    
}

@end

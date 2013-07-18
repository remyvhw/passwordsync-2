//
//  PSSPINpasscodeButtonView.m
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-07-04.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import "PSSPINpasscodeButtonView.h"

@implementation PSSPINpasscodeButtonView
@synthesize passcodeNumber = _passcodeNumber;


-(void)setPasscodeNumber:(PSSPINpasscodeButtonNumber)passcodeNumber{
    
    
    
    
    
    _passcodeNumber = passcodeNumber;
    
}


-(PSSPINpasscodeButtonNumber)passcodeNumber{
    return _passcodeNumber;
}


-(NSString*)lettersForCurrentNumber{
    
    switch (self.passcodeNumber) {
        case PSSPINpasscodeButtonNumberZero:
            return @"";
        case PSSPINpasscodeButtonNumberOne:
            return @"";
        case PSSPINpasscodeButtonNumberTwo:
            return @"ABC";
        case PSSPINpasscodeButtonNumberThree:
            return @"DEF";
        case PSSPINpasscodeButtonNumberFour:
            return @"GHI";
        case PSSPINpasscodeButtonNumberFive:
            return @"JKL";
        case PSSPINpasscodeButtonNumberSix:
            return @"MNO";
        case PSSPINpasscodeButtonNumberSeven:
            return @"PQRS";
        case PSSPINpasscodeButtonNumberEight:
            return @"TUV";
        case PSSPINpasscodeButtonNumberNine:
            return @"WXYZ";
    }
    
    return @"";

}

-(NSString*)numberForCurrentPasscodeNumber{
    
    switch (self.passcodeNumber) {
        case PSSPINpasscodeButtonNumberZero:
            return @"0";
        case PSSPINpasscodeButtonNumberOne:
            return @"1";
        case PSSPINpasscodeButtonNumberTwo:
            return @"2";
        case PSSPINpasscodeButtonNumberThree:
            return @"3";
        case PSSPINpasscodeButtonNumberFour:
            return @"4";
        case PSSPINpasscodeButtonNumberFive:
            return @"5";
        case PSSPINpasscodeButtonNumberSix:
            return @"6";
        case PSSPINpasscodeButtonNumberSeven:
            return @"7";
        case PSSPINpasscodeButtonNumberEight:
            return @"8";
        case PSSPINpasscodeButtonNumberNine:
            return @"9";
    }
    
    return @"";
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    //// General Declarations
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //// Color Declarations
    UIColor* strokeColor = [UIColor colorWithRed: 0 green: 0 blue: 0 alpha: 1];
    UIColor* bottomTint;
    if (self.highlighted) {
        bottomTint = self.window.tintColor;
    } else {
        bottomTint = [UIColor colorWithRed: 0.892 green: 0.892 blue: 0.892 alpha: 0];
    }
    CGFloat bottomTintRGBA[4];
    [bottomTint getRed: &bottomTintRGBA[0] green: &bottomTintRGBA[1] blue: &bottomTintRGBA[2] alpha: &bottomTintRGBA[3]];
    
    UIColor* topTint = [UIColor colorWithRed: (bottomTintRGBA[0] * 0.6 + 0.4) green: (bottomTintRGBA[1] * 0.6 + 0.4) blue: (bottomTintRGBA[2] * 0.6 + 0.4) alpha: (bottomTintRGBA[3] * 0.6 + 0.4)];
    UIColor* black = [UIColor colorWithRed: 0 green: 0 blue: 0 alpha: 1];
    
    //// Gradient Declarations
    NSArray* gradientColors = [NSArray arrayWithObjects:
                               (id)topTint.CGColor,
                               (id)bottomTint.CGColor, nil];
    CGFloat gradientLocations[] = {0, 1};
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)gradientColors, gradientLocations);
    
    //// Abstracted Attributes
    NSString* numberContent = [self numberForCurrentPasscodeNumber];
    NSString* bottomLettersContent = [self lettersForCurrentNumber];
    
    
    //// Oval Drawing
    UIBezierPath* ovalPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(1, 1, rect.size.width-2, rect.size.height-2)];
    CGContextSaveGState(context);
    [ovalPath addClip];
    CGContextDrawLinearGradient(context, gradient, CGPointMake(rect.size.width/2, 0), CGPointMake(rect.size.height/2, rect.size.height), 0);
    CGContextRestoreGState(context);
    [strokeColor setStroke];
    ovalPath.lineWidth = 1;
    [ovalPath stroke];
    
    
    //// number Drawing
    CGRect numberRect = CGRectMake(0, 10, rect.size.width, 41);
    [black setFill];
    NSMutableParagraphStyle* numberStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    [numberStyle setAlignment: NSTextAlignmentCenter];
    
    NSDictionary* numberFontAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                          [UIFont fontWithName: @"HelveticaNeue-UltraLight" size: 28], NSFontAttributeName,
                                          black, NSForegroundColorAttributeName,
                                          numberStyle, NSParagraphStyleAttributeName, nil];
    
    [numberContent drawInRect: CGRectInset(numberRect, 0, 2) withAttributes: numberFontAttributes];
    
    
    //// bottomLetters Drawing
    CGRect bottomLettersRect = CGRectMake(0, 43, rect.size.width, 19);
    
    NSMutableParagraphStyle* bottomLettersStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    [bottomLettersStyle setAlignment: NSTextAlignmentCenter];
    
    NSDictionary* bottomLettersFontAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                                 [UIFont fontWithName: @"HelveticaNeue-UltraLight" size: 10], NSFontAttributeName,
                                                 black, NSForegroundColorAttributeName,
                                                 bottomLettersStyle, NSParagraphStyleAttributeName, nil];
    
    [bottomLettersContent drawInRect: CGRectInset(bottomLettersRect, 0, 1) withAttributes: bottomLettersFontAttributes];

    
    
    //// Cleanup
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);
    

}

-(void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    [self setNeedsDisplay];
}

@end

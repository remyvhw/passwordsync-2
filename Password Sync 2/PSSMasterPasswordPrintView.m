//
//  PSSMasterPasswordPrintView.m
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-07-01.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import "PSSMasterPasswordPrintView.h"

@interface PSSMasterPasswordPrintView ()

@property (strong) NSString * masterPassword;

@end

@implementation PSSMasterPasswordPrintView


-(id)initWithFrame:(CGRect)frame password:(NSString *)password{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        self.masterPassword = password;
        
        
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame password:@"correctHorseBatteryStaple384728Xu3hhehbfhebfu7"];
}



// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    
    //// General Declarations
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //// Color Declarations
    UIColor* fillColor = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 1];
    UIColor* alphaColor = [fillColor colorWithAlphaComponent: 0.9];
    UIColor* strokeColor = [UIColor colorWithRed: 0 green: 0 blue: 0 alpha: 1];
    
    //// Image Declarations
    UIImage* scramblobs = [UIImage imageNamed: @"scramblobs"];
    UIColor* scramblobsPattern = [UIColor colorWithPatternImage: scramblobs];
    
    //// Abstracted Attributes
    NSString* text2Content = @"Step 1 -- ↓ -- Fold down, password face inside";
    NSString* text3Content = @"Step 2 -- ↑ -- Fold up, cover password back side";
    NSString* fakeText1Content = @"Dolor Ligula Justo";
    NSString* fakeText2Content = @"MattisPellentesqueTristi";
    NSString* fakeText3Content = @"A7ZqKKMffyJP5D42";
    NSString* fakeText4Content = @"DYgBw9M5FU64VEXL";
    NSString* fakeText5Content = @"uzQEvPtHSXaW7Z2d";
    NSString* fakeText6Content = @"VehiculaInceptosTristique";
    NSString* fakeText7Content = @"CommodoVulputateParturient";
    NSString* fakeText8Content = @"voyage fierce swimming";
    NSString* fakeText9Content = @"somehow couple be large";
    NSString* fakeText10Content = @"into join swung";
    NSString* explanationTextContent = @"Make sure you fold 4 times this sheet of paper and staple it in a manner that will prevent access to it's content. Keep it in a personal safe or in a very secure place.";

    
    
    CGFloat width = rect.size.width;
    CGFloat height = rect.size.height;
    
    //// Rectangle Drawing
    UIBezierPath* rectanglePath = [UIBezierPath bezierPathWithRect: CGRectMake(0, 0, width, height)];
    CGContextSaveGState(context);
    CGContextSetPatternPhase(context, CGSizeMake(0, 0));
    [scramblobsPattern setFill];
    [rectanglePath fill];
    CGContextRestoreGState(context);
    [strokeColor setStroke];
    rectanglePath.lineWidth = 1;
    [rectanglePath stroke];
    
    
    NSMutableParagraphStyle* generalTextStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    [generalTextStyle setAlignment: NSTextAlignmentCenter];
    
    NSDictionary* generalTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                         [UIFont fontWithName: @"Courier-Bold" size: 11.5], NSFontAttributeName,
                                         strokeColor, NSForegroundColorAttributeName,
                                         generalTextStyle, NSParagraphStyleAttributeName, nil];
    
    
    
    //// fakeText1 Drawing
    CGRect fakeText1Rect = CGRectMake(26, 70, 217, 20);
    [strokeColor setFill];
    [fakeText1Content drawInRect:fakeText1Rect withAttributes:generalTextAttributes];
    
    
    //// fakeText2 Drawing
    CGRect fakeText2Rect = CGRectMake(0, 104, 217, 20);
    [strokeColor setFill];

    [fakeText2Content drawInRect: fakeText2Rect withAttributes:generalTextAttributes];    
    
    //// fakeText3 Drawing
    CGRect fakeText3Rect = CGRectMake(199, 124, 217, 20);
    [strokeColor setFill];
    [fakeText3Content drawInRect: fakeText3Rect withAttributes:generalTextAttributes];    
    
    //// fakeText4 Drawing
    CGRect fakeText4Rect = CGRectMake(408, 114, 217, 20);
    [strokeColor setFill];
    [fakeText4Content drawInRect: fakeText4Rect withAttributes:generalTextAttributes];    
    
    //// fakeText5 Drawing
    CGRect fakeText5Rect = CGRectMake(395, 144, 217, 20);
    [strokeColor setFill];
    [fakeText5Content drawInRect: fakeText5Rect withAttributes:generalTextAttributes];    
    
    //// fakeText6 Drawing
    CGRect fakeText6Rect = CGRectMake(0, 189, 217, 20);
    [strokeColor setFill];
    [fakeText6Content drawInRect: fakeText6Rect withAttributes:generalTextAttributes];    
    
    //// fakeText7 Drawing
    CGRect fakeText7Rect = CGRectMake(-5, 134, 217, 20);
    [strokeColor setFill];
    [fakeText7Content drawInRect: fakeText7Rect withAttributes:generalTextAttributes];    
    
    //// fakeText8 Drawing
    CGRect fakeText8Rect = CGRectMake(408, 134, 199, 20);
    [strokeColor setFill];
    [fakeText8Content drawInRect: fakeText8Rect withAttributes:generalTextAttributes];    
    
    //// fakeText9 Drawing
    CGRect fakeText9Rect = CGRectMake(-5, 164, 217, 20);
    [strokeColor setFill];
    [fakeText9Content drawInRect: fakeText9Rect withAttributes:generalTextAttributes];
    
    
    //// fakeText10 Drawing
    CGRect fakeText10Rect = CGRectMake(403, 60, 217, 20);
    [strokeColor setFill];
    [fakeText10Content drawInRect: fakeText10Rect withAttributes:generalTextAttributes];
    
    
    
    //// Rectangle 2 Drawing
    UIBezierPath* rectangle2Path = [UIBezierPath bezierPathWithRect: CGRectMake(width/3-5, 0, 10, height)];
    [fillColor setFill];
    [rectangle2Path fill];
    
    
    //// Rectangle 3 Drawing
    UIBezierPath* rectangle3Path = [UIBezierPath bezierPathWithRect: CGRectMake((width/3)*2+5, 0, 10, height)];
    [fillColor setFill];
    [rectangle3Path fill];
    
    
    //// Rectangle 4 Drawing
    UIBezierPath* rectangle4Path = [UIBezierPath bezierPathWithRect: CGRectMake(0, 0, 10, height)];
    [fillColor setFill];
    [rectangle4Path fill];
    
    
    //// Rectangle 5 Drawing
    UIBezierPath* rectangle5Path = [UIBezierPath bezierPathWithRect: CGRectMake(width-10, 0, 10, height)];
    [fillColor setFill];
    [rectangle5Path fill];
    
    
    //// Rectangle 6 Drawing
    UIBezierPath* rectangle6Path = [UIBezierPath bezierPathWithRect: CGRectMake(0, 0, width, 10)];
    [fillColor setFill];
    [rectangle6Path fill];
    
    
    //// Rectangle 7 Drawing
    UIBezierPath* rectangle7Path = [UIBezierPath bezierPathWithRect: CGRectMake(0, height/3-5, width, 10)];
    [fillColor setFill];
    [rectangle7Path fill];
    
    
    //// Rectangle 8 Drawing
    UIBezierPath* rectangle8Path = [UIBezierPath bezierPathWithRect: CGRectMake(0, (height/3)*2-5, width, 10)];
    [fillColor setFill];
    [rectangle8Path fill];
    
    
    //// Rectangle 10 Drawing
    UIBezierPath* rectangle10Path = [UIBezierPath bezierPathWithRect: CGRectMake(0, height-10, width, 10)];
    [fillColor setFill];
    [rectangle10Path fill];
    
    //// Rectangle 9 Drawing
    UIBezierPath* rectangle9Path = [UIBezierPath bezierPathWithRect: CGRectMake(width/3-5, 10, width/3+10, height/3-5)];
    [alphaColor setFill];
    [rectangle9Path fill];
    
    //// Text 2 Drawing
    CGRect text2Rect = CGRectMake(0, (height/3)-5, width, 16);
    [strokeColor setFill];
    [text2Content drawInRect: text2Rect withAttributes:generalTextAttributes];
    
    
    //// Text 3 Drawing
    CGRect text3Rect = CGRectMake(0, (height/3)*2-5, width, 16);
    [strokeColor setFill];
    [text3Content drawInRect: text3Rect withAttributes:generalTextAttributes];

    //// Password Drawing
    
    
    
    
    CGRect passwordRect = CGRectMake(rect.size.width/2-(rect.size.width/6)+10, 30, rect.size.width/3-10, rect.size.height/6-30);
    [strokeColor setFill];
    NSMutableParagraphStyle* textStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    [textStyle setAlignment: NSTextAlignmentCenter];
    
    NSDictionary *attr = @{NSParagraphStyleAttributeName:textStyle, NSFontAttributeName:[UIFont fontWithName: @"Courier" size: 11.5], NSForegroundColorAttributeName:[UIColor lightGrayColor]};
    
    [self.masterPassword drawInRect:passwordRect withAttributes:attr];
   
    
    //// explanationText Drawing
    CGRect explanationTextRect = CGRectMake(rect.size.width/2-(rect.size.width/6)+10, 30+passwordRect.size.height+10, rect.size.width/3-10, rect.size.height/6-30);
    
    NSMutableParagraphStyle* explanationTextStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    [explanationTextStyle setAlignment: NSTextAlignmentCenter];
    
    NSDictionary* explanationTextFontAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                                   [UIFont fontWithName: @"Courier" size: 10.5], NSFontAttributeName,
                                                   strokeColor, NSForegroundColorAttributeName,
                                                   explanationTextStyle, NSParagraphStyleAttributeName, nil];
    
    [explanationTextContent drawInRect: explanationTextRect withAttributes: explanationTextFontAttributes];

    
}


@end

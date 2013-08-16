//
//  UIColor+PSSDictionaryCoding.m
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-08-15.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import "UIColor+PSSDictionaryCoding.h"

typedef enum {
    PSSColorDictionaryKeyRed,
    PSSColorDictionaryKeyBlue,
    PSSColorDictionaryKeyGreen,
    PSSColorDictionaryKeyAlpha
} PSSColorDictionaryKey;

@implementation UIColor (PSSDictionaryCoding)


+(NSDictionary*)dictionaryWithColor:(UIColor *)color{
    
    const CGFloat* components = CGColorGetComponents(color.CGColor);
    
    
    NSDictionary * colorDictionary = @{
                                       @(PSSColorDictionaryKeyRed) : @(components[0]),
                                       @(PSSColorDictionaryKeyGreen) : @(components[1]),
                                       @(PSSColorDictionaryKeyBlue) : @(components[2]),
                                       @(PSSColorDictionaryKeyAlpha) : @(components[3]),
                                       };
    
    
    return colorDictionary;
}

+(UIColor*)colorWithDictionary:(NSDictionary *)dictionary{
    
    float red = [[dictionary objectForKey:@(PSSColorDictionaryKeyRed)] floatValue];
    float green = [[dictionary objectForKey:@(PSSColorDictionaryKeyGreen)] floatValue];
    float blue = [[dictionary objectForKey:@(PSSColorDictionaryKeyBlue)] floatValue];
    float alpha = [[dictionary objectForKey:@(PSSColorDictionaryKeyAlpha)] floatValue];

    
    UIColor * colorFromDictionary = [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
    
    return colorFromDictionary;
}


+(UIImage*)imageWithColor:(UIColor *)color{
    CGRect rect = CGRectMake(0.0f, 0.0f, 40.0f, 40.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}


+(UIImage*)imageWithColorDictionary:(NSDictionary *)dictionary{
    
    UIColor * colorFromDict = [UIColor colorWithDictionary:dictionary];
    return [UIColor imageWithColor:colorFromDict];
}

@end

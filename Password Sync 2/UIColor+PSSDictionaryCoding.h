//
//  UIColor+PSSDictionaryCoding.h
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-08-15.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (PSSDictionaryCoding)

+(NSDictionary*)dictionaryWithColor:(UIColor*)color;
+(UIColor*)colorWithDictionary:(NSDictionary*)dictionary;
+(UIImage*)imageWithColor:(UIColor*)color;
+(UIImage*)imageWithColorDictionary:(NSDictionary*)dictionary;
+(UIColor *)readableForegroundColorForColor:(UIColor*)color;

@end

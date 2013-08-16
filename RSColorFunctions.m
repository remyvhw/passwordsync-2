//
//  RSColorFunctions.m
//  RSColorPicker
//
//  Created by Ryan Sullivan on 3/12/13.
//  Copyright (c) 2013 Freelance Web Developer. All rights reserved.
//

#import "RSColorFunctions.h"

BMPixel RSPixelFromHSV(CGFloat H, CGFloat S, CGFloat V)
{
	UIColor *color = [UIColor colorWithHue:H saturation:S brightness:V alpha:1];
	CGFloat r, g, b;
	[color getRed:&r green:&g blue:&b alpha:NULL];
	return BMPixelMake(r, g, b, 1.0);
}

void RSHSVFromPixel(BMPixel pixel, CGFloat *h, CGFloat *s, CGFloat *v)
{
	UIColor *color = [UIColor colorWithRed:pixel.red green:pixel.green blue:pixel.blue alpha:1];
	[color getHue:h saturation:s brightness:v alpha:NULL];
}

void RSGetComponentsForColor(float components[4], UIColor *color) {
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char resultingPixel[4];
    CGContextRef context = CGBitmapContextCreate(&resultingPixel, 1, 1, 8, 4, rgbColorSpace, kCGImageAlphaPremultipliedLast);
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, CGRectMake(0, 0, 1, 1));
    CGContextRelease(context);
    CGColorSpaceRelease(rgbColorSpace);
    
    for (int component = 0; component < 4; component++) {
        components[component] = resultingPixel[component] / 255.0f;
    }
}

CGSize RSCGSizeWithScale(CGSize size, CGFloat scale) {
    return CGSizeMake(size.width * scale, size.height * scale);
}
CGPoint RSCGPointWithScale(CGPoint point, CGFloat scale) {
    return CGPointMake(point.x * scale, point.y * scale);
}
UIImage* RSUIImageWithScale(UIImage *img, CGFloat scale) {
    return [UIImage imageWithCGImage:img.CGImage scale:scale orientation:UIImageOrientationUp];
}

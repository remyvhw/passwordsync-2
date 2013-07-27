//
//  PSSThumbnailMaker.m
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-07-26.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import "PSSThumbnailMaker.h"
@import ImageIO;

@implementation PSSThumbnailMaker


//+(UIImage*)thumbnailImageWith

+(UIImage*)thumbnailImageFromImageAtURL:(NSURL *)imgURL maxSize:(double)maxSize{
    CGImageSourceRef src = CGImageSourceCreateWithURL((__bridge CFURLRef)imgURL, NULL);
    
    
    NSDictionary *thumbnailOptions = [NSDictionary dictionaryWithObjectsAndKeys:(id)kCFBooleanTrue, kCGImageSourceCreateThumbnailWithTransform,
                                      kCFBooleanTrue, kCGImageSourceCreateThumbnailFromImageAlways,
                                      [NSNumber numberWithFloat:maxSize], kCGImageSourceThumbnailMaxPixelSize,
                                      nil];
    CGImageRef thumbnail = CGImageSourceCreateThumbnailAtIndex(src, 0, (__bridge CFDictionaryRef)thumbnailOptions);
    

    CFRelease(src);
    UIImage* img = [[UIImage alloc] initWithCGImage:thumbnail];
    CGImageRelease(thumbnail);

    
    return img;
}


+(NSData*)thumbnailPNGImageDataFromImageAtURL:(NSURL *)imgURL maxSize:(double)maxSize{
    
    UIImage * thumbnail = [PSSThumbnailMaker thumbnailImageFromImageAtURL:imgURL maxSize:maxSize];
    
    if (!thumbnail) {
        return nil;
    }
    
    NSData * pngRepresentation = UIImagePNGRepresentation(thumbnail);
    
    
    return pngRepresentation;
}

+(UIImage*)thumbnailImageFromImage:(UIImage *)image maxSize:(double)maxSize{
    return nil;
}

@end

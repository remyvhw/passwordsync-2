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



+(UIImage*)thumbnailImageFromImageAtURL:(NSURL *)imgURL maxSize:(double)maxSize{
    NSLog(@"%@", [imgURL description]);
    
    if ([UIImage imageWithData:[NSData dataWithContentsOfURL:imgURL]] || [[imgURL pathExtension] isEqualToString:@"pdf"]) {
        // It is indeed an image
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
        
    } else {
        // It is NOT an image or a PDF.
        NSString *placeholderPath = [[NSBundle mainBundle] pathForResource:@"DocumentPlaceholder" ofType:@"pdf"];
        
        return [PSSThumbnailMaker thumbnailImageFromImageAtURL:[NSURL fileURLWithPath:placeholderPath] maxSize:maxSize];
        
    }
    
    

    
    return nil;
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


+(NSData*)createPDFfromImage:(UIImage*)image
{
    
    UIImageView * aView = [[UIImageView alloc] initWithImage:image];
    
    // Creates a mutable data object for updating with binary data, like a byte array
    NSMutableData *pdfData = [NSMutableData data];
    
    // Points the pdf converter to the mutable data object and to the UIView to be converted
    UIGraphicsBeginPDFContextToData(pdfData, aView.bounds, nil);
    UIGraphicsBeginPDFPage();
    
    // draws rect to the view and thus this is captured by UIGraphicsBeginPDFContextToData
    [aView.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    // remove PDF rendering context
    UIGraphicsEndPDFContext();
    
    return (NSData*)pdfData;
}

@end

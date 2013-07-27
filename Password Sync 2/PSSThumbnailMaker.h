//
//  PSSThumbnailMaker.h
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-07-26.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import <Foundation/Foundation.h>

#define PSSThumbnailMakerSizeTableView 80.;
#define PSSThumbnailMakerSizeStorable 450.;

@interface PSSThumbnailMaker : NSObject


+(UIImage*)thumbnailImageFromImageAtURL:(NSURL*)url maxSize:(double)maxSize;
+(NSData*)thumbnailPNGImageDataFromImageAtURL:(NSURL *)url maxSize:(double)maxSize;

@end

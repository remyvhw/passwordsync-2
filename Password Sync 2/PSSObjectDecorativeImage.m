//
//  PSSObjectDecorativeImage.m
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-07-27.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import "PSSObjectDecorativeImage.h"
#import "PSSBaseGenericObject.h"
#import "PSSNoteBaseObject.h"
#import "PSSObjectAttachment.h"

#import "UIImage+ImageEffects.h"

@implementation PSSObjectDecorativeImage

@dynamic data;
@dynamic timestamp;
@dynamic viewportIdentifier;
@dynamic attachment;
@dynamic encryptedObject;
@dynamic noteBaseObject;

@synthesize imageNormal = _imageNormal;
@synthesize imageLightEffect = _imageLightEffect;


-(UIImage*)imageNormal{
    
    if (_imageNormal) {
        return _imageNormal;
    }
    
    UIImage * normalImage = [UIImage imageWithData:self.data];
    _imageNormal = normalImage;
    return _imageNormal;
}


-(UIImage*)imageLightEffect{
    
    if (_imageLightEffect) {
        return _imageLightEffect;
    }
    
    
    UIImage * blurredImage = [self.imageNormal applyLightEffect];
    _imageLightEffect = blurredImage;
    return _imageLightEffect;
}


@end

//
//  PSSVersionGenericCollectionViewCell.m
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-08-06.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import "PSSVersionGenericCollectionViewCell.h"

@interface PSSVersionGenericCollectionViewCell ()



@end

@implementation PSSVersionGenericCollectionViewCell

@synthesize currentVersion = _currentVersion;

-(BOOL)currentVersion{
    return _currentVersion;
}

-(void)setCurrentVersion:(BOOL)currentVersion{
    
    
    if (currentVersion == YES) {
        // We need to hide the info button
        [self.infoButton setHidden:YES];
        self.backgroundColor = self.window.tintColor;
    } else {
        [self.infoButton setHidden:NO];
    }
    
    
}

@end

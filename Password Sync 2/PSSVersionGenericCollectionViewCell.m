//
//  PSSVersionGenericCollectionViewCell.m
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-08-06.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import "PSSVersionGenericCollectionViewCell.h"
#import "PSSAppDelegate.h"

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
        self.backgroundColor = APP_DELEGATE.window.tintColor;
        self.dateLabel.textColor = [UIColor whiteColor];
        self.titleLabel.textColor = [UIColor whiteColor];
    } else {
        [self.infoButton setHidden:NO];
        self.backgroundColor = [UIColor whiteColor];
        self.dateLabel.textColor = [UIColor blackColor];
        self.titleLabel.textColor = [UIColor blackColor];
    }
    
    
}

@end

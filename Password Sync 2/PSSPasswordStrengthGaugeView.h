//
//  PSSPasswordStrengthGaugeView.h
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-07-12.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    PSSPasswordStrengthLevelNone,
    PSSPasswordStrengthLevelLow,
    PSSPasswordStrengthLevelMedium,
    PSSPasswordStrengthLevelHigh,
    PSSPasswordStrengthLevelHighest
} PSSPasswordStrengthLevel;

@interface PSSPasswordStrengthGaugeView : UIView

@property PSSPasswordStrengthLevel strengthLevel;

-(void)updateGaugeForString:(NSString*)passwordString;
-(void)updateGaugeForLevel:(PSSPasswordStrengthLevel)strengthLevel;

@end

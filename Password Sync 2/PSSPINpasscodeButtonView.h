//
//  PSSPINpasscodeButtonView.h
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-07-04.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    PSSPINpasscodeButtonNumberZero,
    PSSPINpasscodeButtonNumberOne,
    PSSPINpasscodeButtonNumberTwo,
    PSSPINpasscodeButtonNumberThree,
    PSSPINpasscodeButtonNumberFour,
    PSSPINpasscodeButtonNumberFive,
    PSSPINpasscodeButtonNumberSix,
    PSSPINpasscodeButtonNumberSeven,
    PSSPINpasscodeButtonNumberEight,
    PSSPINpasscodeButtonNumberNine
} PSSPINpasscodeButtonNumber;

@interface PSSPINpasscodeButtonView : UIButton

@property PSSPINpasscodeButtonNumber passcodeNumber;

-(NSString*)numberForCurrentPasscodeNumber;

@end

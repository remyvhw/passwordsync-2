//
//  PSSWelcomeScreenPINPasscodeSetterViewController.h
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-07-04.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    PSSPINpasscodeStatusUndefined,
    PSSPINpasscodeStatusOne,
    PSSPINpasscodeStatusTwo,
    PSSPINpasscodeStatusThree,
    PSSPINpasscodeStatusFour,
    PSSPINpasscodeStatusValidateOne,
    PSSPINpasscodeStatusValidateTwo,
    PSSPINpasscodeStatusValidateThree,
    PSSPINpasscodeStatusValidateFour,
    PSSPINpasscodeStatusValidate,
    PSSPINpasscodeStatusInvalid,
} PSSPINpasscodeStatus;

@interface PSSWelcomeScreenPINPasscodeSetterViewController : UIViewController

@end

//
//  PSSWelcomeScreenGesturePasscodeSetterViewController.h
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-07-03.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SPLockScreen.h"

typedef enum {
    PSSGesturePasscodeStatusUndefined,
    PSSGesturePasscodeStatusInvalid,
    PSSGesturePasscodeStatusNotMatching,
    PSSGesturePasscodeStatusValid,
} PSSGesturePasscodeStatus;


@interface PSSWelcomeScreenGesturePasscodeSetterViewController : UIViewController <LockScreenDelegate>

@end

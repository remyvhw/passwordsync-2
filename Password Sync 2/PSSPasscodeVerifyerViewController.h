//
//  PSSPasscodeVerifyerViewController.h
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-07-03.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef enum {
    PSSPasscodeTypeNone,
    PSSPasscodeTypeGestureBased,
    PSSPasscodeTypeNIPcode,
    PSSPasscodeTypeComplexPassword,
    PSSPasscodeTypeMasterPassword
} PSSPasscodeType;


@interface PSSPasscodeVerifyerViewController : NSObject

-(NSInteger)countOfPasscodeAttempts;

-(void)savePasscode:(NSString*)passcode withType:(PSSPasscodeType)passcodeType;
/// @description This method will save the passcode in the keychain as a digested value.


-(BOOL)verifyPasscode:(NSString*)passcode;
/// @description This method will verify the passcode in the keychain.


@end

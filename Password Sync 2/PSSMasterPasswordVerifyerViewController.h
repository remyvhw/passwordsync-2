//
//  PSSMasterPasswordVerifyerViewController.h
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-07-01.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PSSMasterPasswordVerifyerViewController : UIViewController

-(void)saveMasterPassword:(NSString*)masterPassword hint:(NSString*)hint;
/// @description This method will save the master password and a hint in the keychain and generate a password verification hash that will be propagated via iCloud.

-(BOOL)verifyMasterPasswordValidity:(NSString*)providedMasterPassword;
/// @description This method will verify if the provided master password is valid. If no master password is saved in keychain, a master password hash will be used and a copy of the provided master password will be saved in keychain for further verification.

@end

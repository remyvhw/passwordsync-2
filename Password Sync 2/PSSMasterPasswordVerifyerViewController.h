//
//  PSSMasterPasswordVerifyerViewController.h
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-07-01.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PSSMasterPasswordVerifyerViewController : UIViewController

/// This method will save the master password and a hint in the keychain and generate a password verification hash that will be propagated via iCloud.
-(void)saveNewMasterPassword:(NSString*)masterPassword hint:(NSString*)hint;

/// This method will generate a master password hash just as the one that calling the saveMasterPassword:hint: method would save in the keychain.
-(NSString*)generateMasterPasswordHash:(NSString*)masterPassword hint:(NSString*)hint;

/// This method will verify if the provided master password is valid. If no master password is saved in keychain, a master password hash will be used and a copy of the provided master password will be saved in keychain for further verification.
-(BOOL)verifyMasterPasswordValidity:(NSString*)providedMasterPassword;


/// Make sure the password stored in the keychain of this device is the actual last password used across other devices.
-(BOOL)isLocalMasterPasswordCurrent;
    


@end

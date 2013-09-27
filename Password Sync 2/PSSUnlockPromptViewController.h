//
//  PSSUnlockPromptViewController.h
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-07-15.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSSPasscodeVerifyerViewController.h"
typedef void(^SuccessfulUnlockBlock)(void);
typedef void(^SuccessfulMasterPasswordUnlockBlock)(void);
typedef void(^CancelationBlock)(void);

@interface PSSUnlockPromptViewController : UINavigationController
@property (nonatomic, strong) SuccessfulUnlockBlock unlockBlock;
@property (nonatomic, strong) SuccessfulMasterPasswordUnlockBlock masterPasswordUnlockBlock;
@property (nonatomic, strong) CancelationBlock cancelationBlock;


-(PSSUnlockPromptViewController*)promptForPasscodeBlockingView:(BOOL)blockingView completion:(void (^)(void))completion cancelation:(void (^)(void))cancelation;

-(PSSUnlockPromptViewController*)promptForMasterPasswordBlockingView:(BOOL)blockingView completion:(void (^)(void))completion cancelation:(void (^)(void))cancelation;

-(void)skipPasscodeVerification;
-(void)userDidSuccessfullyUnlockWithPasscode;
-(void)userDidSuccesfullyUnlockedWithMasterPassword;


-(void)userDidCancelUnlockWithMasterPassword;

@end

//
//  PSSWelcomeNewUserSetMasterPasswordViewController.h
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-06-29.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PSSWelcomeNewUserSetMasterPasswordViewController : UIViewController <UIAlertViewDelegate>
- (IBAction)saveButtonAction:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *masterPasswordTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordHintTextField;

@end

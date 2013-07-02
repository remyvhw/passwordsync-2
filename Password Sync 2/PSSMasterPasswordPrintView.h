//
//  PSSMasterPasswordPrintView.h
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-07-01.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PSSMasterPasswordPrintView : UIView

@property (strong) UILabel * masterPasswordTextLabel;

-(id)initWithFrame:(CGRect)frame password:(NSString*)password;

@end

//
//  PSSTagColorPickerViewController.h
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-08-15.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RSColorPickerView.h"
#import "RSBrightnessSlider.h"

@protocol PSSTagColorPickerViewControllerDelegate;

@interface PSSTagColorPickerViewController : UIViewController <RSColorPickerViewDelegate>

@property (strong, nonatomic) UIColor * selectedColor;
@property (weak, nonatomic) id<PSSTagColorPickerViewControllerDelegate> pickerDelegate;

-(IBAction)pressedColorPresetButton:(UIButton*)sender;

@end

@protocol PSSTagColorPickerViewControllerDelegate <NSObject>

-(void)pickerViewController:(PSSTagColorPickerViewController*)viewController didFinishSelectingColor:(UIColor*)color;

@end

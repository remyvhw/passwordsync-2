//
//  PSSLocationChoicePopoverViewController.h
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-08-23.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

@import UIKit;
@import CoreLocation;

@interface PSSLocationChoicePopoverViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic, strong) void (^completionBlock)(CLLocation * location, CLPlacemark * Placemark);
@property (nonatomic, strong) NSArray * choiceOfPlacemarks;
@property (nonatomic, strong) NSArray * choiceOfMapItems;

@end

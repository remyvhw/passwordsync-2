//
//  PSSTagColorPickerViewController.m
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-08-15.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import "PSSTagColorPickerViewController.h"

@interface PSSTagColorPickerViewController ()
@property (weak, nonatomic) IBOutlet RSColorPickerView *colorWheelView;
@property (weak, nonatomic) IBOutlet RSBrightnessSlider *darknessSlider;
@property (weak, nonatomic) IBOutlet UIView *finalColorView;

@end

@implementation PSSTagColorPickerViewController

-(void)pressedColorPresetButton:(UIButton *)sender{
    [self.colorWheelView setSelectionColor:sender.backgroundColor];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if (self.pickerDelegate) {
        [self.pickerDelegate pickerViewController:self didFinishSelectingColor:self.selectedColor];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.colorWheelView.delegate = self;
    
    if (self.selectedColor) {
        [self.colorWheelView setSelectionColor:self.selectedColor];
    }
    
}

-(void)viewDidAppear:(BOOL)animated{
    
    [self.colorWheelView setAlpha:0.0];
    [self.colorWheelView setHidden:NO];
    
    [UIView animateWithDuration:0.2 animations:^{
        [self.colorWheelView setAlpha:1.0];
    }];
    
    self.darknessSlider.colorPicker = self.colorWheelView;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - RSColorPickerView delegate methods

- (void)colorPickerDidChangeSelection:(RSColorPickerView *)cp
{
	self.selectedColor = [cp selectionColor];

    self.darknessSlider.value = [cp brightness];
    
    [UIView animateWithDuration:0.2 animations:^{
        self.finalColorView.layer.backgroundColor = [cp selectionColor].CGColor;
    }];
    
}



@end

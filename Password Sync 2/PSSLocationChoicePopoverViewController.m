//
//  PSSLocationChoicePopoverViewController.m
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-08-23.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import "PSSLocationChoicePopoverViewController.h"
#import <AddressBookUI/AddressBookUI.h>
#import "UIViewController+MJPopupViewController.h"

@interface PSSLocationChoicePopoverViewController ()
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;
- (IBAction)doneButtonSelected:(id)sender;

@end

@implementation PSSLocationChoicePopoverViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIPickerViewDataSource

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return self.choiceOfPlacemarks.count;
}

#pragma mark - UIPickerViewDelegate


-(NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    CLPlacemark *placemark = [self.choiceOfPlacemarks objectAtIndex:row];
    
    NSString * addressString = ABCreateStringWithAddressDictionary([placemark addressDictionary], NO);
    return [addressString stringByReplacingOccurrencesOfString:@"\n" withString:@", "];
}

- (IBAction)doneButtonSelected:(id)sender {
    
    
    CLPlacemark * selectedPlacemark = [self.choiceOfPlacemarks objectAtIndex:[self.pickerView selectedRowInComponent:0]];
    
    CLLocation * locationForPlacemark = [selectedPlacemark location];
    
    if (self.completionBlock) {
        self.completionBlock(locationForPlacemark, selectedPlacemark);
    }
    
    
    
}
@end

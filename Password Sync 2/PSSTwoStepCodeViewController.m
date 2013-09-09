//
//  PSSTwoStepCodeViewController.m
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-09-03.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import "PSSTwoStepCodeViewController.h"
#import "HOTPGenerator.h"
#import "TOTPGenerator.h"
#import "PSSBaseObjectVersion.h"
#import "PSSTwoStepEditorTableViewController.h"
#import "PSSPasswordVersion.h"
#import "OTPAuthURL.h"

typedef enum {
    PSSTwoStepTypeModeNone,
    PSSTwoStepTypeModeHOTP,
    PSSTwoStepTypeModeTOTP,
} PSSTwoStepTypeMode;

@interface PSSTwoStepCodeViewController ()
@property (weak, nonatomic) IBOutlet UILabel *digitsLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *remainingTimeIndicator;
@property (nonatomic, strong) NSDictionary * additionalData;
@property (nonatomic) PSSTwoStepTypeMode twoStepMode;
@property (nonatomic) OTPGenerator * generator;
@property (nonatomic, strong) NSTimer*secondsTimer;

@property (nonatomic, strong) UIPopoverController * editorPopover;

@end

@implementation PSSTwoStepCodeViewController

-(NSDictionary *)additionalDataWithExistingData:(NSDictionary*)existingData twoStepValues:(NSDictionary*)twoStepValues{
    
    NSMutableDictionary * additionalData = [[NSMutableDictionary alloc] initWithDictionary:existingData];
    
    // Remove any previous traces from the dictionary
    [additionalData removeObjectForKey:PSSTwoStepAlgorithmKey];
    [additionalData removeObjectForKey:PSSTwoStepCounterKey];
    [additionalData removeObjectForKey:PSSTwoStepDigitsKey];
    [additionalData removeObjectForKey:PSSTwoStepLabel];
    [additionalData removeObjectForKey:PSSTwoStepPeriodKey];
    [additionalData removeObjectForKey:PSSTwoStepSecretKey];
    [additionalData removeObjectForKey:PSSTwoStepTypeKey];
    
    
    if ([twoStepValues objectForKey:PSSTwoStepAlgorithmKey]) {
        [additionalData setObject:[twoStepValues objectForKey:PSSTwoStepAlgorithmKey] forKey:PSSTwoStepAlgorithmKey];
    }
    
    if ([twoStepValues objectForKey:PSSTwoStepCounterKey]) {
        [additionalData setObject:[twoStepValues objectForKey:PSSTwoStepCounterKey] forKey:PSSTwoStepCounterKey];
    }
    
    if ([twoStepValues objectForKey:PSSTwoStepDigitsKey]) {
        [additionalData setObject:[twoStepValues objectForKey:PSSTwoStepDigitsKey] forKey:PSSTwoStepDigitsKey];
    }
    
    if ([twoStepValues objectForKey:PSSTwoStepLabel]) {
        [additionalData setObject:[twoStepValues objectForKey:PSSTwoStepLabel] forKey:PSSTwoStepLabel];
    }
    
    if ([twoStepValues objectForKey:PSSTwoStepPeriodKey]) {
        [additionalData setObject:[twoStepValues objectForKey:PSSTwoStepPeriodKey] forKey:PSSTwoStepPeriodKey];
    }
    
    if ([twoStepValues objectForKey:PSSTwoStepSecretKey]) {
        [additionalData setObject:[twoStepValues objectForKey:PSSTwoStepSecretKey] forKey:PSSTwoStepSecretKey];
    }
    
    if ([twoStepValues objectForKey:PSSTwoStepTypeKey]) {
        [additionalData setObject:[twoStepValues objectForKey:PSSTwoStepTypeKey] forKey:PSSTwoStepTypeKey];
    }
    
    return additionalData;
}


-(void)refreshLabel:(id)sender{
    
    NSTimeInterval period;
    if (self.twoStepMode == PSSTwoStepTypeModeTOTP) {
        period = [(TOTPGenerator*)self.generator period];
    } else {
        period = [TOTPGenerator defaultPeriod];
    }
    
    NSTimeInterval seconds = [[NSDate date] timeIntervalSince1970];
    CGFloat mod =  fmod(seconds, period);
    CGFloat percent = mod / period;
    
    self.digitsLabel.text = self.generator.generateOTP;
    
    [self.remainingTimeIndicator setProgress:1-percent];
}

-(void)refreshTypeAndCounter{
    if ([self.additionalData objectForKey:PSSTwoStepTypeKey] && [[self.additionalData objectForKey:PSSTwoStepTypeKey] isEqualToString:@"hotp"]) {
        // We're in hotp mode
        self.twoStepMode = PSSTwoStepTypeModeHOTP;
        
    } else if ([self.additionalData objectForKey:PSSTwoStepTypeKey] && [[self.additionalData objectForKey:PSSTwoStepTypeKey] isEqualToString:@"totp"]) {
        // We're in totp mode
        self.twoStepMode = PSSTwoStepTypeModeTOTP;
        
    } else {
        // We're in None
        self.twoStepMode = PSSTwoStepTypeModeNone;
    }
    
    
    
    
    
    if (self.twoStepMode == PSSTwoStepTypeModeNone) {
        self.digitsLabel.text = @"00000";
        self.remainingTimeIndicator.progress = 0.0;
    } else if (self.twoStepMode == PSSTwoStepTypeModeHOTP) {
        // Counter based
        
        HOTPGenerator * counterGenerator = [[HOTPGenerator alloc] initWithSecret:[[self.additionalData objectForKey:PSSTwoStepSecretKey] dataUsingEncoding:NSUTF8StringEncoding] algorithm:[self.additionalData objectForKey:PSSTwoStepAlgorithmKey] digits:[[self.additionalData objectForKey:PSSTwoStepDigitsKey] unsignedIntegerValue] counter:[[self.additionalData objectForKey:PSSTwoStepCounterKey] unsignedIntegerValue]];
        
        self.generator = counterGenerator;
        
    } else if (self.twoStepMode == PSSTwoStepTypeModeTOTP) {
        // Timer based
        
        NSData * base32DecodedData = [OTPAuthURL base32Decode:[self.additionalData objectForKey:PSSTwoStepSecretKey]];
      
        TOTPGenerator * counterGenerator = [[TOTPGenerator alloc] initWithSecret:base32DecodedData algorithm:[self.additionalData objectForKey:PSSTwoStepAlgorithmKey] digits:[[self.additionalData objectForKey:PSSTwoStepDigitsKey] unsignedIntegerValue] period:[[self.additionalData objectForKey:PSSTwoStepPeriodKey] doubleValue]];
        
        self.generator = counterGenerator;
        
    }
    
    if (self.twoStepMode != PSSTwoStepTypeModeNone) {
        NSTimer* timer = [NSTimer timerWithTimeInterval:1.0f target:self selector:@selector(refreshLabel:) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
        self.secondsTimer = timer;
        [self refreshLabel:nil];
    }

}

-(void)editButtonPressed:(id)sender{
    
    if (self.editorPopover) {
        [self.editorPopover dismissPopoverAnimated:YES];
        self.editorPopover = nil;
        return;
    }
    
    PSSTwoStepEditorTableViewController * editorViewController = [[PSSTwoStepEditorTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    editorViewController.editorDelegate = self;
    
    if ([self.detailItem.currentVersion isMemberOfClass:[PSSPasswordVersion class]]) {
        editorViewController.username = [(PSSPasswordVersion*)self.detailItem.currentVersion decryptedUsername];
    }
    
    
    UINavigationController * navController = [[UINavigationController alloc] initWithRootViewController:editorViewController];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        
        
        
        UIPopoverController * popoverController = [[UIPopoverController alloc] initWithContentViewController:navController];
        
        self.editorPopover = popoverController;
        
        [popoverController presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        
        
    } else {
        [self.navigationController presentViewController:navController animated:YES completion:^{
            
        }];
    }
    
}

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
    
    UIBarButtonItem * editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editButtonPressed:)];
    self.navigationItem.rightBarButtonItem = editButton;
    
    // Load the two step data from detail item's JSON data
    
    NSData * jsonData = [(PSSBaseObjectVersion*)self.detailItem.currentVersion decryptedAdditionalJSONfields];
    
    if (jsonData) {
        NSDictionary * additionalDictionary = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:NULL];
        
        self.additionalData = additionalDictionary;
    }
    
    
    
    [self refreshTypeAndCounter];
    
    
    
    
}

-(void)viewWillDisappear:(BOOL)animated{
    [self.editorPopover dismissPopoverAnimated:NO];
    self.editorPopover = nil;
    [super viewWillDisappear:animated];
}

-(void)dealloc{
    [self.secondsTimer invalidate];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark PSSTwoStepEditorDelegate methods

-(void)twoStepEditor:(PSSTwoStepEditorTableViewController *)editor finishedWithValues:(NSDictionary *)values{
    // Take detail item's current values and recreate them
    
    if (self.editorPopover) {
        [self.editorPopover dismissPopoverAnimated:YES];
        self.editorPopover = nil;
    }
    
    NSDictionary * newAdditionalData = [self additionalDataWithExistingData:self.additionalData twoStepValues:values];
    
    self.additionalData = newAdditionalData;
    
    // Save the new data
    NSData * newJSONAdditionalData = [NSJSONSerialization dataWithJSONObject:self.additionalData options:0 error:NULL];
    [(PSSBaseObjectVersion*)self.detailItem.currentVersion setDecryptedAdditionalJSONfields:newJSONAdditionalData];
    
    [self.detailItem.managedObjectContext performBlock:^{
        [self.detailItem.managedObjectContext save:NULL];
    }];
    
    [self refreshTypeAndCounter];
}

@end

//  PSSTwoStepEditorTableViewController.m
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-09-03.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import "PSSTwoStepEditorTableViewController.h"
#import "PSSnewPasswordBasicTextFieldCell.h"
#import "PSSnewCardNumberTextFieldCell.h"
#import "PSSBarcodeScannerViewController.h"
#import "HOTPGenerator.h"
#import "TOTPGenerator.h"
#import "DDURLParser.h"



@interface PSSTwoStepEditorTableViewController ()

@property (nonatomic, strong) UISegmentedControl * typeSelector;
@property (nonatomic, strong) PSSnewCardNumberTextFieldCell * keyCell;
@property (nonatomic, strong) PSSnewPasswordBasicTextFieldCell * usernameCell;

@end

@implementation PSSTwoStepEditorTableViewController

-(void)presentBarcodeScanner:(id)sender{
    PSSBarcodeScannerViewController * barcodeScanner = [[PSSBarcodeScannerViewController alloc] init];
    
    barcodeScanner.scannerDelegate = self;
    
    [self.navigationController pushViewController:barcodeScanner animated:YES];
    
}

-(void)finishWithValuesDictionary:(NSDictionary*)dictionary animated:(BOOL)animated{
    if (self.editorDelegate) {
        [self.editorDelegate twoStepEditor:self finishedWithValues:dictionary];
    }
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self.navigationController dismissViewControllerAnimated:animated completion:NULL];
    }
    
}

-(void)done:(id)sender{

    // We remove the space characters as google tends to present them in a XXXX XXXX XXXX XXXX format
    NSString *secret = [[self.keyCell.textField.text stringByReplacingOccurrencesOfString:@" " withString:@""] stringByReplacingOccurrencesOfString:@"-" withString:@""];
    
    NSString * type;
    NSString * algorithm;
    NSNumber * digits;
    NSNumber * counter;
    NSNumber * period;
    NSString * account = self.usernameCell.textField.text;
    NSDictionary * valuesDictionary;
    if (self.typeSelector.selectedSegmentIndex == 0) {
        type = @"hotp";
        algorithm = [HOTPGenerator defaultAlgorithm];
        digits = @([HOTPGenerator defaultDigits]);
        counter = @([HOTPGenerator defaultInitialCounter]);
        valuesDictionary = @{PSSTwoStepTypeKey : type,
                             PSSTwoStepLabel : account,
                             PSSTwoStepAlgorithmKey : algorithm,
                             PSSTwoStepDigitsKey : digits,
                             PSSTwoStepCounterKey : counter,
                             PSSTwoStepSecretKey : secret};
    } else if (self.typeSelector.selectedSegmentIndex ==1 ) {
        type = @"totp";
        algorithm = [TOTPGenerator defaultAlgorithm];
        digits = @([TOTPGenerator defaultDigits]);
        period = @([TOTPGenerator defaultPeriod]);
        valuesDictionary = @{PSSTwoStepTypeKey : type,
                             PSSTwoStepAlgorithmKey : algorithm,
                             PSSTwoStepLabel : account,
                             PSSTwoStepDigitsKey : digits,
                             PSSTwoStepPeriodKey : period,
                             PSSTwoStepSecretKey : secret};
    }
    
    
    
    [self finishWithValuesDictionary:valuesDictionary animated:YES];
    
}

-(NSDictionary*)readQRResult:(NSString*)qrCode{
    
    // We should receive a string with the format @"otpauth://TYPE/LABEL?PARAMETERS"
    
    NSURL * qrURL = [NSURL URLWithString:qrCode];
    
    // Find the type, either hotp or totp
    NSString * type = [qrURL host];
    
    if (![type isEqualToString:@"hotp"] && ![type isEqualToString:@"totp"]) {
        // Type not supported
        return nil;
    }
    
    // Account name
    NSString * account;
    if ([qrURL.pathComponents count] < 1) {
        // Not enough path componenents
        account = @"";
    } else {
        account = [qrURL.pathComponents objectAtIndex:1];
    }
    
    DDURLParser * parser = [[DDURLParser alloc] initWithURLString:qrCode];
    
    // Secret
    NSString * secret = [parser valueForVariable:@"secret"];
    if (!secret) {
        // The secret is kind of the thing we want
        return nil;
    }
    
    // Algorithm
    NSString * algorithm = [parser valueForVariable:@"algorithm"];
    
    // Digits
    NSString * digitsString = [parser valueForVariable:@"digits"];
    
    // Counter
    NSString * counterString = [parser valueForVariable:@"counter"];
    
    // Period
    NSString * periodString = [parser valueForVariable:@"period"];
    
    NSNumber *digits;
    NSNumber *counter;
    NSNumber *period;
    NSNumberFormatter * numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    
    // Make adjustments depending of type
    if ([type isEqualToString:@"hotp"]) {
        // Counter based
        
        
        if (!algorithm) {
            algorithm = [HOTPGenerator defaultAlgorithm];
        }
        
        
        if (digitsString) {
            digits = [numberFormatter numberFromString:digitsString];
        }
        else{
            digits = @([HOTPGenerator defaultDigits]);
        }
        
        if (counterString) {
            counter = [numberFormatter numberFromString:counterString];
        }
        else {
            counter = @([HOTPGenerator defaultInitialCounter]);
        }
        
        NSDictionary * counterBasedDictionary = @{PSSTwoStepAlgorithmKey : algorithm,
                                                  PSSTwoStepCounterKey : counter,
                                                  PSSTwoStepDigitsKey : digits,
                                                  PSSTwoStepLabel : account,
                                                  PSSTwoStepSecretKey : secret,
                                                  PSSTwoStepTypeKey : type,
                                                  };
        
        return counterBasedDictionary;
        
        
    } else if ([type isEqualToString:@"totp"]) {
        // Time based
        
        if (!algorithm) {
            algorithm = [TOTPGenerator defaultAlgorithm];
        }
        
        
        if (digitsString) {
            digits = [numberFormatter numberFromString:digitsString];
        }
        else{
            digits = @([TOTPGenerator defaultDigits]);
        }
        
        if (periodString) {
            period = [numberFormatter numberFromString:periodString];
        }
        else {
            period = @([TOTPGenerator defaultPeriod]);
        }
        
        NSDictionary * timeBasedDictionary = @{PSSTwoStepAlgorithmKey : algorithm,
                                                  PSSTwoStepPeriodKey : period,
                                                  PSSTwoStepDigitsKey : digits,
                                                  PSSTwoStepLabel : account,
                                                  PSSTwoStepSecretKey : secret,
                                                  PSSTwoStepTypeKey : type,
                                                  };
        
        return timeBasedDictionary;
        
    }
    
    
    
    
    return nil;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}


-(void)cancelAction:(id)sender{
    [self.navigationController dismissViewControllerAnimated:YES completion:NULL];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = NSLocalizedString(@"Two-factor Authentication", nil);
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        UIBarButtonItem * cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelAction:)];
        
        self.navigationItem.leftBarButtonItem = cancelButton;
    }
    
    
    UIBarButtonItem * doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)];
    self.navigationItem.rightBarButtonItem = doneButton;
    
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    // If user cancels from machine readable image reader
    [self.navigationController.navigationBar setBarStyle:UIBarStyleDefault];
    
    
    [self.keyCell.textField becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0,0, 320, 44)]; // x,y,width,height
    
    NSArray *itemArray = [NSArray arrayWithObjects: NSLocalizedString(@"Time Based", nil), NSLocalizedString(@"Counter Based", nil), nil];
    UISegmentedControl *control = [[UISegmentedControl alloc] initWithItems:itemArray];
    [control setCenter:headerView.center];
    [control setSelectedSegmentIndex:0];
    [control setEnabled:YES];
    
    [headerView addSubview:control];
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 44.f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.row == 0) {
        
        UITableViewCell * cell;
        // Title Cell
        
        if (!self.usernameCell) {
            
            PSSnewPasswordBasicTextFieldCell * usernameCell = [[PSSnewPasswordBasicTextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            self.usernameCell = usernameCell;
            self.usernameCell.textField.placeholder = NSLocalizedString(@"Account", nil);
            self.usernameCell.textField.keyboardType = UIKeyboardTypeDefault;
            self.usernameCell.textField.autocorrectionType = UITextAutocorrectionTypeNo;
            self.usernameCell.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
            self.usernameCell.selectionStyle = UITableViewCellSelectionStyleNone;
            if (self.username) {
                self.usernameCell.textField.text = self.username;
            }
        }
        cell = self.usernameCell;
        
        return cell;

    } else if (indexPath.row == 1) {
        
        UITableViewCell * cell;
            // Title Cell
        
            if (!self.keyCell) {
                
                PSSnewCardNumberTextFieldCell * keyCell = [[PSSnewCardNumberTextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
                self.keyCell = keyCell;
                self.keyCell.textField.placeholder = NSLocalizedString(@"Key", nil);
                self.keyCell.textField.keyboardType = UIKeyboardTypeDefault;
                self.keyCell.textField.autocorrectionType = UITextAutocorrectionTypeNo;
                self.keyCell.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
                self.keyCell.selectionStyle = UITableViewCellSelectionStyleNone;
                
                self.keyCell.cameraButton.accessibilityLabel = NSLocalizedString(@"Scan Barcode", nil);
                
                if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                    [self.keyCell.cameraButton addTarget:self action:@selector(presentBarcodeScanner:) forControlEvents:UIControlEventTouchUpInside];
                } else {
                    [self.keyCell.cameraButton setEnabled:NO];
                }
                
            }
            cell = self.keyCell;
        
        return cell;
        
    }
    
    return nil;
}
#pragma mark - PSSBarcodeScannerDelegate methods

-(void)barcodeScanner:(PSSBarcodeScannerViewController *)scanner finishedWithString:(NSString *)qrcode{
    
    // Use the qrcode result and transform it in a dictionary
    NSDictionary * scannerDict = [self readQRResult:qrcode];
    if (scannerDict) {
        [self finishWithValuesDictionary:scannerDict animated:YES];
    } else {
#pragma TODO Alert user
        
    }
    
}

@end

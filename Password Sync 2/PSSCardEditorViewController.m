//
//  PSSCardEditorViewController.m
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-07-13.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import "PSSCardEditorViewController.h"
#import "PSSnewPasswordBasicTextFieldCell.h"
#import "PSSnewPasswordMultilineTextFieldCell.h"
#import "PSSnewCardExpirationTextFieldCell.h"
#import "PSSnewCardNumberTextFieldCell.h"
#import "PSSCardsEditorCardTypeSelectorTableViewController.h"
#import "PSSCreditCardVersion.h"
#import "PSSCreditCardBaseObject.h"
#import "PSSAppDelegate.h"

@interface PSSCardEditorViewController ()

@property (strong, nonatomic) PSSnewCardNumberTextFieldCell * numberCell;
@property (strong, nonatomic) PSSnewPasswordBasicTextFieldCell * nameCell;
@property (strong, nonatomic) PSSnewCardExpirationTextFieldCell * expirationCell;
@property (strong, nonatomic) UITableViewCell * cardTypeCell;
@property CardIOCreditCardType cardType;


@property (strong, nonatomic) PSSnewPasswordBasicTextFieldCell * bankNameCell;
@property (strong, nonatomic) PSSnewPasswordBasicTextFieldCell * bankNumberCell;
@property (strong, nonatomic) PSSnewPasswordBasicTextFieldCell * bankURLCell;

@property (strong, nonatomic) PSSnewPasswordMultilineTextFieldCell * notesCell;

@property BOOL isPasscodeUnlocked;

@end

@implementation PSSCardEditorViewController
@synthesize cardType = _cardType;
dispatch_queue_t backgroundQueue;



-(void)lockUI:(id)sender{
    
    self.isPasscodeUnlocked = NO;
    
    // Hide our sensitive information fields
    [self.numberCell.textField setAlpha:0.0];
    [self.expirationCell.cvvField setAlpha:0.0];
    
    // Launch a timer. If after 15 seconds our user is not back in the app, we'll just pop this editor our of the stack
    double delayInSeconds = 15.;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        // If user came back to the app in the meantime we just invalidate this timer
        if (!self.isPasscodeUnlocked) {
            
            if (self.navigationController.visibleViewController == self) {
                
                [self.navigationController popViewControllerAnimated:NO];
                
            }
            
        }
        
    });
    
    
}

-(void)unlockUI:(id)sender{
    
    self.isPasscodeUnlocked = YES;
    [self.numberCell.textField setAlpha:1.0];
    [self.expirationCell.cvvField setAlpha:1.0];
    
    
}



-(PSSCreditCardVersion*)insertNewCardVersionInManagedObject{
    
    PSSAppDelegate * appDelegate = (PSSAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    PSSCreditCardVersion *newManagedObject = (PSSCreditCardVersion*)[NSEntityDescription insertNewObjectForEntityForName:@"PSSCreditCardVersion" inManagedObjectContext:context];
    
    // We'll automatically timestamp it
    newManagedObject.timestamp = [NSDate date];
    
    return newManagedObject;
    
}

-(PSSCreditCardBaseObject*)insertNewCardInManagedObject{
    
    PSSAppDelegate * appDelegate = (PSSAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    PSSCreditCardBaseObject *newManagedObject = (PSSCreditCardBaseObject*)[NSEntityDescription insertNewObjectForEntityForName:@"PSSCreditCardBaseObject" inManagedObjectContext:context];
    
    // We'll add a creation date automatically
    newManagedObject.created = [NSDate date];
    
    return newManagedObject;
    
}

-(NSString*)redactedCardNumber:(NSString*)cardNumber{
    
    if ([cardNumber length] > 4) {
        NSMutableString*newString = [[NSMutableString alloc] initWithCapacity:[cardNumber length]];
        
        for (NSInteger counter = 0; counter<[cardNumber length]-4; counter++) {
            [newString appendString:@"•"];
        }
        // Add the last 4 digits
        NSString *trimmedString=[cardNumber substringFromIndex:[cardNumber length]-4];
        [newString appendString:trimmedString];
        return (NSString*)newString;
    }
    
    return @"••••";
}

-(void)saveChangesAndDismiss{
    
    BOOL creationMode = NO;
    
    if (!self.cardBaseObject) {
        self.cardBaseObject = [self insertNewCardInManagedObject];
        self.cardBaseObject.autofill = [NSNumber numberWithBool:YES];
        creationMode = YES;
    }
    
    NSMutableString * descriptionString = [[NSMutableString alloc] initWithCapacity:25];
    [descriptionString appendString:[CardIOCreditCardInfo displayStringForCardType:self.cardType usingLanguageOrLocale:[[NSLocale currentLocale] objectForKey:NSLocaleIdentifier]]];
    
    if (![self.bankNameCell.textField.text isEqualToString:@""]) {
        [descriptionString appendFormat:@" - %@", self.bankNameCell.textField.text];
    }
    self.cardBaseObject.cardName = descriptionString;
    self.cardBaseObject.displayName = [self redactedCardNumber:self.numberCell.textField.text];
    
    // We need to create a new version
    
    PSSCreditCardVersion * version = [self insertNewCardVersionInManagedObject];
    version.encryptedObject = self.cardBaseObject;
    
    version.decryptedNumber = self.numberCell.textField.text;
    version.decryptedCardholdersName = self.nameCell.textField.text;
    version.decryptedExpiryDate = self.expirationCell.textField.text;
    version.decryptedVerificationcode = self.expirationCell.cvvField.text;
    version.decryptedNote = self.notesCell.textView.text;
    version.cardType = [self stringForCardType:self.cardType];
    

    version.bankWebsite = self.bankURLCell.textField.text;
    version.bankPhoneNumber = self.bankNumberCell.textField.text;
    version.issuingBank = self.bankNameCell.textField.text;
    version.unencryptedLastDigits = self.cardBaseObject.displayName;
    
    self.cardBaseObject.currentVersion = version;
    
    [self.cardBaseObject.managedObjectContext performBlockAndWait:^{
        NSError *error = nil;
        if (![self.cardBaseObject.managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"An error occured", nil) message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
        }
    }];
    
    
    if (creationMode) {
        [self.navigationController dismissViewControllerAnimated:YES completion:^{
            
        }];
    } else {
        if (self.editorDelegate) {
            [self.editorDelegate objectEditor:self finishedWithObject:self.cardBaseObject];
        }
        
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    
}


-(void)saveActionWasTriggered:(id)sender{
    [self saveChangesAndDismiss];
}


-(NSString*)stringForCardType:(CardIOCreditCardType)cardType{
    NSString * cardTypeString;
    switch (cardType) {
        case CardIOCreditCardTypeVisa:
            cardTypeString = @"Visa";
            break;
        case CardIOCreditCardTypeMastercard:
            cardTypeString = @"Mastercard";
            break;
        case CardIOCreditCardTypeAmex:
            cardTypeString = @"Amex";
            break;
        case CardIOCreditCardTypeJCB:
            cardTypeString = @"JCB";
            break;
        case CardIOCreditCardTypeDiscover:
            cardTypeString = @"Discover";
            break;
        default:
            cardTypeString = @"";
    }
    return cardTypeString;
}

-(CardIOCreditCardType)cardTypeFromString:(NSString*)cardString{
    if ([cardString isEqualToString:@"Visa"]) {
        return CardIOCreditCardTypeVisa;
    } else if ([cardString isEqualToString:@"Mastercard"]){
        return CardIOCreditCardTypeMastercard;
    } else if ([cardString isEqualToString:@"Amex"]){
        return CardIOCreditCardTypeAmex;
    } else if ([cardString isEqualToString:@"Discover"]){
        return CardIOCreditCardTypeDiscover;
    } else if ([cardString isEqualToString:@"JCB"]){
        return CardIOCreditCardTypeJCB;
    }
    
    return CardIOCreditCardTypeUnrecognized;
    
}

// Card type getter-setter
-(void)setCardType:(CardIOCreditCardType)cardType{
    
    _cardType = cardType;
    if (self.cardTypeCell) {
        [self displayCartTypeVerboseName];
    }
    
}

-(CardIOCreditCardType)cardType{
    return _cardType;
}



-(void)startCameraImport:(id)sender{
    
    CardIOPaymentViewController *scanViewController = [[CardIOPaymentViewController alloc] initWithPaymentDelegate:self];
    scanViewController.appToken = @"879f7903c4d14602a8c0115a4594cc9a";
    
    
    if (self.cardBaseObject) {
        // We're in editing mode
    } else{
        scanViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        [self.navigationController presentViewController:scanViewController animated:YES completion:^{
            
        }];
    }
    
    
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)cancelNewCardEditor:(id)sender{
    
    if (self.editorDelegate && [self.editorDelegate respondsToSelector:@selector(objectEditor:canceledOperationOnObject:)]) {
        [self.editorDelegate objectEditor:self canceledOperationOnObject:self.cardBaseObject];
    }
    
    [self.navigationController dismissViewControllerAnimated:YES completion:^{}];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    backgroundQueue = dispatch_queue_create("com.pumaxprod.iOS.Password-Sync2.cardBankBackgroundFetchThread", NULL);
    
    UIBarButtonItem * saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveActionWasTriggered:)];
    self.navigationItem.rightBarButtonItem = saveButton;
    
    if (self.cardBaseObject) {
        // We're in edit mode
        self.cardType = [self cardTypeFromString:self.cardBaseObject.currentVersion.cardType];
        self.isPasscodeUnlocked = YES;
        // Register for notifications
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(lockUI:) name:PSSGlobalLockNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(unlockUI:) name:PSSGlobalUnlockNotification object:nil];
        
    } else {
        
        self.title = NSLocalizedString(@"New Card", nil);
        
        // We're writing a new password
        
        UIBarButtonItem * cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelNewCardEditor:)];
        
        self.navigationItem.leftBarButtonItem = cancelButton;
    }
    
    
}



-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    // Update the field order so we can easily navigate using the keyboard's "next" button
    self.nameCell.nextFormField = self.bankNameCell.textField;
    self.bankNameCell.nextFormField = self.bankNumberCell.textField;
    self.bankNumberCell.nextFormField = self.bankURLCell.textField;
    self.bankURLCell.nextFormField = self.notesCell.textView;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)fillBankDetailsWithBank:(NSDictionary*)bankInfo{
    self.bankNameCell.textField.text = [bankInfo objectForKey:@"bankName"];
    self.bankNumberCell.textField.text = [bankInfo objectForKey:@"emergencyNumber"];
    self.bankURLCell.textField.text = [bankInfo objectForKey:@"bankWebsite"];
}

-(NSDictionary*)automaticallyFetchBankDataForCardNumber:(NSString*)bankNumber{
    
    // Do this on a background thread to avoid blocking the UI
    dispatch_async(backgroundQueue, ^(void) {
        
        
        // Load a PLIST containing the bank infos
        NSString* filePath = [[NSBundle mainBundle] pathForResource:@"bankEmercyContacts" ofType:@"plist"];
        
        // The PLIST contains an array of NSDictionarys, on for each bank
        NSArray * bankEmergencyContactArray = [[NSArray alloc] initWithContentsOfFile:filePath];
        
        
        // Go through each bank, one after the other
        for (NSDictionary * bankDetails in bankEmergencyContactArray) {
            
            // We'll iterate through each of the reserved numbers for that bank
            NSArray * bankReservedNumbers = [bankDetails objectForKey:@"cardID"];
            for (NSString * bankReservedNumber in bankReservedNumbers) {
                
                if ([bankNumber hasPrefix:bankReservedNumber]) {
                    // We have a match: return the bank NSDictionary on the main queue
                    dispatch_async(dispatch_get_main_queue(), ^(void) {
                        [self fillBankDetailsWithBank:bankDetails];
                        return;
                    });
                    
                }
                
                
            }
        }
        
        
    });
    
    
    
    
    
    return nil;
}

-(void)displayCartTypeVerboseName{
    
    switch (self.cardType) {
        case CardIOCreditCardTypeUnrecognized:
        case CardIOCreditCardTypeAmbiguous:
            self.cardTypeCell.textLabel.text = NSLocalizedString(@"Other", nil);
            break;
        case CardIOCreditCardTypeAmex:
            self.cardTypeCell.textLabel.text = @"American Express";
            self.bankNameCell.textField.text = NSLocalizedString(@"American Express", nil);
            self.bankNumberCell.textField.text = @"(North America) 1-800-992-3404; (Abroad) +1-336-393-1111";
            self.bankURLCell.textField.text = NSLocalizedString(@"http://www.americanexpress.com/", nil);
            break;
        case CardIOCreditCardTypeDiscover:
            self.cardTypeCell.textLabel.text = @"Discover";
            break;
        case CardIOCreditCardTypeJCB:
            self.cardTypeCell.textLabel.text = @"JCB";
            break;
        case CardIOCreditCardTypeMastercard:
            self.cardTypeCell.textLabel.text = @"MasterCard";
            break;
        case CardIOCreditCardTypeVisa:
            self.cardTypeCell.textLabel.text = @"Visa";
        default:
            break;
    }
    
}

#pragma mark - Table view data source

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 2) {
        return 144.;
    }
    
    return 44.;
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    
    if (section == 1) {
        return NSLocalizedString(@"Emergency Details", nil);
    } else if (section == 2){
        return NSLocalizedString(@"Notes", nil);
    }
    
    return @"";
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        // Basic informations
        return 4;
    } else if (section == 1) {
        // Emergency information
        return 3;
    } else if (section == 2) {
        // Notes
        return 1;
    }

    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell;
    if (indexPath.section == 0 && indexPath.row == 0) {
        // Number Cell
        
        if (!self.numberCell) {
            
            PSSnewCardNumberTextFieldCell * numberCell = [[PSSnewCardNumberTextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            self.numberCell = numberCell;
            if (self.cardBaseObject) {
                self.numberCell.textField.text = self.cardBaseObject.currentVersion.decryptedNumber;
            }
            self.numberCell.textField.placeholder = NSLocalizedString(@"Card Number", nil);
            self.numberCell.selectionStyle = UITableViewCellSelectionStyleNone;
            self.numberCell.nextFormField = self.expirationCell.textField;
            
            
            // Automatically try to complete the bank details for the typed credit card number
            // We never query bank details one existing card object / edit mode.
            __weak typeof(self) weakSelf = self;
            if (!self.cardBaseObject) {
                [self.numberCell setFinishedEditingNumberBlock:^{
                    // Only proceed with the filling if user has not already started typing in the bank infos
                    if ([weakSelf.bankNameCell.textField.text isEqualToString:@""]) {
                        [weakSelf automaticallyFetchBankDataForCardNumber:weakSelf.numberCell.textField.text];
                    }
                }];
            }
            
            [self.numberCell.cameraButton addTarget:self action:@selector(startCameraImport:) forControlEvents:UIControlEventTouchUpInside];
            
        }
        cell = self.numberCell;
        
    } else if (indexPath.section == 0 && indexPath.row == 1) {
        // Expiration Cell
        
        if (!self.expirationCell) {
            
            PSSnewCardExpirationTextFieldCell * expirationCell = [[PSSnewCardExpirationTextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            self.expirationCell = expirationCell;
            if (self.cardBaseObject) {
                self.expirationCell.textField.text = self.cardBaseObject.currentVersion.decryptedExpiryDate;
                self.expirationCell.cvvField.text = self.cardBaseObject.currentVersion.decryptedVerificationcode;
            }
            self.expirationCell.textField.placeholder = NSLocalizedString(@"MM/YYYY", nil);
            self.expirationCell.cvvField.placeholder = NSLocalizedString(@"CVV/CVC2", nil);
            self.expirationCell.selectionStyle = UITableViewCellSelectionStyleNone;
            self.expirationCell.nextFormField = self.nameCell.textField;
            
            
        }
        cell = self.expirationCell;
        
    } else if (indexPath.section == 0 && indexPath.row == 2) {
        // Card Type
        
        if (!self.cardTypeCell) {
            
            UITableViewCell * cardTypeCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            self.cardTypeCell = cardTypeCell;
            if (self.cardBaseObject) {
                [self displayCartTypeVerboseName];
            } else {
                self.cardTypeCell.textLabel.text = NSLocalizedString(@"Card Type", nil);
            }
            
            self.cardTypeCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            self.cardTypeCell.selectionStyle = UITableViewCellSelectionStyleNone;
            
        }
        cell = self.cardTypeCell;
        
        
        
    } else if (indexPath.section == 0 && indexPath.row == 3) {
        // Name on card Cell
        
        if (!self.nameCell) {
            
            PSSnewPasswordBasicTextFieldCell * nameCell = [[PSSnewPasswordBasicTextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            self.nameCell = nameCell;
            if (self.cardBaseObject) {
                self.nameCell.textField.text = self.cardBaseObject.currentVersion.decryptedCardholdersName;
            }
            self.nameCell.textField.placeholder = NSLocalizedString(@"Name on card", nil);
            self.nameCell.selectionStyle = UITableViewCellSelectionStyleNone;
            self.nameCell.textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
            self.nameCell.nextFormField = self.bankNameCell.textField;
            
        }
        cell = self.nameCell;
        
        
        
    } else if (indexPath.section == 1 && indexPath.row == 0) {
        // Bank name Cell
        
        if (!self.bankNameCell) {
            
            PSSnewPasswordBasicTextFieldCell * bankNameCell = [[PSSnewPasswordBasicTextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            self.bankNameCell = bankNameCell;
            if (self.cardBaseObject) {
                self.bankNameCell.textField.text = self.cardBaseObject.currentVersion.issuingBank;
            }
            self.bankNameCell.textField.placeholder = NSLocalizedString(@"Card Issuer / Bank Name", nil);
            self.bankNameCell.selectionStyle = UITableViewCellSelectionStyleNone;
            self.bankNameCell.textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
            self.bankNameCell.nextFormField = self.bankNumberCell.textField;
            
        }
        cell = self.bankNameCell;
        
        
        
    } else if (indexPath.section == 1 && indexPath.row == 1){
        // Bank Phone Number cell
        
        if (!self.bankNumberCell) {
            
            PSSnewPasswordBasicTextFieldCell * bankNumberCell = [[PSSnewPasswordBasicTextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            
            self.bankNumberCell = bankNumberCell;
            self.bankNumberCell.textField.placeholder = NSLocalizedString(@"Emergency Phone Number", nil);
            if (self.cardBaseObject) {
                self.bankNumberCell.textField.text = self.cardBaseObject.currentVersion.bankPhoneNumber;
            }
            self.bankNumberCell.selectionStyle =UITableViewCellSelectionStyleNone;
            self.bankNumberCell.nextFormField = self.bankURLCell.textField;
        }
        
        cell = self.bankNumberCell;
        
    } else if (indexPath.section == 1 && indexPath.row == 2){
        // Bank URL cell
        
        if (!self.bankURLCell) {
            
            PSSnewPasswordBasicTextFieldCell * bankURLCell = [[PSSnewPasswordBasicTextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            
            self.bankURLCell = bankURLCell;
            self.bankURLCell.textField.placeholder = NSLocalizedString(@"Website", nil);
            if (self.cardBaseObject) {
                self.bankURLCell.textField.text = self.cardBaseObject.currentVersion.bankWebsite;
            }
            self.bankURLCell.selectionStyle =UITableViewCellSelectionStyleNone;
            
        }
        
        cell = self.bankURLCell;
        
    } else if (indexPath.section == 2 && indexPath.row == 0){
        // Notes cell
        
        if (!self.notesCell) {
            
            PSSnewPasswordMultilineTextFieldCell * notesCell = [[PSSnewPasswordMultilineTextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            
            self.notesCell = notesCell;
            if (self.cardBaseObject) {
                self.notesCell.textView.text = [self.cardBaseObject.currentVersion decryptedNote];
            }
            self.notesCell.selectionStyle =UITableViewCellSelectionStyleNone;
            
        }
        
        cell = self.notesCell;
        
    }


    
    return cell;
}




#pragma mark - Navigation


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 0 && indexPath.row == 2) {
        // Card Type
        
        PSSCardsEditorCardTypeSelectorTableViewController * typeSelector = [[PSSCardsEditorCardTypeSelectorTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
        
        typeSelector.selectedCardType = self.cardType;
        typeSelector.cardEditorDelegate = self;
        [self.navigationController pushViewController:typeSelector animated:YES];
        
        
    }
    
    
}

#pragma mark - Card.io delegate

- (void)userDidCancelPaymentViewController:(CardIOPaymentViewController *)scanViewController {
    
    if (!self.cardBaseObject) {
        [scanViewController dismissViewControllerAnimated:YES completion:^{}];
    }
    
}

- (void)userDidProvideCreditCardInfo:(CardIOCreditCardInfo *)info inPaymentViewController:(CardIOPaymentViewController *)scanViewController {

    [self.numberCell setCardNumber:info.cardNumber];
    [self.expirationCell setExpirationDate:[NSString stringWithFormat:@"%02i/%i", info.expiryMonth, info.expiryYear]];
    self.expirationCell.cvvField.text = info.cvv;
    self.cardType = info.cardType;
    
    // Use the card info...
    if (!self.cardBaseObject) {
        [scanViewController dismissViewControllerAnimated:YES completion:^{
            // Give first responder to name field
            [self.nameCell.textField becomeFirstResponder];

        }];
    }
}

#pragma mark - PSSCardsEditorCardTypeSelectorProtocol methods

-(void)cardSelector:(PSSCardsEditorCardTypeSelectorTableViewController *)cardSelector finishedWithCardType:(CardIOCreditCardType)cardType{
    [self setCardType:cardType];
}

@end

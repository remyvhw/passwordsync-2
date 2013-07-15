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


@end

@implementation PSSCardEditorViewController
@synthesize cardType = _cardType;
dispatch_queue_t backgroundQueue;

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
    
    if (self.cardBaseObject) {
        // We're in edit mode
        //self.cardType =
    } else {
        
        self.title = NSLocalizedString(@"New Card", nil);
        
        // We're writing a new password
        
        UIBarButtonItem * cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelNewCardEditor:)];
        
        self.navigationItem.leftBarButtonItem = cancelButton;
    }
    
    
    
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
                //self.titleCell.textField.text = self.passwordBaseObject.displayName;
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
                //self.titleCell.textField.text = self.passwordBaseObject.displayName;
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
                //self.titleCell.textField.text = self.passwordBaseObject.displayName;
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
            if (self.nameCell) {
                //self.titleCell.textField.text = self.passwordBaseObject.displayName;
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
            if (self.bankNameCell) {
                //self.bankNameCell.textField.text = self.bankNameCell..displayName;
            }
            self.bankNameCell.textField.placeholder = NSLocalizedString(@"Card Issuer / Bank Name", nil);
            self.bankNameCell.selectionStyle = UITableViewCellSelectionStyleNone;
            self.bankNameCell.textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
            //self.nameCell.nextFormField = self.cardType.textField;
            
        }
        cell = self.bankNameCell;
        
        
        
    } else if (indexPath.section == 1 && indexPath.row == 1){
        // Bank Phone Number cell
        
        if (!self.bankNumberCell) {
            
            PSSnewPasswordBasicTextFieldCell * bankNumberCell = [[PSSnewPasswordBasicTextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            
            self.bankNumberCell = bankNumberCell;
            self.bankNumberCell.textField.placeholder = NSLocalizedString(@"Emergency Phone Number", nil);
            if (self.cardBaseObject) {
                //self.notesCell.textView.text = [self.passwordBaseObject.currentVersion decryptedNotes];
            }
            self.bankNumberCell.selectionStyle =UITableViewCellSelectionStyleNone;
            
        }
        
        cell = self.bankNumberCell;
        
    } else if (indexPath.section == 1 && indexPath.row == 2){
        // Bank URL cell
        
        if (!self.bankURLCell) {
            
            PSSnewPasswordBasicTextFieldCell * bankURLCell = [[PSSnewPasswordBasicTextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            
            self.bankURLCell = bankURLCell;
            self.bankURLCell.textField.placeholder = NSLocalizedString(@"Website", nil);
            if (self.cardBaseObject) {
                //self.notesCell.textView.text = [self.passwordBaseObject.currentVersion decryptedNotes];
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
                //self.notesCell.textView.text = [self.passwordBaseObject.currentVersion decryptedNotes];
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

//
//  PSSCardEmergencyContactTableViewController.m
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-07-22.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import "PSSCardEmergencyContactTableViewController.h"
#import "PSSCreditCardVersion.h"

@interface PSSCardEmergencyContactTableViewController ()

@property (strong, nonatomic) NSArray * arrayOfCountryPhonePairs;
@property (nonatomic, readonly)  BOOL deviceCanCall;

@end

@implementation PSSCardEmergencyContactTableViewController
@synthesize deviceCanCall = _deviceCanCall;


-(BOOL)deviceCanCall{
    
    BOOL deviceCanCall = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tel:1-555-555-5555"]];
    _deviceCanCall = deviceCanCall;
    return deviceCanCall;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)buildPhoneNumberList{
    
    // @"(Canada) 1-800-555-5555; (US) 1-800-555-6666"
    NSString * contactPhoneString = self.detailItem.currentVersion.bankPhoneNumber;
    
    // @[@"(Canada) 1-800-555-5555", @" (US) 1-800-555-6666"]
    NSArray * countriesAndPhonesComponents = [contactPhoneString componentsSeparatedByString:@";"];
    
    NSMutableArray * mutableArrayOfCountriesAndPhones = [[NSMutableArray alloc] initWithCapacity:[countriesAndPhonesComponents count]];
    
    NSCharacterSet *spaceAndOpeningParentheses = [NSCharacterSet characterSetWithCharactersInString:@" ("];
    for (NSString * countryAndPhone in countriesAndPhonesComponents) {
        
        // @[@"(Canada", @" 1-800-555-5555"]
        NSArray * componentsOfString = [countryAndPhone componentsSeparatedByString:@")"];
        if ([componentsOfString count] == 2) {
            
            
            // @"Canada"
            NSString * countryName = [[componentsOfString objectAtIndex:0] stringByTrimmingCharactersInSet:spaceAndOpeningParentheses];
            
            // @"1-800-555-5555"
            NSString * contactNumber = [[componentsOfString objectAtIndex:1] stringByTrimmingCharactersInSet:spaceAndOpeningParentheses];
            
            NSDictionary * countryDict = @{@"country":countryName,
                                           @"number":contactNumber};
            
            [mutableArrayOfCountriesAndPhones addObject:countryDict];
            
        }
        
    }
    
    self.arrayOfCountryPhonePairs = (NSArray*)mutableArrayOfCountriesAndPhones;
    
}

-(BOOL)shouldWeAdoptPhoneContactList{
    
    // Test to see if the string adopts the format @"(Country Name) 555-555-1234;"
    
    NSCharacterSet * requiredCharacters = [NSCharacterSet characterSetWithCharactersInString:@"();"];
    if ([self.detailItem.currentVersion.bankPhoneNumber rangeOfCharacterFromSet:requiredCharacters].location != NSNotFound){
        return YES;
    }
    
    return NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"titleViewCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"BankContactWebsiteCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"bankWebsiteCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"BankContactPhoneNumberCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"countryNumberCell"];
    
    if ([self shouldWeAdoptPhoneContactList]) {
        
        // Build list of phone contact dictionaries
        [self buildPhoneNumberList];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    
    if (self.detailItem.currentVersion.bankPhoneNumber && ![self.detailItem.currentVersion.bankPhoneNumber isEqualToString:@""]) {
        return 2;
    }
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    
    if (section==0) {
        if (self.detailItem.currentVersion.bankWebsite) {
            return 2;
        }
        return 1;
    } else if (section == 1) {
        
        if ([self.arrayOfCountryPhonePairs count]) {
            return [self.arrayOfCountryPhonePairs count];
        }
        return 0;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section == 0 && indexPath.row == 0) {
        // Bank name cell
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"titleViewCell" forIndexPath:indexPath];
        cell.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if (self.detailItem.currentVersion.issuingBank) {
            cell.textLabel.text = self.detailItem.currentVersion.issuingBank;
        } else {
            cell.textLabel.text = NSLocalizedString(@"Unknown Bank", nil);
        }
        
        return cell;
        
    } else if (indexPath.section == 0 && indexPath.row == 1) {
        // Bank website cell
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"bankWebsiteCell" forIndexPath:indexPath];
        
        if (self.detailItem.currentVersion.bankWebsite && ![self.detailItem.currentVersion.bankWebsite isEqualToString:@""]) {
            cell.textLabel.text = self.detailItem.currentVersion.bankWebsite;
        } else {
            cell.textLabel.text = NSLocalizedString(@"Search the web", nil);
        }
        
        return cell;
    } else if (indexPath.section == 1 && [self.arrayOfCountryPhonePairs count]) {
        // Provide a list of UITableViewCell for each country
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"countryNumberCell" forIndexPath:indexPath];
        
        NSDictionary * countryDict = [self.arrayOfCountryPhonePairs objectAtIndex:indexPath.row];
        
        cell.textLabel.text = [countryDict objectForKey:@"country"];
        cell.detailTextLabel.text = [countryDict objectForKey:@"number"];
        if (self.deviceCanCall) {
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        } else {
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        return cell;
        
    }
    
    
    // Configure the cell...
    
    return nil;
}

#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 0 && indexPath.row == 1) {
        // Open the bank's website or search the web
        
        if (self.detailItem.currentVersion.bankWebsite && ![self.detailItem.currentVersion.bankWebsite isEqualToString:@""]) {
            // Open bank URL
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.detailItem.currentVersion.bankWebsite]];
        } else {
            // Search the web
            NSString * encodedQuery = [self.detailItem.currentVersion.issuingBank stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            
            NSURL * queryURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://www.google.com/search?q=%@", encodedQuery]];
            [[UIApplication sharedApplication] openURL:queryURL];
            
        }
        
    } else if (indexPath.section == 1 && [self.arrayOfCountryPhonePairs count]) {
        
        if (![self deviceCanCall]) {
            return;
        }
        
        // Open the phone number
        NSDictionary * selectedDict = [self.arrayOfCountryPhonePairs objectAtIndex:indexPath.row];
        
        UIActionSheet * actionSheet = [[UIActionSheet alloc] initWithTitle:[NSString stringWithFormat:@"%@ - %@", [selectedDict objectForKey:@"country"], [selectedDict objectForKey:@"number"]] delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Call", nil), nil];
        
        
        [actionSheet showFromTabBar:[(UITabBarController*)self.view.window.rootViewController tabBar]];
        
        
        
    }
    
}


#pragma mark - UIActionSheetDelegate methods

-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 1) {
        NSIndexPath * selectItemIndexPath = [self.tableView indexPathForSelectedRow];
        NSDictionary * selectedDict = [self.arrayOfCountryPhonePairs objectAtIndex:selectItemIndexPath.row];
        
        NSString * phoneNumberString = [NSString stringWithFormat:@"tel:%@", [selectedDict objectForKey:@"number"]];
        NSURL * phoneURL = [NSURL URLWithString:phoneNumberString];
        
        [[UIApplication sharedApplication] openURL:phoneURL];

    }

    
    
    
}


@end

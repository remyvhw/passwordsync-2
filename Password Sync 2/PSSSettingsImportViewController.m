//
//  PSSSettingsImportViewController.m
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 10/6/2013.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import "PSSSettingsImportViewController.h"
#import <DBChooser/DBChooser.h>
#import "PSSAppDelegate.h"
#import "SVProgressHUD.h"

@interface PSSSettingsImportViewController ()

@end

@implementation PSSSettingsImportViewController



-(void)importFromDropbox{
    
    [[DBChooser defaultChooser] openChooserForLinkType:DBChooserLinkTypeDirect
                                    fromViewController:self completion:^(NSArray *results)
     {
         if ([results count]) {
             // Process results from Chooser
             
             // Prepare the queue in case we need it
             dispatch_queue_t request_queue = dispatch_queue_create("com.pumaxprod.iOS.Password-Sync-2.dropboxDownloadQueue", NULL);
             dispatch_queue_t main_queue = dispatch_get_main_queue();

             // Iterate through the received files
             [results enumerateObjectsUsingBlock:^(DBChooserResult* obj, NSUInteger idx, BOOL *stop) {
                
                // Check if the file received is a local file or a network file.
                 
                if ([obj.link isFileURL]) {
                    // It's a file URL (local), we don't have to download it.
                    [APP_DELEGATE handleFileURL:obj.link];
                } else {
                    // Show the HUD since it might take a while
                    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
                    
                    // The file is on a server somewhere, we have to download it first, then save it in a temporary folder so our import routine can handle it.
                    
                    dispatch_async(request_queue, ^{
                        
                        NSError * downloadError;
                        NSData * rawData = [NSData dataWithContentsOfURL:obj.link options:NSDataReadingUncached error:&downloadError];
                        
                        
                        if (downloadError) {
                            dispatch_sync(main_queue, ^{
                                // Alert the user of a download error
                                [SVProgressHUD dismiss];
                                UIAlertView * downloadAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"An Error Occured", nil) message:[downloadError localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
                                [downloadAlert show];
                                return;
                            });
                        }
                        
                        
                        NSURL *tmpDirURL = [NSURL fileURLWithPath:NSTemporaryDirectory() isDirectory:YES];
                        
                        NSURL * fileTemporaryURL = [tmpDirURL URLByAppendingPathComponent:obj.name];
                        
                        NSError * writeError;
                        [rawData writeToURL:fileTemporaryURL options:NSDataWritingAtomic error:&writeError];
                        
                        if (writeError) {
                            dispatch_sync(main_queue, ^{
                                // Alert the user of a download error
                                [SVProgressHUD dismiss];
                                UIAlertView * downloadAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"An Error Occured", nil) message:[writeError localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
                                [downloadAlert show];
                                return;
                            });
                        }
                        
                        dispatch_sync(main_queue, ^{
                            // Everything went A-OK. End the process
                            
                            [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Success", nil)];
                            
                            [APP_DELEGATE handleFileURL:fileTemporaryURL];
                            
                        });
                    });
                
                
                }
                
                
                
                
                
                
            }];
             
         } // else: user canceled the action. Do nothing.
     }];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.title = NSLocalizedString(@"Import", nil);
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

-(NSString*)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section{
    if (section == 1) {
        return NSLocalizedString(@"Password Sync can import website passwords from a CSV file, as well as documents from many file (.pdf, .docx, .pptx, etc.) or image (.png, .jpg, .tiff, etc.) formats.", nil);
    }
    return @"";
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 1) {
        return 444.;
    }
    return 44.;
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section==0) {
        return NSLocalizedString(@"Import from...", nil);
        
    } else if (section==1) {
        return NSLocalizedString(@"Import from other apps", nil);
    }
    return @"";
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    if (indexPath.section == 0 && indexPath.row == 0) {
        
        // Import from Dropbox
        static NSString *CellIdentifier = @"buttonCell";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        cell.textLabel.text = @"Dropbox";
        cell.textLabel.textColor = cell.window.tintColor;
        cell.imageView.image = [UIImage imageNamed:@"Dropbox"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
    } else if (indexPath.section == 1 && indexPath.row == 0) {
        // From other apps
        
        static NSString *CellIdentifier = @"imageCell";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        
        UIImageView * imageView = (UIImageView*)[cell viewWithTag:1];
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            imageView.image = [UIImage imageNamed:@"Import-Other-App-View-iPad"];
        } else {
            imageView.image = [UIImage imageNamed:@"Import-Other-App-View"];
        }
        
        
        
        cell.selectionStyle =UITableViewCellSelectionStyleNone;
        
    }
    
    
    
    
    return cell;
}

#pragma mark - UITableViewDelegate methods

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 0 && indexPath.row == 0) {
        
        // Dropbox
        [self importFromDropbox];
        
        
    }
    
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


@end

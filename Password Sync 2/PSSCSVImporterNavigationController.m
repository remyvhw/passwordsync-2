//
//  PSSCSVImporterNavigationController.m
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-10-01.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import "PSSCSVImporterNavigationController.h"
#import "PSSCSVImporterEncodingChooserTableViewController.h"
#import "SVProgressHUD.h"
#import "PSSCSVColumnSelectorTableViewController.h"
#import "PSSAppDelegate.h"
#import "PSSPasswordVersion.h"
#import "PSSPasswordBaseObject.h"

@interface PSSCSVImporterNavigationController ()

@property (nonatomic, strong) NSMutableArray * currentLine;
@property (nonatomic, strong) NSManagedObjectContext * threadSafeContext;

@end

@implementation PSSCSVImporterNavigationController
@synthesize currentLine = _currentLine;
@synthesize lines = _lines;

-(void)finishImportation{
    [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Success", nil)];
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)backgroundContextDidSave:(NSNotification *)notification {
    /* Make sure we're on the main thread when updating the main context */
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(backgroundContextDidSave:)
                               withObject:notification
                            waitUntilDone:NO];
        return;
    }
    
    /* merge in the changes to the main context */
    [APP_DELEGATE.managedObjectContext mergeChangesFromContextDidSaveNotification:notification];
}




-(PSSPasswordVersion*)insertNewPasswordVersionInManagedObject{
    
    
    NSManagedObjectContext *context = self.threadSafeContext;
    PSSPasswordVersion *newManagedObject = (PSSPasswordVersion*)[NSEntityDescription insertNewObjectForEntityForName:@"PSSPasswordVersion" inManagedObjectContext:context];
    
    // We'll automatically timestamp it
    newManagedObject.timestamp = [NSDate date];
    
    return newManagedObject;
    
}

-(PSSPasswordBaseObject*)insertNewPasswordInManagedObject{
    
    NSManagedObjectContext *context = self.threadSafeContext;
    PSSPasswordBaseObject *newManagedObject = (PSSPasswordBaseObject*)[NSEntityDescription insertNewObjectForEntityForName:@"PSSPasswordBaseObject" inManagedObjectContext:context];
    
    // We'll add a creation date automatically
    newManagedObject.created = [NSDate date];
    
    return newManagedObject;
    
}


-(void)importWebsitePasswordWithScheme:(NSDictionary*)importScheme{
    
    
    dispatch_queue_t main_queue = dispatch_get_main_queue();
    dispatch_queue_t request_queue = dispatch_queue_create("com.pumaxprod.iOS.Password-Sync-2.passwordsyncCSVImportThread", NULL);
    
    __block __typeof__(self) blockSelf = self;
    
    dispatch_async(request_queue, ^{
        
    
        __block NSNumber* titleIndex;
        __block NSNumber* usernameIndex;
        __block NSNumber* passwordIndex;
        __block NSNumber* urlIndex;
        __block NSNumber* notesIndex;
    
        __block NSInteger biggerIndex = 0;
        // fast enumerate the received import scheme to assign the appropriate fields
        
        [importScheme enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            
            if ([obj integerValue] != 0) {
                
                // Remove one because there's a 'No Data' column in the UI
                
                NSInteger objColumnInteger = [obj integerValue]-1;
                // Convert back to NSNumber
                NSNumber * objColumn = @(objColumnInteger);
                
                
                if ([key isEqualToString:@"0"]) {
                    // Title
                    titleIndex = objColumn;
                } else if ([key isEqualToString:@"1"]) {
                    // Username
                    usernameIndex = objColumn;
                } else if ([key isEqualToString:@"2"]) {
                    // Password
                    passwordIndex = objColumn;
                } else if ([key isEqualToString:@"3"]) {
                    // URL index
                    urlIndex = objColumn;
                } else {
                    // Notes
                    notesIndex = objColumn;
                }
                
                // Check if the index is larger than the previous one so we don't go out of bounds
                if ([objColumn integerValue] > biggerIndex) {
                    biggerIndex = [objColumn integerValue];
                }
                
            }
            
        }];
        
        if (!titleIndex) {
            
            dispatch_sync(main_queue, ^{
                
                
                [SVProgressHUD dismiss];
                UIAlertView * errorView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"An Error Occured", nil) message:NSLocalizedString(@"Title field cannot be left empty.", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
                [errorView show];
                
            });
            
            
            
            return;

        }
        
        // Now we know which column goes where. Parse through the received data and create objects
        
        
        // update and heavy lifting...
        
        NSManagedObjectContext * threadSafeContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [threadSafeContext setPersistentStoreCoordinator:APP_DELEGATE.persistentStoreCoordinator];
        self.threadSafeContext = threadSafeContext;
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(backgroundContextDidSave:)
                                                     name:NSManagedObjectContextDidSaveNotification
                                                   object:threadSafeContext];
        
        
        // Create the stuff
        
        for (NSArray * line in blockSelf.lines) {
            
            if (line.count >= biggerIndex) {
                // The line is complete
                
                PSSPasswordBaseObject* passwordBase = [blockSelf insertNewPasswordInManagedObject];
                
                NSMutableArray * remainingFields = [[NSMutableArray alloc] initWithArray:line];
                
                if (urlIndex && ![[line objectAtIndex:[urlIndex integerValue]] isEqualToString:@""]) {
                    NSString * url = [line objectAtIndex:[urlIndex integerValue]];
                    [passwordBase setMainDomainFromString:url];
                    [remainingFields removeObject:url];
                }
                
                PSSPasswordVersion * version = [blockSelf insertNewPasswordVersionInManagedObject];
                
                version.encryptedObject = passwordBase;
                
                // Get the title
                NSString * displayTitle = [line objectAtIndex:[titleIndex integerValue]];
                version.displayName = displayTitle;
                passwordBase.displayName = version.displayName;
                [remainingFields removeObject:displayTitle];
                
                
                if (usernameIndex && ![[line objectAtIndex:[usernameIndex integerValue]] isEqualToString:@""]) {
                    NSString * username = [line objectAtIndex:[usernameIndex integerValue]];
                    version.decryptedUsername = username;
                    [remainingFields removeObject:username];
                }
                if (passwordIndex && ![[line objectAtIndex:[passwordIndex integerValue]] isEqualToString:@""]) {
                    NSString * password = [line objectAtIndex:[passwordIndex integerValue]];
                    version.decryptedPassword = password;
                    [remainingFields removeObject:password];
                }
                if (notesIndex && ![[line objectAtIndex:[notesIndex integerValue]] isEqualToString:@""]) {
                    NSString * notes = [line objectAtIndex:[notesIndex integerValue]];
                    version.decryptedNotes = notes;
                    [remainingFields removeObject:notes];
                }
                
                passwordBase.currentVersion = version;
                
                //TODO: Keep other columns and add them to the JSON payload.
                
                // Remove empty lines
                [remainingFields removeObject:@""];
                
                if (remainingFields.count > 0) {
                    // If we have columns that we haven't imported and that contain data, we will save them in the version's JSON encrypted payload
                    
                    NSDictionary * jsonPayloadDict = @{NSLocalizedString(@"Imported Attributes", nil): remainingFields};
                    
                    NSData * jsonPayload = [NSJSONSerialization dataWithJSONObject:jsonPayloadDict options:0 error:NULL];
                    
                    version.decryptedAdditionalJSONfields = jsonPayload;
                    
                }
                
            }
            
        }
        
        
        // Save the data
        [self.threadSafeContext performBlockAndWait:^{
            NSError * error;
            [self.threadSafeContext save:&error];
        }];
        
        
        
        
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:NSManagedObjectContextDidSaveNotification
                                                      object:threadSafeContext];
        
        dispatch_sync(main_queue, ^{
            
            
            [blockSelf finishImportation];
            
            
        });

        
    });

        
    
}

-(void)endWithDataArrangment:(NSDictionary *)arrangementDictionary{
    
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Importing", nil) maskType:SVProgressHUDMaskTypeGradient];
    
    
    // Eventually, we might split the process here and import other things.
    [self importWebsitePasswordWithScheme:arrangementDictionary];
    
}

-(void)cancelAndDismiss:(id)sender{
    
    [self dismissViewControllerAnimated:YES completion:NULL];
    
}

-(NSArray*)fieldsForDataType{
    
    
    NSArray * websiteArray = @[NSLocalizedString(@"Title", nil), NSLocalizedString(@"Username", nil), NSLocalizedString(@"Password", nil), NSLocalizedString(@"URL", nil), NSLocalizedString(@"Notes", nil)];
    
    
    return websiteArray;
}

-(void)deduceSeparatorFromFileUTI:(NSURL*)fileURL{
    
    UIDocumentInteractionController * documentController = [UIDocumentInteractionController interactionControllerWithURL:fileURL];
    
    if ([documentController.UTI isEqualToString:@"public.comma-separated-values-text"]) {
        self.separator = @",";
    } else if ([documentController.UTI isEqualToString:@"public.tab-separated-values-text"]) {
        self.separator = @"\t";
    }
    
}


- (id)initWithCSVDocumentURL:(NSURL *)documentURL
{
    PSSCSVImporterEncodingChooserTableViewController * encodingChooser = [[PSSCSVImporterEncodingChooserTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    
    self = [super initWithRootViewController:encodingChooser];
    if (self) {
        
        // Custom initialization
        
        self.documentURL = documentURL;
        
        [self deduceSeparatorFromFileUTI:documentURL];
        
        
        // Use the default encoding MacOS Roman
        self.fileEncoding = NSMacOSRomanStringEncoding;
        
        
        UIBarButtonItem * cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelAndDismiss:)];
        

        encodingChooser.navigationItem.leftBarButtonItem = cancelButton;
        encodingChooser.title = NSLocalizedString(@"Import", nil);
        
    }
    return self;
}

-(void)startParsing:(id)sender{
    
    [SVProgressHUD show];
    
    dispatch_queue_t request_queue = dispatch_queue_create("com.pumaxprod.iOS.Password-Sync-2.csvImportParsingQueue", NULL);
    
    __block __typeof__(self) blockSelf = self;
    
    dispatch_async(request_queue, ^{
        
        
        NSStringEncoding encoding = self.fileEncoding;
        
        NSInputStream *stream = [NSInputStream inputStreamWithURL:self.documentURL];
        CHCSVParser * parser = [[CHCSVParser alloc] initWithInputStream:stream usedEncoding:&encoding delimiter:[self.separator characterAtIndex:0]];
        [parser setRecognizesBackslashesAsEscapes:YES];
        [parser setSanitizesFields:YES];
		
        [parser setDelegate:self];
        
        [parser parse];
        blockSelf.parser = parser;
        
    });
    
    
    
}

#pragma mark - CHCSVParserDelegate methods

- (void)parserDidBeginDocument:(CHCSVParser *)parser {
    _lines = [[NSMutableArray alloc] init];
}

- (void)parser:(CHCSVParser *)parser didBeginLine:(NSUInteger)recordNumber {
    _currentLine = [[NSMutableArray alloc] init];
}
- (void)parser:(CHCSVParser *)parser didReadField:(NSString *)field atIndex:(NSInteger)fieldIndex {
    [_currentLine addObject:field];
}
- (void)parser:(CHCSVParser *)parser didEndLine:(NSUInteger)recordNumber {
    [_lines addObject:_currentLine];
    _currentLine = nil;
}
- (void)parserDidEndDocument:(CHCSVParser *)parser {
    dispatch_sync(dispatch_get_main_queue(), ^{
        
        self.lines = [[NSMutableArray alloc] initWithArray:_lines copyItems:YES];
        [SVProgressHUD dismiss];
        
        PSSCSVColumnSelectorTableViewController * columnSelectorViewController = [[PSSCSVColumnSelectorTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
        
        [self pushViewController:columnSelectorViewController animated:YES];
        
        
        
    });
}

- (void)parser:(CHCSVParser *)parser didFailWithError:(NSError *)error {
	
    dispatch_sync(dispatch_get_main_queue(), ^{
        
        [SVProgressHUD dismiss];
        
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"An Error Occured", nil) message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
        
        [alert show];
        
        
        
        _lines = nil;
        
        
        
    });
    
    
}

@end

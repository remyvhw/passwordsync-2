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

@interface PSSCSVImporterNavigationController ()

@property (nonatomic, strong) NSMutableArray * currentLine;

@end

@implementation PSSCSVImporterNavigationController
@synthesize currentLine = _currentLine;
@synthesize lines = _lines;

-(void)endWithDataArrangment:(NSDictionary *)arrangementDictionary{
    
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Importing", nil) maskType:SVProgressHUDMaskTypeGradient];
    
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

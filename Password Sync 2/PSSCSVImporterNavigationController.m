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

@interface PSSCSVImporterNavigationController ()

@property (nonatomic, strong) NSMutableArray * currentLine;

@end

@implementation PSSCSVImporterNavigationController
@synthesize currentLine = _currentLine;
@synthesize lines = _lines;

-(void)cancelAndDismiss:(id)sender{
    
    [self dismissViewControllerAnimated:YES completion:NULL];
    
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
    
    
    
    NSStringEncoding encoding = self.fileEncoding;
    
    NSInputStream *stream = [NSInputStream inputStreamWithURL:self.documentURL];
	CHCSVParser * parser = [[CHCSVParser alloc] initWithInputStream:stream usedEncoding:&encoding delimiter:[self.separator characterAtIndex:0]];
    [parser setRecognizesBackslashesAsEscapes:YES];
    [parser setSanitizesFields:YES];
		
	[parser setDelegate:self];
	
	[parser parse];
    self.parser = parser;
    
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
    	NSLog(@"parser ended: %@", [_lines description]);
}

- (void)parser:(CHCSVParser *)parser didFailWithError:(NSError *)error {
	
    _lines = nil;
}

@end

//
//  PSSCSVImporterNavigationController.h
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-10-01.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CHCSVParser.h"

@interface PSSCSVImporterNavigationController : UINavigationController <CHCSVParserDelegate>

-(id)initWithCSVDocumentURL:(NSURL*)documentURL;
-(void)cancelAndDismiss:(id)sender;

-(void)startParsing:(id)sender;

@property (nonatomic, strong) NSURL* documentURL;
@property (nonatomic) NSStringEncoding fileEncoding;
@property (nonatomic, strong) NSString * separator;
@property (nonatomic, strong) CHCSVParser * parser;

@property (nonatomic, strong) NSMutableArray * lines;

@end

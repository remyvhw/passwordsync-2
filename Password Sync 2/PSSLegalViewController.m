//
//  PSSLegalViewController.m
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-08-14.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import "PSSLegalViewController.h"
#import "Reachability.h"

@interface PSSLegalViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation PSSLegalViewController

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
	// Do any additional setup after loading the view.
    
    NSString * loadingString = [NSString stringWithFormat:@"<html><body><div style='text-align:center;font-family:Helvetica Nueue, sans-serif;padding-top:1em;font-size:1.5em;font-weight:100;'>%@</div></body></html>", NSLocalizedString(@"Please Wait", nil)];
    [self.webView loadHTMLString:loadingString baseURL:[NSURL URLWithString:@"localhost"]];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.title = NSLocalizedString(@"Legal", nil);
    }
    
    Reachability* reach = [Reachability reachabilityWithHostname:@"appspot.com"];
    
    // Set the blocks
    reach.reachableBlock = ^(Reachability*reach)
    {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *languageCode = [[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode];
            
            
            NSURL * urlOfRequest = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@/legal?nochrome=true", PSSWebsiteDomainString, languageCode]];
            
            
            
            
            NSURLRequest * urlRequest = [[NSURLRequest alloc] initWithURL:urlOfRequest];
            
            [self.webView loadRequest:urlRequest];
        });
        [reach stopNotifier];
    };
    
    reach.unreachableBlock = ^(Reachability*reach)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString * loadingString = [NSString stringWithFormat:@"<html><body><div style='text-align:center;font-family:Helvetica Nueue, sans-serif;font-size:0.8em;padding-top:1em;font-weight:100;color:#8F2D32'>%@</div></body></html>", NSLocalizedString(@"The Internet connection appears to be offline.", nil)];
            [self.webView loadHTMLString:loadingString baseURL:[NSURL URLWithString:@"localhost"]];
        });
        
        
        [reach stopNotifier];
    };
    
    // Start the notifier, which will cause the reachability object to retain itself!
    [reach startNotifier];
    
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

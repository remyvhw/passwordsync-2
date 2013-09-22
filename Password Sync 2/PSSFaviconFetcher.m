//
//  PSSFaviconFetcher.m
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-07-13.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import "PSSFaviconFetcher.h"
#import "PSSPasswordBaseObject.h"
#import "PSSPasswordDomain.h"
#import "IGHTMLDocument.h"
#include "PSSDeviceCapacity.c"

@implementation PSSFaviconFetcher
dispatch_queue_t backgroundQueue;

- (id)init
{
    self = [super init];
    if (self) {
        backgroundQueue = dispatch_queue_create("com.pumaxprod.iOS.Password-Sync2.faviconfetcherBackgroundQueue", NULL);
    }
    return self;
}

-(UIImage*)requestImageAtURL:(NSURL*)url{
    NSData * requestData = [NSData dataWithContentsOfURL:url];
    
    if (requestData) {
        UIImage * image = [UIImage imageWithData:requestData];
        return image;
    }
    return nil;
}


-(UIImage*)requestFaviconFromServer:(NSURL*)fetchURL{
    
    NSURL * faviconURL = [fetchURL URLByAppendingPathComponent:@"favicon.ico"];
    
    return [self requestImageAtURL:faviconURL];
}



-(UIImage*)requestAppleTouchIconFromServer:(NSURL*)fetchURL{
    
    // A lot of servers have the touch icon at their root, we'll first try there.
    
    NSURL * touchIconURL = [fetchURL URLByAppendingPathComponent:@"apple-touch-icon.png"];
    
    NSURLRequest * touchIconAtRootRequest = [[NSURLRequest alloc] initWithURL:touchIconURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:15.];
    
    NSURLResponse * touchIconAtRootRequestResponse = nil;
    NSError * touchIconAtRootRequestError = nil;
    
    
    NSData * touchIconAtRootRequestContent = [NSURLConnection sendSynchronousRequest:touchIconAtRootRequest returningResponse:&touchIconAtRootRequestResponse error:&touchIconAtRootRequestError];
    
    if (!touchIconAtRootRequestError && touchIconAtRootRequestContent) {
        // A touch icon was found immediatly at the server's root (eg.: "http://apple.com/apple-touch-icon.png")
        UIImage * pngImage = [UIImage imageWithData:touchIconAtRootRequestContent];
        // TODO: remove comment
        if (pngImage) {
            return pngImage;
        }
        
    }
    
    // We prevent the execution of background parsing on devices with a single processor. Sorry iPhone 4.
    if (!PSSShouldRunAdvancedFeatures()) {
        return nil;
    }
    
    // We'll load the HTML in the home page and query it for an apple-touch-icon
    
    NSURLRequest * indexHTMLRequest = [[NSURLRequest alloc] initWithURL:fetchURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:15.];
    
    NSURLResponse * indexHTMLResponse = nil;
    NSError * indexHTMLRequestError = nil;
    
    NSData * indexHTMLRequestContent = [NSURLConnection sendSynchronousRequest:indexHTMLRequest returningResponse:&indexHTMLResponse error:&indexHTMLRequestError];
    
    if (!indexHTMLRequestError && indexHTMLRequestContent) {
        
        
        NSString * htmlString = [[NSString alloc] initWithData:indexHTMLRequestContent encoding:NSUTF8StringEncoding];
        
        if (!htmlString) {
            // Encoding might be wrong, try ASCII
            htmlString = [[NSString alloc] initWithData:indexHTMLRequestContent encoding:NSASCIIStringEncoding];
        }
        
        NSError * documentParserImportError;
        IGHTMLDocument* doc = [[IGHTMLDocument alloc] initWithHTMLString:htmlString error:&documentParserImportError];
        
        if (documentParserImportError) {
            NSLog(@"Error: %@", [documentParserImportError localizedDescription]);
            return nil;
        }
        
        
        // First, look for a apple-touch-icon
        NSString * touchIconPath = [[[doc queryWithXPath:@"//link[@rel='apple-touch-icon']"] firstObject] attribute:@"href"];
        if (touchIconPath) {
            NSLog(@"%@", touchIconPath);
            return [self requestImageAtURL:[NSURL URLWithString:touchIconPath relativeToURL:fetchURL]];
        }
        
        // Sometimes, they'll instead use apple-touch-icon-precomposed
        // First, look for a apple-touch-icon
        touchIconPath = [[[doc queryWithXPath:@"//link[@rel='apple-touch-icon-precomposed']"] firstObject] attribute:@"href"];
        if (touchIconPath) {
            return [self requestImageAtURL:[NSURL URLWithString:touchIconPath relativeToURL:fetchURL]];
        }
        
    }
    
    
    
    
    return nil;
    
}


-(UIImage*)fetchIconForURL:(NSURL*)fetchURL basePassword:(PSSPasswordBaseObject*)basePassword{
    
    
    // First, we'll try to extract an apple-touch-icon icon from the domain's main page.
    
    UIImage * passwordImage = nil;
    
    UIImage * touchIcon = [self requestAppleTouchIconFromServer:fetchURL];
    if (touchIcon) {
        passwordImage = touchIcon;
    } else {
        // So this failed. Now attempt to just grab the favicon from that server.
        UIImage * faviconIcon = [self requestFaviconFromServer:fetchURL];
        if (faviconIcon) {
            passwordImage = faviconIcon;
        }
    }
    
    
    if (passwordImage) {
        
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            
            [basePassword setFavicon:UIImagePNGRepresentation(passwordImage)];
            
            // Save the context
            [basePassword.managedObjectContext performBlock:^{
                            NSError *error = nil;
            if (![basePassword.managedObjectContext save:&error]) {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            }

            }];

            
        });
        
        
        
    }
    
    
    return nil;
}


#pragma mark - Public methods
-(void)backgroundFetchFaviconForBasePassword:(PSSPasswordBaseObject *)basePassword{
    
    dispatch_async(backgroundQueue, ^(void) {
        
        NSString * domainHostname = [[basePassword mainDomain] hostname];
        
        NSURL * hostnameURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@", domainHostname]];
        
        [self fetchIconForURL:hostnameURL basePassword:basePassword];
        
        
        
        
        
    });
    
    
}



@end

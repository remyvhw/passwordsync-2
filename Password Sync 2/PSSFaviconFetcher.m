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
#import "HTMLParser.h"

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

-(UIImage*)requestFaviconFromServer:(NSURL*)fetchURL{
    
    NSURL * faviconURL = [fetchURL URLByAppendingPathComponent:@"favicon.ico"];
    
    NSData * requestData = [NSData dataWithContentsOfURL:faviconURL];
    
    if (requestData) {
        UIImage * image = [UIImage imageWithData:requestData];
        return image;
    }
    
    return nil;
}


-(UIImage*)requestAppleTouchIconFromServer:(NSURL*)fetchURL{
    
    NSURL * touchIconURL = [fetchURL URLByAppendingPathComponent:@"apple-touch-icon.png"];
    
    NSURLRequest * urlRequest = [[NSURLRequest alloc] initWithURL:touchIconURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:15.];
    
    NSURLResponse * response = nil;
    NSError * error = nil;
    
    
    NSData * requestContent = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
    
    
    if (!error && requestContent) {
        
        UIImage * pngImage = [UIImage imageWithData:requestContent];
        return pngImage;
        
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
            NSError *error = nil;
            if (![basePassword.managedObjectContext save:&error]) {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"An error occured", nil) message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
                
            }

            
        });
        
        
        
    }
    
    
    return nil;
}


-(void)backgroundFetchFaviconForBasePassword:(PSSPasswordBaseObject *)basePassword{
    
    dispatch_async(backgroundQueue, ^(void) {
        
        NSString * domainHostname = [[basePassword mainDomain] hostname];
        
        NSURL * hostnameURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@", domainHostname]];
        
        [self fetchIconForURL:hostnameURL basePassword:basePassword];
        
        
        
        
        
    });
    
    
}

@end

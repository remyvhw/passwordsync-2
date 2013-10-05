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
#import "PSSDeviceCapacity.h"
#import "PSSAppDelegate.h"

@interface PSSFaviconFetcher ()

@property (nonatomic, strong) NSManagedObjectContext * context;

@end

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

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSManagedObjectContextDidSaveNotification
                                                  object:self.context];
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
        if (pngImage) {
            return pngImage;
        }
        
    }
    
    // We prevent the execution of background parsing on devices with a single processor. Sorry iPhone 4.
    if (![PSSDeviceCapacity shouldRunAdvancedFeatures]) {
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

-(void)saveInContext:(NSManagedObjectContext*)context{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(backgroundContextDidSave:)
                                                 name:NSManagedObjectContextDidSaveNotification
                                               object:context];
    
    
    
    // Save the context
    [context performBlock:^{
        NSError *error = nil;
        if (![context save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        }
        
    }];
    
    
    

}

-(UIImage*)fetchIconForURL:(NSURL*)fetchURL basePassword:(PSSPasswordBaseObject*)basePassword context:(NSManagedObjectContext*)context save:(BOOL)save{
    
    
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
        [basePassword setFavicon:UIImagePNGRepresentation(passwordImage)];
    }
    
    if (save) {
        
        
        
        [self saveInContext:context];
        
            
        
        
        
    }
    
    
    return passwordImage;
}

-(UIImage*)fetchIconForURL:(NSURL*)fetchURL basePassword:(PSSPasswordBaseObject*)basePassword{
    
    NSManagedObjectContext * backgroundContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    
    [backgroundContext setPersistentStoreCoordinator:APP_DELEGATE.persistentStoreCoordinator];
    
    self.context = backgroundContext;
    
    return [self fetchIconForURL:fetchURL basePassword:basePassword context:backgroundContext save:YES];
}

#pragma mark - Public methods
-(void)backgroundFetchFaviconForBasePassword:(PSSPasswordBaseObject *)basePassword{
    
    dispatch_async(backgroundQueue, ^(void) {
        
        NSString * domainHostname = [[basePassword mainDomain] hostname];
        
        NSURL * hostnameURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@", domainHostname]];
        
        [self fetchIconForURL:hostnameURL basePassword:basePassword];
        
        
        
        
        
    });
    
    
}


-(void)fetchFaviconForBasePasswords:(NSArray *)basePasswords inContext:(NSManagedObjectContext *)context{
    
    self.context = context;
    
        for (PSSPasswordBaseObject * basePassword in basePasswords) {
            NSString * domainHostname = [[basePassword mainDomain] hostname];
            
            NSURL * hostnameURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@", domainHostname]];
            
            [self fetchIconForURL:hostnameURL basePassword:basePassword context:context save:NO];
            [self saveInContext:context];
            
        }
    
    
    
        
        
        
        
    
    
}


@end

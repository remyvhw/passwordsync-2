//
//  PSSPasswordSyncOneDataImporter.m
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-08-20.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import "PSSPasswordSyncOneDataImporter.h"
#import "PDKeychainBindings.h"
#import "RNDecryptor.h"
#import "PSSPasswordBaseObject.h"
#import "PSSPasswordVersion.h"
#import "PSSAppDelegate.h"
#import "PSSFaviconFetcher.h"
#import "SVProgressHUD.h"

@interface PSSPasswordSyncOneDataImporter ()
@property (nonatomic, strong) NSManagedObjectContext * threadSafeContext;

@end

@implementation PSSPasswordSyncOneDataImporter

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

-(PSSPasswordBaseObject*)savePasswordWithDictionary:(NSDictionary*)passwordDict{
    
    PSSPasswordBaseObject* passwordBase = [self insertNewPasswordInManagedObject];
    
    if ([passwordDict objectForKey:@"URL"]) {
        [passwordBase setMainDomainFromString:[passwordDict objectForKey:@"URL"]];
    }
    
    PSSPasswordVersion * version = [self insertNewPasswordVersionInManagedObject];
    
    version.encryptedObject = passwordBase;
    
    version.displayName = [passwordDict objectForKey:@"title"];
    passwordBase.displayName = version.displayName;
    
    if ([passwordDict objectForKey:@"username"]) {
        version.decryptedUsername = [passwordDict objectForKey:@"username"];
    }
    if ([passwordDict objectForKey:@"password"]) {
        version.decryptedPassword = [passwordDict objectForKey:@"password"];
    }
    if ([passwordDict objectForKey:@"notes"]) {
        version.decryptedNotes = [passwordDict objectForKey:@"notes"];
    }
    
    passwordBase.currentVersion = version;
    
    return passwordBase;
    
}

-(NSString *) genRandStringLength: (int) len {
    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    
    NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
    
    for (int i=0; i<len; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random() % [letters length]]];
    }
    
    return randomString;
}

-(void)beginImportProcedure:(id)sender{
    
    // Generate a random key
    
    NSString * randomEncryptionKey = [self genRandStringLength:14];
    
    // Save the random key
    [[PDKeychainBindings sharedKeychainBindings] setString:randomEncryptionKey forKey:PSSPasswordSyncOneImporterEncryptionKey];
    
    // Build an URL
    NSString * pathToPasswordSyncOne = [NSString stringWithFormat:@"passsyncjsonexport://passsynctwoupgrade?enckey=%@", randomEncryptionKey];
    
    // Open it
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:pathToPasswordSyncOne]];
    
    
}

-(BOOL)handleImportURL:(NSURL *)importUrl{
    
    
    NSString * queryString = [[importUrl query] stringByReplacingOccurrencesOfString:@"content=" withString:@""];
    
    NSString * pureBase64String = [[[queryString stringByReplacingOccurrencesOfString:@"-" withString:@"+"] stringByReplacingOccurrencesOfString:@"_" withString:@"/"] stringByReplacingOccurrencesOfString:@"*" withString:@"="];
    
    NSData * encryptedJSONData = [[NSData alloc] initWithBase64EncodedString:pureBase64String options:0];
    
    NSString * encryptionKey = [[PDKeychainBindings sharedKeychainBindings] stringForKey:PSSPasswordSyncOneImporterEncryptionKey];
    
    
    NSError * error;
    NSData * decodedJSONData = [RNDecryptor decryptData:encryptedJSONData withPassword:encryptionKey error:&error];
    
    if (error) {
        return NO;
    }
    
    __block NSArray * originalArray = [NSJSONSerialization JSONObjectWithData:decodedJSONData options:0 error:&error];
    
    if (error) {
        return NO;
    }
    
    
    // Switch to another thread
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    
    dispatch_queue_t main_queue = dispatch_get_main_queue();
    dispatch_queue_t request_queue = dispatch_queue_create("com.pumaxprod.iOS.Password-Sync-2.passwordsyncOneImportThread", NULL);
    
    __block __typeof__(self) blockSelf = self;
    
    dispatch_async(request_queue, ^{
        
        // update and heavy lifting...
        
        NSManagedObjectContext * threadSafeContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [threadSafeContext setPersistentStoreCoordinator:APP_DELEGATE.persistentStoreCoordinator];
        self.threadSafeContext = threadSafeContext;
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(backgroundContextDidSave:)
                                                     name:NSManagedObjectContextDidSaveNotification
                                                   object:threadSafeContext];
        
        NSMutableArray * importedPasswords = [[NSMutableArray alloc] initWithCapacity:originalArray.count];
        
        for (NSDictionary * passwordDict in originalArray) {
            [importedPasswords addObject:[blockSelf savePasswordWithDictionary:passwordDict]];
        }
        
        [self.threadSafeContext performBlockAndWait:^{
            NSError * error;
            [self.threadSafeContext save:&error];
        }];
        
        
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:NSManagedObjectContextDidSaveNotification
                                                      object:threadSafeContext];
        
        
        
        
        
        
        dispatch_sync(main_queue, ^{
            
            
            [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"You're done!", nil)];
            
            
            
        });
        
        PSSFaviconFetcher * faviconFetcher = [[PSSFaviconFetcher alloc] init];
        [faviconFetcher fetchFaviconForBasePasswords:importedPasswords inContext:threadSafeContext];
        
    });
    
    
    
    
    
    
    return YES;
}

@end

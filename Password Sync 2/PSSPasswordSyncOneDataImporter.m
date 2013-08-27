//
//  PSSPasswordSyncOneDataImporter.m
//  Password Sync 2
//
//  Created by Remy Vanherweghem on 2013-08-20.
//  Copyright (c) 2013 Pumax. All rights reserved.
//

#import "PSSPasswordSyncOneDataImporter.h"
#import "PDKeychainBindings.h"
#import "Base64.h"
#import "RNDecryptor.h"
#import "PSSPasswordBaseObject.h"
#import "PSSPasswordVersion.h"
#import "PSSAppDelegate.h"
#import "PSSFaviconFetcher.h"
#import "SVProgressHUD.h"

@implementation PSSPasswordSyncOneDataImporter



-(PSSPasswordVersion*)insertNewPasswordVersionInManagedObject{
    
    
    NSManagedObjectContext *context = [APP_DELEGATE managedObjectContext];
    PSSPasswordVersion *newManagedObject = (PSSPasswordVersion*)[NSEntityDescription insertNewObjectForEntityForName:@"PSSPasswordVersion" inManagedObjectContext:context];
    
    // We'll automatically timestamp it
    newManagedObject.timestamp = [NSDate date];
    
    return newManagedObject;
    
}

-(PSSPasswordBaseObject*)insertNewPasswordInManagedObject{
    
    NSManagedObjectContext *context = [APP_DELEGATE managedObjectContext];
    PSSPasswordBaseObject *newManagedObject = (PSSPasswordBaseObject*)[NSEntityDescription insertNewObjectForEntityForName:@"PSSPasswordBaseObject" inManagedObjectContext:context];
    
    // We'll add a creation date automatically
    newManagedObject.created = [NSDate date];
    
    return newManagedObject;
    
}

-(void)savePasswordWithDictionary:(NSDictionary*)passwordDict{
    
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
    
    PSSFaviconFetcher * faviconFetcher = [[PSSFaviconFetcher alloc] init];
    [faviconFetcher backgroundFetchFaviconForBasePassword:passwordBase];
    
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
    
    NSData * encryptedJSONData = [NSData dataWithBase64EncodedString:pureBase64String];
    
    NSString * encryptionKey = [[PDKeychainBindings sharedKeychainBindings] stringForKey:PSSPasswordSyncOneImporterEncryptionKey];
    
    
    NSError * error;
    NSData * decodedJSONData = [RNDecryptor decryptData:encryptedJSONData withPassword:encryptionKey error:&error];
    
    if (error) {
        return NO;
    }
    
    NSArray * originalArray = [NSJSONSerialization JSONObjectWithData:decodedJSONData options:0 error:&error];
    
    if (error) {
        return NO;
    }
    
    for (NSDictionary * passwordDict in originalArray) {
        [self savePasswordWithDictionary:passwordDict];
    }
    
    __block BOOL returnNO = NO;
    [APP_DELEGATE.managedObjectContext performBlockAndWait:^{
        NSError * error;
        if (![APP_DELEGATE.managedObjectContext save:&error]) {
            returnNO = YES;
        }
    }];
    
    if (returnNO) {
        return NO;
    }
    

    
    [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"You're done!", nil)];
    
    return YES;
}

@end
